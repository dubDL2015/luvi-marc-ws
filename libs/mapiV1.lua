local push = table.insert
local concat = table.concat

--all commands for SERVER Object
local server_api = {
  "GETPROPERTIES",
  "GETAPI",
  "GETTASKS",
  "SHUTDOWN",
  "GETCONNECTED"
 }
 
local session_api = {
   "GETINSTANCES",
   "CLEAR",
   "GETPROPERTIES",
   "SETPROPERTIES",
   "CONTEXTTOINHIBITOR",
   "CONTEXTTOPROFILER",
   "INHIBITORTOCONTEXT",
   "PROFILERTOCONTEXT",
   "GETLASTDBINFO",
   "MARCSAVE",
   "MARCRELOAD",
   "MARCCLEAR",
   "MARCREBUILD",
   "MARCPUBLISH",
   "DOCTOCONTEXT",
   "CONTEXTTODOC",
   "STORE",
   "INDEX",
   "GETSPECTRUM",
   "SETSPECTRUM",
   "PREDICT",
   "STRINGTOCONTEXT",
   "CONTEXTTOSTRING",
   "CONTEXTTOCONTEXT"
}

local contexts_api = {
  "CLEAR",
  "GETPROPERTIES",
  "SETPROPERTIES",
  "NEW",
  "DUP",
  "SWAP",
  "ONTOP",
  "INTERSECTION",
  "UNION",
  "AMPLIFY",
  "SPLIT",
  "FETCH",
  "SORTBY",
  "APPLYSPECTRUM",
  "LEARN",
  "NORMALIZE"
}

local results_api = {
  "SET",
  "CLEAR",
  "GETPROPERTIES",
  "SETPROPERTIES",
  "NEW",
  "DUP",
  "SWAP",
  "ONTOP",
  "INTERSECTION",
  "UNION",
  "SELECTBY",
  "DELETEBY",
  "SORTBY",
  "UNIQUEBY",
  "SELECTTOTABLE",
  "FETCH",
  "NORMALIZE",
  "AMPLIFY"
}

--create a function that enable function to be called case insensitively
 local mt = {
  __index = function(t, k)
      k = k:upper()

    return rawget(t, k)
  end
}
 

local _api = {

  SERVER = {},
  SESSION = {},
  CONTEXTS = {},
  TABLE = {},
  RESULTS = {}

}

setmetatable( _api.SERVER, mt )
setmetatable( _api.SESSION, mt )
setmetatable( _api.CONTEXTS, mt )
setmetatable( _api.TABLE, mt )
setmetatable( _api.RESULTS, mt )

local function encode(object, command, ...)
  local q =  { }
  push(q,object.."."..command.." (")
  for i,v in ipairs {...} do

    if i > 1 then 
      push(q," , ")
    end

    push(q," <"..#v..' '..v.."/> ")


  end

  
  push(q," ) ; ")
  return concat(q)

end


local function loadCommands (commands_list, tbl_dest, object_name)
  for i, method in ipairs(commands_list) do
    tbl_dest[method] = function(...) 
      return encode(object_name, method, ...)
    end
  end
end

loadCommands(server_api, _api.SERVER,"SERVER")
loadCommands(session_api, _api.SESSION, "SESSION")
loadCommands(contexts_api, _api.CONTEXTS,"CONTEXTS")
loadCommands(results_api, _api.RESULTS,"RESULTS")



return _api