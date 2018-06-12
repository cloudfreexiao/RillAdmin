local lor = require("lor.index")
local apiRouter = lor:Router() -- 生成一个group router对象


local user_login = require("app.controller.user.login")
local user_signup = require("app.controller.user.signup")
local user_info = require("app.controller.user.user_info")

--注册
apiRouter:post("/signup", function(req, res, next)
    local body =  req.body 
    local username = body.username 
    local password = body.password

    local msg = user_signup(username, password)
    return res:json(msg)
end)

--登录
apiRouter:post("/login", function(req, res, next)
    local body = req.body 
    local username = body.username 
    local password = body.password
        
    local msg = user_login(req, username, password)
    return res:json(msg)
end)

apiRouter:get("/user", function(req, res, next)
    local msg = user_info(req, res)
    return res:json(msg)
end)

apiRouter:get("/list", function(req, res, next)
    local msg = user_info(req, res)
    return res:json(msg)
end)


apiRouter:post("/logout", function(req, res, next)
    res.locals.login = false
    res.locals.username = ""
    res.locals.userid = 0
    res.locals.create_time = ""
    req.session.destroy()
end)

return apiRouter