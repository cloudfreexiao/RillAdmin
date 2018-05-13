local ffi = require 'ffi'

local str_byte      = string.byte
local str_char      = string.char
local bit_lshift    = bit.lshift
local bit_rshift    = bit.rshift
local bit_band      = bit.band
local tbl_concat    = table.concat
local ipairs        = ipairs
local ffi_new       = ffi.new

local _M = {}

-- Number to binary. Converts a lua number into binary string with <bytes> bytes (8 max)
function _M.ntob(num,bytes)
    bytes = bytes or 1

    local str = ""

    -- Mask high bit
    local mask = bit_lshift(0xff,(bytes-1)*8)

    for i=1, bytes do
        -- Isolate current bit by anding it with mask, then shift it bytes-i right
        -- This puts it into byte '0'.
        local val = bit_rshift(bit_band(num,mask),(bytes-i)*8)
        -- Pass it to str_char and append to string
        str = str .. str_char(val)
        -- Shift the mask 1 byte to the left and repeat
        mask = bit_rshift(mask,8)
    end
    return str
end


function _M.bton(str)
    local num = 0
    local bytes = {str_byte(str,1,#str)}

    for _, byte in ipairs(bytes) do
        num = bit_lshift(num,8) + bit_band(byte,0xff)
    end
    return num
end

return _M