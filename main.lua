local pathJoin = require('luvi').path.join
local static = require('weblit-static')
local mclient = require('mclient')
local env = require('env')

--load config file
--luvi luvi-marc-ws/ -- `pwd`/luvi-marc-ws/config.lua
if (#args==0) then error("config file is required: luvi app -- /absolute/path/to/my/config.lua") end

local conf = require(args[1])
if (type(conf) ~= "table") then
  error(args[1].." config file must be a table")
end

mclient.setConfig(conf)

p("load app with config:",conf)


require('weblit-app')

  .bind({host = "0.0.0.0", port = env.get("PORT") or 8080})

  -- Configure weblit server
  .use(require('weblit-logger'))
  .use(require('weblit-auto-headers'))
  .use(require('weblit-etag-cache'))

  -- Serve non-blog content pages
  .route({ method = "GET", path = "/knowledges/:knw_name/" }, mclient.getProperties)
  .route({ method = "GET", path = "/knowledges/:knw_name/resources/" }, mclient.getResources)

  .use(static(pathJoin(module.dir, "static")))

  .start()

  require('uv').run()

