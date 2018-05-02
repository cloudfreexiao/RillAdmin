
local function is_login(req)
	local user
    if req.session then
        user =  req.session.get("user") 
		if user and user.username and user.userid then 
            return true, user
		end
    end
    return false, nil
end

return function (req, res)
    local user = is_login(req)
    assert(user)
    local msg = {
        code = SYSTEM_ERROR.success,
        message = system_error_msg(SYSTEM_ERROR.success),
        data = {
            name = "goodname", 
            avatar = "333333",
            roles = {[1] = "/api/getRoles",
                    [2] = "/api/role",},
            permissions = {[1]="/api/permissions/"},
        }

    }
    return msg
end