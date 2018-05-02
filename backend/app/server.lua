local string_find = string.find
local string_lower = string.lower

local lor = require("lor.index")
local router = require("app.router")
local app = lor()

local config = require("app.config.config")
local whitelist = config.whitelist
local view_config = config.view_config
local upload_config = config.upload_config

-- 模板配置
app:conf("view enable", true)
app:conf("view engine", view_config.engine)
app:conf("view ext", view_config.ext)
app:conf("views", view_config.views)


-- session和cookie支持，如果不需要可注释以下配置
local mw_cookie = require("lor.lib.middleware.cookie")
local mw_session = require("lor.lib.middleware.session")
local mw_check_login = require("app.middleware.check_login")
local mw_uploader = require("app.middleware.uploader")
-- 自定义中间件1: 注入一些全局变量供模板渲染使用
local mw_inject_version = require("app.middleware.inject_app_info")

app:use(mw_cookie())
app:use(mw_session({
    session_key = "__app__", -- the key injected in cookie
    session_aes_key = "aes_&gdk325dh888ffffld", -- should set by yourself
    timeout = 3600 -- default session timeout is 3600 seconds
}))

app:use(mw_inject_version())

-- intercepter: login or not
app:use(mw_check_login(whitelist))

-- uploader
app:use(mw_uploader({
	dir = upload_config.dir
}))

--自定义中间件2: 设置响应头
app:use(function(req, res, next)
        --暂时 这么处理 跨域访问 
    res:set_header("X-Powered-By", "Lor framework")
    res:set_header("Access-Control-Allow-Origin", "http://192.168.1.25:10000")

    res:set_header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
    res:set_header("Access-Control-Allow-Credentials", "true")
    res:set_header("Access-Control-Allow-Headers", "Authorization,Content-Type,Accept,Origin,User-Agent,DNT,Cache-Control,X-Mx-ReqToken,Keep-Alive,X-Requested-With,If-Modified-Since,X-Msys-Subaccount,X-Sparky")
    next()
end)

router(app) -- 业务路由处理

-- 错误处理插件，可根据需要定义多个
app:erroruse(function(err, req, res, next)
    -- ngx.log(ngx.ERR, err)
    ERROR("error: ", err)
    --暂时 这么处理 跨域访问 
    res:set_header("Access-Control-Allow-Origin", "http://192.168.1.25:10000")

    res:set_header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
    res:set_header("Access-Control-Allow-Credentials", "true")
    res:set_header("Access-Control-Allow-Headers", "Authorization,Content-Type,Accept,Origin,User-Agent,DNT,Cache-Control,X-Mx-ReqToken,Keep-Alive,X-Requested-With,If-Modified-Since,X-Msys-Subaccount,X-Sparky")
    local method = req.method and string_lower(req.method)
    if method == "options" then
        res:set_header("Access-Control-Max-Age", "1728000")
        res:set_header("Content-Length", "0")
        return 
    end 

    if req:is_found() ~= true then
        if string_find(req.headers["Accept"], "application/json") then
            res:status(404):json({
                success = false,
                msg = "404! sorry, not found."
            })
        else
            res:status(404):send("404! sorry, not found. " .. (req.path or ""))
        end
    else
        if string_find(req.headers["Accept"], "application/json") then
            res:status(500):json({
                success = false,
                msg = "500! internal error, please check the log."
            })
        else
            res:status(500):send("internal error, please check the log.")
        end
    end
end)

return app
