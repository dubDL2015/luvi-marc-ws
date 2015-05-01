exports.name = "dubld/mconnector"
exports.version = "0.0.1"
exports.dependencies = {
  "creationix/coro-tcp@1.0.5",
  "creationix/coro-wrapper@1.0.0"
}


local connect = require('coro-tcp').connect
local wrapper = require('coro-wrapper')
local concat = table.concat
local remove = table.remove
local tblinsert = table.insert
local strfind = string.find
local strsub = string.sub
local tonumber = tonumber
local strlength = string.len

local function _parse_result(str,current_pos)

  local marcResult = { }
  local pos = current_pos

  --header
  local s, sNbRows, sNbCols
  s, pos, sNbRows, sNbCols = strfind(str, "(%d+)%s(%d+)%s", pos)

  local nbRows = tonumber(sNbRows)
  local nbCols = tonumber(sNbCols)

  local cols = {}
  

  --columns definition
  for i = 1, nbCols do

    local typeCol, length, name

    s, pos, typeCol, length, name = strfind(str, "(%d+)%s(%d+)%s([a-zA-Z0-9_]+)%s", pos)

    cols[i] = { type = tonumber(typeCol), name = name }

  end

  local data = { }
  --parse values e.g <2 77/> <7 icecube/>
  for i = 1,  nbRows do

    local row = {}

    for j = 1, nbCols do
      
      local sNbByte
      s, pos, sNbByte = strfind(str, "<(%d+)%s",pos)
      local nbByte = tonumber(sNbByte)

      local val = nil

      if (nbByte>0) then
        val = strsub(str, pos, pos+ nbByte)
        pos = pos+nbByte
      end

      pos = pos+1 --just after value

      row[cols[j].name] = val

    end

    data[i] = row


  end

  marcResult.data = data


  return marcResult, pos

end


local function decoder(data)
  p(data)
  if not data then return end
   --start scanning after white space
  --p("in:"..data)
  local pos = strfind(data, "%s",1)
  if not pos then return end

  --header
  local ssessionUID, sIsOK, _
  _, pos, ssessionUID, sIsOK = strfind(data, "([a-zA-Z0-9_]+)%s(%d+)%s", pos)
  
   --initialize marc resultset
  local marc_rs = {sessionUID = ssessionUID,  isOK = tonumber(sIsOK)}

  if marc_rs.isOK==0 then
   marc_rs.error_msg = data
   return marc_rs
  end
  
  local resultset = { }

  repeat 
    local rs
    rs, pos = _parse_result(data,pos)
    tblinsert(resultset, rs)
    --marc_rs.resultset[#marc_rs+1], pos = _parse_result(data,pos)
    pos = strfind(data,"%d", pos) --we check for other result by finding next digit (nb of rows)
  until (not pos) --until no more datas (pos is nil)
  
  marc_rs.resultset =  resultset



  return marc_rs, ""
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
  if not res then error("Connection closed") end
 
  
  request = {
      "", --prepare place for header 
      res.sessionUID..' ',
      query.." ( );"
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