exports.name = "dubld/socket-pool"
exports.version = "0.0.1"
exports.dependencies = {
  "creationix/coro-tcp@1.0.5",
  "creationix/coro-wrapper@1.0.0"
}


local connect = require('coro-tcp').connect
local remove = table.remove



local connections = {} 
local function connect(host, port, timeout)
	for i = #connections, 1, -1 do
    local connection = connections[i]
    if connection.host == host and connection.port == port  then
      remove(connections, i)
      -- Make sure the connection is still alive before reusing it.
      if not connection.socket:is_closing() and connection.socket:is_active() then
        return connection
      end
    end
end
exports.connect = connect


local function save(connection)
  if connection.socket:is_closing() then return end
  connections[#connections + 1] = connection
end
exports.save = save

function exports.request(request, options)
  
  local connection = connect(options.hostname, options.port)
  local read = connection.read
  local write = connection.write

    save(connection)
  
end