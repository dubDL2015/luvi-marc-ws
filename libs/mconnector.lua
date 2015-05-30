-- exports.name = "lduboeuf/mconnector"
-- exports.version = "0.0.1"
-- exports.dependencies = {
--   "creationix/coro-tcp@1.0.5",
--   "creationix/coro-wrapper@1.0.0"
-- }


local connect = require('coro-tcp').connect
local wrapper = require('coro-wrapper')
local concat = table.concat
local remove = table.remove
local strfind = string.find
local strsub = string.sub
local tonumber = tonumber
local strlength = string.len
local strmatch = string.gmatch



local function decode_header(data, pos)

  local _, pos, ssessionUID, sIsOK = strfind(data, "([a-zA-Z0-9_]+)%s(%d+)%s", pos)

   --initialize marc resultset
  return {sessionUID = ssessionUID,  isOK = tonumber(sIsOK)}, pos
end

local function decode_table_size(data,pos)
    
  local _, pos, sNbRows, sNbCols = strfind(data, "(%d+)%s(%d+)%s", pos)

  return tonumber(sNbRows), tonumber(sNbCols), pos

end




local function decode_columns_header(data, pos, nb_cols)
  --columns definition
    local cols = {}
  
    for i = 1, nb_cols do
      local  _, typeCol, length, name
       _, pos, typeCol, length, name = strfind(data, "(%d+)%s(%d+)%s([a-zA-Z0-9_]+)%s", pos)

      cols[i] = { mtype = tonumber(typeCol), name = name }

    end

    return cols, pos
end


local function decode_datas(data, pos, nbRows, cols)

  local rs = { }
  local sNbByte, nbByte, val, _
  --parse values e.g <2 77/> <7 icecube/>
  for i = 1,  nbRows do

      local row = {}

      for j = 1, #cols do

        _, pos, sNbByte = strfind(data, "<(%d+)%s",pos)
        nbByte = tonumber(sNbByte)

        if (nbByte > 0) then
          val = strsub(data, pos, pos + nbByte)
          pos = pos + nbByte
        end

        pos = pos + 1 --just after value

        row[cols[j].name] = val

      end

    rs[i] = row
  end
  p(rs)
  return rs, pos
end

--TODO handle streaming
local function decoder(data)

  if not data then return end
   --start scanning after white space
  --p("in:"..data)
  local pos = strfind(data, "%s",1)
  if not pos then return end

  local marc_rs

  marc_rs, pos = decode_header(data, pos)
  --handle errors
  if marc_rs.isOK==0 then
   marc_rs.error_msg = data
   return marc_rs
  end

  local resultset = { }

  repeat
    local rs = {}

    local nb_rows, nb_cols
    nb_rows, nb_cols, pos = decode_table_size(data, pos)
    

    local cols
    cols, pos = decode_columns_header(data, pos, nb_cols)
    rs.data , pos = decode_datas(data, pos, nb_rows, cols)

    resultset[#resultset + 1] = rs
    
    pos = strfind(data,"%d", pos) --we check for other result by finding next digit (nb of rows)
  until (not pos) --until no more datas (pos is nil)
  
  marc_rs.resultset =  resultset

  return marc_rs, ''

end


  
local function encoder(req)
    local length = 0
    --calculate length TODO should be directly compute when inserting new request ?
    for _,v in ipairs(req) do 
      length = length + #v
    end
  
    --header
    req[1] = "#"..strlength(length).."#"..length..' '
    --p("out:"..concat(req))

    return concat(req)
end



local sessions = {}
local connections = {} 
--TODO limit number of connections & timeout
local function getConnection(host, port, timeout)
	for i = #connections, 1, -1 do
    local connection = connections[i]
    if connection.host == host and connection.port == port  then
      remove(connections, i)
      -- Make sure the connection is still alive before reusing it.
      if not connection.socket:is_closing() and connection.socket:is_active() then
       -- p("reused connection"..#connections)
        return connection
      end
    end
  end
  local read, write, socket = assert(connect(host, port))
 
  return {
    socket = socket,
    host = host,
    port = port,
    read = wrapper.reader(read, decoder),
    write = wrapper.writer(write, encoder)
  }
end



local function save(connection)
  if connection.socket:is_closing() then return end
  connections[#connections + 1] = connection
end

function exports.execute(query, options)
  --get connection from pool
  local connection = getConnection(options.host, options.port)
  local read = connection.read
  local write = connection.write

  local request = {
      "", --prepare place for header 
      "-1"..' ', --fake sessionUID for connect
      "CONNECT (NULL);"
   }


  write(request)

  local res = read()
  if not res then error("Unable to connecto to:",options.host..':'..options.port) end
 
  
  request = {
      "", --prepare place for header 
      res.sessionUID..' ',
      concat(query)
   }



  write(request)
  
  res = read()
   if not res then error("Connection closed") end
  

  --if res.keepAlive then
  save(connection)

  return res
  
  --else
  --  write()
  --end

end