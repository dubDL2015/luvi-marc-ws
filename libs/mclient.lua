local mconnector = require('mconnector')
local jsonStringify = require('cjson').encode

local SERVER = require('mapiV1').SERVER
local CONTEXTS = require('mapiV1').CONTEXTS
local RESULTS = require('mapiV1').RESULTS
local SESSION = require('mapiV1').SESSION

local mclient = {}

local servers  --will be loaded at run time via config file

function mclient.setConfig(conf)
  servers = conf.servers
 end


--local uri = { host = "127.0.0.1", port = 1254 }


local function exec(req, res, go)



  local knw_name = req.params.knw_name
  local server = servers[knw_name]

  if not server then
    local reason = knw_name.." is not found"
    res.headers = {
      ["Content-Type"] = "text/plain",
      ["Content-Length"] = #reason
    }
    
    res.code = 404
    res.body = reason
    return
  end

  if not req.mquery then 
    
    local reason = "empty query"
      res.headers = {
        ["Content-Type"] = "text/plain",
        ["Content-Length"] = #reason
      }
    
      res.code = 400
      res.body = reason
    return
  end

  local mresult = mconnector.execute(req.mquery, server)

  --we take by default the last resultset
  local tosend = mresult.resultset[#mresult.resultset]
  
  local body = jsonStringify(tosend)
  --local body = table.concat(mresult)

  res.headers = {
    { 'Content-Type', 'application/json' },
    { 'Content-Length', #body }
  }
  res.code = 200
  res.body = body

end




function mclient.getProperties(req, res, go)

  req.mquery = {
    SERVER.getProperties()
  }

  exec(req, res, go)
	
end


function mclient.getResources(req, res, go)
   local q = req.query
  if not q then 
    local reason = "empty query"
      res.headers = {
        ["Content-Type"] = "text/plain",
        ["Content-Length"] = #reason
      }
    
      res.code = 400
      res.body = reason
    return

  end --TODO send appropriate header


  local range = q["range"] or 20
  local offset = q["offset"] or 1

  req.mquery = {
    CONTEXTS.CLEAR(),
    SESSION.StringToContext(q["search"]),
    RESULTS.CLEAR(),
    SESSION.ContextToDoc(),
    RESULTS.SET("FORMAT", "rowId title Act"),
    RESULTS.FETCH(""..range, ""..offset)
    
  }
 
  exec(req, res, go)


end

return mclient