local binutil           = require 'resty.fastcgi.binutil'
local ntob              = binutil.ntob
local bton              = binutil.bton

local bit_band          = bit.band

local ngx_socket_tcp    = ngx.socket.tcp
local ngx_log           = ngx.log
local ngx_DEBUG         = ngx.DEBUG
local ngx_ERR           = ngx.ERR

local str_char          = string.char
local str_sub           = string.sub

local tbl_concat        = table.concat
local pairs             = pairs
local ipairs            = ipairs


local _M = {
    _VERSION = '0.01',
}

local mt = { __index = _M }


local FCGI_HEADER_LEN         = 0x08
local FCGI_VERSION_1          = 0x01
local FCGI_BEGIN_REQUEST      = 0x01
local FCGI_ABORT_REQUEST      = 0x02
local FCGI_END_REQUEST        = 0x03
local FCGI_PARAMS             = 0x04
local FCGI_STDIN              = 0x05
local FCGI_STDOUT             = 0x06
local FCGI_STDERR             = 0x07
local FCGI_DATA               = 0x08
local FCGI_GET_VALUES         = 0x09
local FCGI_GET_VALUES_RESULT  = 0x10
local FCGI_UNKNOWN_TYPE       = 0x11
local FCGI_MAXTYPE            = 0x11
local FCGI_PARAM_HIGH_BIT     = 2147483648
local FCGI_BODY_MAX_LENGTH    = 32768
local FCGI_KEEP_CONN          = 0x01
local FCGI_NO_KEEP_CONN       = 0x00
local FCGI_NULL_REQUEST_ID    = 0x00
local FCGI_RESPONDER          = 0x01
local FCGI_AUTHORIZER         = 0x02
local FCGI_FILTER             = 0x03


local FCGI_HEADER_FORMAT = {
    {"version",1,FCGI_VERSION_1},
    {"type",1,nil},
    {"request_id",2,1},
    {"content_length",2,0},
    {"padding_length",1,0},
    {"reserved",1,0}
}


local FCGI_BEGIN_REQ_FORMAT = {
    {"role",2,FCGI_RESPONDER},
    {"flags",1,0},
    {"reserved",5,0}
}


local FCGI_END_REQ_FORMAT = {
    {"status",4,nil},
    {"protocolStatus",1,nil},
    {"reserved",3,nil}
}


local FCGI_PADDING_BYTES = {
    str_char(0),
    str_char(0,0),
    str_char(0,0,0),
    str_char(0,0,0,0),
    str_char(0,0,0,0,0),
    str_char(0,0,0,0,0,0),
    str_char(0,0,0,0,0,0,0),
}


local function _pack(format,params)
    local bytes = ""

    for index, field in ipairs(format) do
        local fieldname     = field[1]
        local fieldlength   = field[2]
        local defaulval     = field[3]

        if params[fieldname] == nil then
            bytes = bytes .. ntob(defaulval,fieldlength)
        else
            bytes = bytes .. ntob(params[fieldname],fieldlength)
        end
    end

    return bytes
end


local function _pack_header(params)
    local align = 8
    params.padding_length = bit_band(-(params.content_length or 0),align - 1)
    return _pack(FCGI_HEADER_FORMAT,params), params.padding_length
end


local function _unpack(format,str)
    -- If we received nil, return nil
    if not str then
        return nil
    end

    local res, idx = {}, 1

    -- Extract bytes based on format. Convert back to number and place in res rable
    for _, field in ipairs(format) do
        res[field[1]] = bton(str_sub(str,idx,idx + field[2] - 1))
        idx = idx + field[2]
    end

    return res
end


local FCGI_PREPACKED = {
    end_params = _pack_header({
        type    = FCGI_PARAMS,
    }),
    begin_request = _pack_header({
        type            = FCGI_BEGIN_REQUEST,
        request_id      = 1,
        content_length  = FCGI_HEADER_LEN,
    }) .. _pack(FCGI_BEGIN_REQ_FORMAT,{
        role    = FCGI_RESPONDER,
        flags   = 1,
    }),
    abort_request = _pack_header({
        type            = FCGI_ABORT_REQUEST,
    }),
    empty_stdin = _pack_header({
        type            = FCGI_STDIN,
        content_length  = 0,
    }),
}


local function _pad(bytes)
    if bytes == 0 then
        return ""
    else
        return FCGI_PADDING_BYTES[bytes]
    end
end


function _M.new(_)
    local sock, err = ngx_socket_tcp()
    if not sock then
        return nil, err
    end

    local self = {
        sock            = sock,
        keepalives      = false,
    }

    return setmetatable(self, mt)
end


function _M.set_timeout(self, timeout)
    local sock = self.sock
    if not sock then
        return nil, "not initialized"
    end

    return sock:settimeout(timeout)
end


function _M.connect(self, ...)
    local sock = self.sock
    if not sock then
        return nil, "not initialized"
    end

    self.host = select(1, ...)

    return sock:connect(...)
end


function _M.set_keepalive(self, ...)
    local sock = self.sock
    if not sock then
        return nil, "not initialized"
    end

    return sock:setkeepalive(...)
end


function _M.get_reused_times(self)
    local sock = self.sock
    if not sock then
        return nil, "not initialized"
    end

    return sock:getreusedtimes()
end


function _M.close(self)
    local sock = self.sock
    if not sock then
        return nil, "not initialized"
    end

    return sock:close()
end


local function _format_params(params)
    local new_params, idx = {}, 1

    -- Iterate over each param
    for key,value in pairs(params) do
        key             = tostring(key)
        value           = tostring(value)

        local keylen    = #key
        local valuelen  = #value

        -- If length of field is longer than 127, we represent
        -- it as 4 bytes with high bit set to 1 (+2147483648
        -- or FCGI_PARAM_HIGH_BIT)

        local keylen_b, valuelen_b

        if keylen <= 127 then
            keylen_b = ntob(keylen)
        else
            keylen_b = ntob(keylen + FCGI_PARAM_HIGH_BIT,4)
        end

        if valuelen <= 127 then
            valuelen_b = ntob(valuelen)
        else
            valuelen_b = ntob(valuelen + FCGI_PARAM_HIGH_BIT,4)
        end

        new_params[idx] = tbl_concat({
            keylen_b,
            valuelen_b,
            key,
            value,
        })

        idx = idx + 1
    end

    local new_params_str = tbl_concat(new_params)

    local start_params, padding = _pack_header({
        type            = FCGI_PARAMS,
        content_length  = #new_params_str
    })

    return tbl_concat({ start_params, new_params_str, _pad(padding), FCGI_PREPACKED.end_params })
end


local function _format_stdin(stdin)
    local chunk_length
    local to_send = {}
    local stdin_chunk = {"","",""}
    local header = ""
    local padding, idx = 0, 1
    local stdin_length = #stdin

    -- We could potentially need to send more than one records' worth of data, so
    -- loop to format.
    repeat
        -- While we still have stdin data, build up STDIN record in chunks
        if stdin_length > FCGI_BODY_MAX_LENGTH then
            chunk_length = FCGI_BODY_MAX_LENGTH
        else
            chunk_length = stdin_length
        end

        header, padding = _pack_header({
            type            = FCGI_STDIN,
            content_length  = chunk_length,
        })

        stdin_chunk[1] = header
        stdin_chunk[2] = str_sub(stdin,1,chunk_length)
        stdin_chunk[3] = _pad(padding)

        to_send[idx] = tbl_concat(stdin_chunk)
        stdin = str_sub(stdin,chunk_length+1)
        stdin_length = stdin_length - chunk_length
        idx = idx + 1
    until stdin_length == 0

    return tbl_concat(to_send)
end


local function _send_stdin(sock,stdin)

    local ok, bytes, err, chunk, partial

    if type(stdin) == 'function' then
        repeat
            chunk, err, partial = stdin(FCGI_BODY_MAX_LENGTH)

            -- If the iterator returns nil, then we have no more stdin
            -- Send an empty stdin record to signify the end of the request
            if chunk then
                ngx_log(ngx_DEBUG,"Request body reader yielded ",#chunk," bytes of data - sending")
                ok,err = sock:send(_format_stdin(chunk))
                if not ok then
                    ngx_log(ngx_DEBUG,"Unable to send ",#chunk," bytes of stdin: ",err)
                    return nil, err
                end
            -- Otherwise iterator errored, return
            elseif err ~= nil then
                ngx_log(ngx_DEBUG,"Request body reader yielded an error: ",err)
                return nil, err, partial
            end
        until chunk == nil
    elseif stdin ~= nil then
        ngx_log(ngx_DEBUG,"Sending ",#stdin," bytes of read data")
        bytes, err = sock:send(_format_stdin(stdin))

        if not bytes then
            return nil, err
        end
    end

    -- Send empty stdin record to signify end
    bytes, err = sock:send(FCGI_PREPACKED.empty_stdin)

    if not bytes then
        return nil, err
    end

    return true, nil
end


function _M.get_response_reader(self)
    local sock              = self.sock
    local record_type       = nil
    local content_length    = 0
    local padding_length    = 0

    return function(chunk_size)
        -- 65536 is the maximum content length of a FCGI record
        local chunk_size = chunk_size or 65536
        local res = { stdout = nil, stderr = nil}
        local data, err, partial, header_bytes, bytes_to_read

        -- If we don't have a length of data to read yet, attempt to read a record header
        if not record_type then
            ngx_log(ngx_DEBUG,"Attempting to grab next FCGI record")
            local header_bytes, err = sock:receive(FCGI_HEADER_LEN)
            local header = _unpack(FCGI_HEADER_FORMAT,header_bytes)

            if not header then
                return nil, err or "Unable to parse FCGI record header"
            end

            record_type     = header.type
            content_length  = header.content_length
            padding_length  = header.padding_length

            ngx_log(ngx_DEBUG,"New content length is ",content_length," padding ",padding_length)

            -- If we've reached the end of the request, return nil
            if record_type == FCGI_END_REQUEST then
                ngx_log(ngx_DEBUG,"Attempting to read end request")
                read_bytes, err, partial = sock:receive(content_length)

                if not read_bytes or partial then
                    return nil, err or "Unable to parse FCGI end request body"
                end

                return nil -- TODO: Return end request format correctly without breaking
            end
        end

        -- Calculate maximum readable buffer size
        if chunk_size >= content_length then
            bytes_to_read = content_length
        else
            bytes_to_read = chunk_size
        end

        -- If we have any bytes to read, read these now
        if bytes_to_read > 0 then
            data, err, partial = sock:receive(bytes_to_read)

            if not data then
                return nil, err or "Unable to retrieve request body", partial
            end

            -- Reduce content_length by the amount that we've read so far
            content_length = content_length - bytes_to_read
            ngx_log(ngx_DEBUG,"Reducing content length by ", bytes_to_read," bytes to ",content_length)
        end

        -- Place received data into correct result attribute based on record type
        if record_type == FCGI_STDOUT then
            res.stdout = data
        elseif record_type == FCGI_STDERR then
            res.stderr = data
        else
            return nil, err or "Attempted to receive an unknown FCGI record"
        end

        -- If we've read all of the data that we have 'available' in this record, then start again
        -- by attempting to parse another record the next time this function is called.
        if content_length == 0 then
            -- Read and discard padding data
            _ = sock:receive(padding_length)
            ngx_log(ngx_DEBUG,"Resetting record type")
            record_type = nil
        end

        return res, nil
    end

end


function _M.request(self,parameters)
    local sock      = self.sock
    local stdin     = parameters.stdin
    local params    = parameters.params

    -- Build request
    local req = {
        FCGI_PREPACKED.begin_request,   -- Generate start of request
        _format_params(params),         -- Generate params (HTTP / FCGI headers)
    }

    -- Send request
    local bytes_sent, err, partial = sock:send(req)
    if not bytes_sent then
        return nil, "Failed to send request, " .. err, partial
    end

    -- Send body if any
    local ok, err, partial = _send_stdin(sock, stdin)
    if not ok then
        return nil, "Failed to send stdin, " .. (err or "Unkown error"), partial
    end

    return true, nil
end

return _M