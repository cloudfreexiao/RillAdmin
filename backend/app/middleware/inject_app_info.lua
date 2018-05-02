--- 中间件示例： 为每个请求注入一些通用的变量
local lor = require("lor.index")
return function()
    return function(req, res, next)
        -- res.locals是一个table, 可以在这里注入一些“全局”变量
        -- 这个示例里注入app的名称和版本号， 在渲染页面时即可使用
        res.locals.app_name = "lor application"
        res.locals.app_version = lor.version or ""
        next()
    end
end
