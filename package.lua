return {
  name = "lduboeuf/luvi-marc-ws",
  version = "0.0.2",
  private = true,
  dependencies = {
   	"luvit/require@1.2.0",
    "luvit/pretty-print",
    "lduboeuf/cjson@1.0.1",
    "luvit/json@1.0.0", --needed by weblit-static
  	"creationix/weblit-app@0.2.5-1",
  	"creationix/weblit-auto-headers@0.1.1",
    -- Serve static files from disk
    "creationix/weblit-static@0.3.0",
    -- In-memory caching of http responses
    "creationix/weblit-etag-cache@0.1.0",
    -- Basic logger to stdout
    "creationix/weblit-logger@0.1.0",

  }
}


