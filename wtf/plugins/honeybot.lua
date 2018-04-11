local require = require
local cjson = require("cjson")
local tools = require("wtf.core.tools")
local Plugin = require("wtf.core.classes.plugin")

local _M = Plugin:extend()
_M.name = "honeybot"

function _M:access()
    if not ngx.ctx.get then
        ngx.ctx.get, ngx.ctx.post, ngx.ctx.files = require("resty.reqargs")()
    end
end

function _M:log(...)
    local select = select
    local instance = select(1, ...)
    local ngx = ngx
    local os = os
    local md5 = require("resty.nettle.md5")
    local str = require("resty.string")

    local data = {}
    data["id"] = ngx.var.request_id
    data["ip"] = ngx.var.remote_addr
    data["uri"] = ngx.var.uri
    data["sni"] = ngx.var.ssl_server_name
    data["date"] = os.time(os.date("!*t"))
    data["method"] = ngx.var.request_method
    data["headers"] = ngx.req.get_headers()
    data["get"] = ngx.ctx.get or {}
    data["post"] = ngx.ctx.post or {}
    data["files"] = {}
    if ngx.ctx.files then
        for key,val in pairs(ngx.ctx.files) do
            local f=io.open(val["temp"],"rb")
            local content=f:read("*a")
            local hash=md5.new()
            hash:update(content)
            data["files"][key]=val
            data["files"][key]["md5"]=str.to_hex(hash:digest())
            data["files"][key]["content"]=string.sub(content,1,1024)
        end
    end
    instance:note(cjson.encode(data))

    return self
end

return _M

