local utils = require("app.libs.utils")
-- local jwt = require("app.libs.jwt.jwt")

local pwd_secret = require("app.config.config").pwd_secret
local jwt_secret = require("app.config.config").jwt_secret

local user_model = require("app.model.user")

return function (req, username, password)
    if not username or not password or username == "" or password == "" then
        return {
            code = AUTH_ERROR.account_nil,
            message = system_error_msg(AUTH_ERROR.account_nil),
        }
    end

    local isExist = false
    local userid = 0

    password = utils.encode(password .. "#" .. pwd_secret)
    local result, err = user_model:query(username, password)

    local user = {}
    if result and not err then
        if result and #result == 1 then
            isExist = true
            user = result[1] 
            userid = user.id
        end
    else
        isExist = false
    end

    -- 生成 token 的有效期
    local now = ngx.now()
    local exp = now + 1200

    if isExist == true then
        -- local jwt_token = jwt:sign(jwt_secret, {
        --     header = { typ = "JWT", alg = "HS256" },
        --     payload = { foo = "bar", id = 1, name = "mind029", exp = exp }
        -- })
        
        local token = ngx.md5(username .. password .. os.time() .. "fishadminapi") 
        req.session.set("user", {
            username = username,
            userid = userid,
            create_time = user.create_time or "",
            token = token
        })

        return {
            code = SYSTEM_ERROR.success,
            message = system_error_msg(SYSTEM_ERROR.success),
            data = {
                token = token
            }
        }
    else
        return {
            code = AUTH_ERROR.account_error,
            message = system_error_msg(AUTH_ERROR.account_error),
        }
    end

end 