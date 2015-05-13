return {
  name = "dubld/luvi-marc-ws",
  version = "0.0.1",
  dependencies = {
   	"luvit/require@1.2.0",
    "luvit/pretty-print",
    "luvit/json",
    "lduboeuf/cjson@1.0.1",
    "luvit/querystring@1.0.0",
    "creationix/hybrid-fs@0.1.0",
  	"creationix/weblit-app@0.2.3",
  	"creationix/weblit-auto-headers@0.1.1",
    -- Serve static files from disk
    "creationix/weblit-static@0.3.0",
    -- In-memory caching of http responses
    "creationix/weblit-etag-cache@0.1.0",
    -- Basic logger to stdout
    "creationix/weblit-logger@0.1.0",
    --"dubld/socket-pool@0.0.1",
  }
}
