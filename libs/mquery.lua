--high level API

local mapi = require('mapiV1')
--load apis
local SERVER = mapi.SERVER
local CONTEXTS = mapi.CONTEXTS
local RESULTS = mapi.RESULTS
local SESSION = mapi.SESSION

local _M = {}

function _M.getProperties(...)

  return {SERVER.getProperties(...)}
	
end

function _M.getResources(req)
  --will be available later directly in weblit-app
  local q = req.query
  if not q then end --TODO send appropriate header

  local range = q["range"] or 20
  local offset = q["offset"] or 1

  return {
    CONTEXTS.CLEAR(),
    SESSION.StringToContext(q["search"]),
    RESULTS.CLEAR(),
    SESSION.ContextToDoc(),
    RESULTS.SET("FORMAT", "rowId title Act"),
    RESULTS.FETCH(""..range, ""..offset)
    
  }
 
 


end

return _M