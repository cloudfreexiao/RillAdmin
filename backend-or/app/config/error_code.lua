local errors = {}

function system_error_msg(ec)
	if not ec then
		return "nil"
	end
	return errors[ec].desc
end

local function add(err)
	assert(errors[err.code] == nil, string.format("have the same error code[%x], msg[%s]", err.code, err.message))
	errors[err.code] = {code = err.code, desc = err.desc}
	return err.code
end

SYSTEM_ERROR = {
    success            = add{code = 0x0000, desc = "请求成功"},
    failed              = add{code = 0x0001, desc = "操作失败"},
}

AUTH_ERROR = {
    account_error        = add{code = 0x0101, desc = "用户名或密码错误，请检查!"},
	account_nil          = add{code = 0x0102, desc = "用户名和密码不得为空!"},
	account_login          = add{code = 0x0103, desc = "该操作需要先登录!"},

}



return errors