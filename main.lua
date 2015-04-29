local pathJoin = require('luvi').path.join
local static = require('weblit-static')
local mclient = require('mclient')
local env = require('env')

if type(module) == "function" then
  module = { dir = "bundle:" }
end

require('weblit-app')

  .bind({host = "0.0.0.0", port = env.get("PORT") or 8080})

  -- Configure weblit server
  .use(require('weblit-logger'))
  .use(require('weblit-auto-headers'))
  .use(require('weblit-etag-cache'))

  -- Serve non-blog content pages
  .route({ method = "GET", path = "/" }, mclient.getProperties)

  .use(static(pathJoin(module.dir, "static")))

  .start()

  require('uv').run()
