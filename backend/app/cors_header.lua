local cors_whitelist = require("app.config.config").cors_whitelist

--跨域访问 头 设置 
return function (res) 
    res:set_header("X-Powered-By", "Lor framework")
    res:set_header("Access-Control-Allow-Origin", cors_whitelist)

    res:set_header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
    res:set_header("Access-Control-Allow-Credentials", "true")
    res:set_header("Access-Control-Allow-Headers", "Authorization,Content-Type,Accept,Origin,User-Agent,DNT,Cache-Control,X-Mx-ReqToken,Keep-Alive,X-Requested-With,If-Modified-Since,X-Msys-Subaccount,X-Sparky")
end