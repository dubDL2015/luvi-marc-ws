local mconnector = require('mconnector')
local jsonStringify = require('json').stringify
local url_parse = require('querystring').parse
local SERVER = require('marc_api_V1').SERVER
local CONTEXTS = require('marc_api_V1').CONTEXTS
local RESULTS = require('marc_api_V1').RESULTS
local SESSION = require('marc_api_V1').SESSION

local mclient = {}

local servers  --will be loaded at run time via config file

function mclient.setConfig(conf)
  servers = conf.servers
end

local function getServer(knw_name)
  return servers[knw_name]
end

--local uri = { host = "127.0.0.1", port = 1254 }



local function exec(query, req, res, go)

  local knw_name = req.params.knw_name
  local server = getServer(knw_name)

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

  local mresult = mconnector.execute(query, server)

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

  local query = {
    SERVER.getProperties()
  }

  exec(query, req, res, go)
	
end


function mclient.getResources(req, res, go)

  local uri_params = url_parse(req.path,"?&","=")
  local range = uri_params.range or 20
  local offset = uri_params.offset or 1

  local query = {
    CONTEXTS.CLEAR(),
    SESSION.StringToContext(uri_params.search),
    RESULTS.CLEAR(),
    SESSION.ContextToDoc(),
    RESULTS.SET("FORMAT", "rowId title Act"),
    RESULTS.FETCH(""..range, ""..offset)
    
  }
 
  exec(query, req, res, go)


end

return mclient