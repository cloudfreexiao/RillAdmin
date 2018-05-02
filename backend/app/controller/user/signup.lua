local pairs = pairs
local ipairs = ipairs
local smatch = string.match
local slen = string.len
local ssub = string.sub
local slower = string.lower

local utils = require("app.libs.utils")
local pwd_secret = require("app.config.config").pwd_secret

local user_model = require("app.model.user")

local role_lv = 1 --角色等级 用来 鉴权操作

return function(username, password) 
    local pattern = "^[a-zA-Z][0-9a-zA-Z_]+$"
    local match, err = smatch(username, pattern)

    if not username or not password or username == "" or password == "" then
        return {
            code = system_error_msg(AUTH_ERROR.account_nil),
            message = system_error_msg(AUTH_ERROR.account_nil),
        }
    end

    local username_len = slen(username)
    local password_len = slen(password)

    if username_len<4 or username_len>50 then
        return {
            success = false,
            msg = "用户名长度应为4~50位."
        }
    end
    if password_len<6 or password_len>50 then
        return {
            success = false,
            msg = "密码长度应为6~50位."
        }
    end

    if not match then
        return {
            success = false,
            msg = "用户名只能输入字母、下划线、数字，必须以字母开头."
        }
    end

    local result, err = user_model:query_by_username(username)
    local isExist = false
    if result and not err then
        isExist = true
    end

    if isExist == true then
        return {
            success = false,
            msg = "用户名已被占用，请修改."
        }
    else
        password = utils.encode(password .. "#" .. pwd_secret)
        local avatar = ssub(username, 1, 1) .. ".png" --取首字母作为默认头像名
        avatar = slower(avatar)
        local result, err = user_model:new(username, password, avatar, role_lv)
        if result and not err then
            return {
                success = true,
                msg = "注册成功."
            }
        else
            return {
                success = false,
                msg = "注册失败."
            }
        end
    end

end 