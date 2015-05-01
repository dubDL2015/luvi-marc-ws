local mconnector = require('mconnector')
local jsonStringify = require('json').stringify

local mclient = {}

local uri = { host = "127.0.0.1", port = 1254 }


function mclient.getProperties(req, res, go)
	local mresult = mconnector.execute("SERVER.GETPROPERTIES", uri)
	
	local body = jsonStringify(mresult)

  	res.headers = {
    	{ 'Content-Type', 'application/json' },
    	{ 'Content-Length', #body },
  	}
  	res.code = 200
  	res.body = body
end

return mclient