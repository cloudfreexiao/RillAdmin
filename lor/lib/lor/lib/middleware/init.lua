local init_middleware = function(req, res, next)
    req.res = res
    req.next = next
    res.req = req
    res.locals = res.locals or {}
    next()
end

return init_middleware
