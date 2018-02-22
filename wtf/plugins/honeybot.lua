local require = require
local cjson = require("cjson")
local tools = require("wtf.core.tools")
local Plugin = require("wtf.core.classes.plugin")

local _M = Plugin:extend()
_M.name = "honeybot"

function _M:log(...)
  local select = select
	local instance = select(1, ...)
  local ngx= ngx
  local os = os

  local data = {}
  data["id"] = ngx.var.request_id
  data["ip"] = ngx.var.remote_addr
  data["uri"] = ngx.var.uri
  data["sni"] = ngx.var.ssl_server_name
  data["date"] = os.time(os.date("!*t"))
  data["method"] = ngx.var.request_method
  data["headers"] = ngx.req.get_headers()
  data["get"], data["post"], data["files"] = require("resty.reqargs")()
  instance:note(cjson.encode(data))

	return self
end

return _M

