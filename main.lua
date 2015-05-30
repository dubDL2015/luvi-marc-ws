local pathJoin = require('luvi').path.join
local static = require('weblit-static')
local mclient = require('mclient')
local env = require('env')

--load config file
--luvi luvi-marc-ws/ -- `pwd`/luvi-marc-ws/config.lua
if (#args==0) then error("config file is required, usage: luvi app -- /absolute/path/to/my/config.lua\n e.g: luvi luvi-marc-ws/ -- `pwd`/luvi-marc-ws/config.lua") end

local conf = require(args[1])
if (type(conf) ~= "table") then
  error(args[1].." config file must be a table")
end

mclient.setConfig(conf)

p("load app with config:",conf)
p("for first test: curl -L http://127.0.0.1:8080/knowledges/patent/")


local function auth(req)
  local token = req.headers["M-API-TOKEN"]
  if not token then
       --todo proper http response
    error("unauthorized")
    return false
  end
  return true
end


require('weblit-app')

  .bind({host = "0.0.0.0", port = env.get("PORT") or 8080})

  -- Configure weblit server
  .use(require('weblit-logger'))
  .use(require('weblit-auto-headers'))
  .use(require('weblit-etag-cache'))


  .use(static(pathJoin(module.dir, "static")))

   --TODO chain  

  --[[
    token protected area TODO
  ]]
  -- .use(
  --   function (req, res, go)
  --     local token = req.headers["M-API-TOKEN"]
  --     if not token then
  --       --todo proper http response
  --       error("unauthorized")
  --     end
  --     go()

  --   end)

  .route({ method = "GET", path = "/knowledges/:knw_name/" }, mclient.getProperties)
  .route({ method = "GET", path = "/knowledges/:knw_name/resources/" }, mclient.getResources)
.use(
    function (req, res, go)
      p("here")

    end)
 
  .start()


require('uv').run()

