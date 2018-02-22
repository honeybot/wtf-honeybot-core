local require = require
local cjson = require("cjson")
local Solver = require("wtf.core.classes.solver")
local tools = require("wtf.core.tools")

local _M = Solver:extend()
_M.name = "honeybot"

function _M:check_condition(obj)
  local ipairs = ipairs
  local pairs = pairs
  local type = type
  local string = string
  local warn = tools.warn
  local excludes = self:get_optional_parameter('exclude') or {}
  local res
  
  for key,value in pairs(excludes) do
    if obj[key] then
      if type(value) == "string" and type(obj[key]) == "string" then
        return string.match(obj[key], value)
      elseif type(value) =="number" and type(obj[key] == "number") then
        return value == obj[key]
      elseif type(value) == "table" and type(obj[key]) == "string" then
        for _,p in ipairs(value) do
          if type(p) == "string" then 
            res = string.match(obj[key], p)
            if res then return res end
          end
        end
      elseif type(value) == "table" and type(obj[key]) == "number" then
        for _,n in ipairs(value) do
          if type(n) == "number" then 
            res = (obj[key] == n)
            if res then return res end
          end
        end
      else
        warn("Unsupported types when processing excludes at "..self.name..": '"..key.."' value type is "..type(obj[key])..", and condition type is "..type(value))
      end
    end
  end
end

function _M:log(...)
  local select = select
  
	local caller = select(1, ...)
  local action_name = self:get_mandatory_parameter('action')
  local action = caller:get_action(action_name)
  
  local obj

  for _, note in self:get_notes() do
    obj = cjson.decode(note)
    if not self:check_condition(obj) then
      action:act(obj)
    end
  end
    
	return self
end

return _M