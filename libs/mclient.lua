local mconnector = require('mconnector')
local json = require('cjson')

local mclient = {}

local uri = { host = "127.0.0.1", port = 1254 }


function mclient.getProperties(req, res, go)
	local mresult = mconnector.execute("SERVER.GETPROPERTIES", uri)
	
	--local body = jsonStringify(mresult)
  	local body = json.encode(mresult)
  	res.headers = {
    	{ 'Content-Type', 'application/json' },
    	{ 'Content-Length', #body },
  	}
  	res.code = 200
  	res.body = body
end

return mclient