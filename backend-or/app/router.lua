-- 业务路由管理
local apiRouter = require("app.routes.api")

return function(app)
    app:use("/api", apiRouter)
end

