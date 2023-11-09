local M={}
local keyMap=
{
 ["space"]=-1,
 ["0"]=9,
 ["1"]=0,
 ["2"]=1,
 ["3"]=2,
 ["4"]=3,
 ["5"]=4,
 ["6"]=5,
 ["7"]=6,
 ["8"]=7,
 ["9"]=8,
}
function M.move_true_index(key,env)
 local index <const> =keyMap[key]
 if not index then
  return false
 end
 local seg <const> = env.engine.context.composition:back()
 if index>-1 then
  local page_size <const> = env.engine.schema.page_size
  seg.selected_index=index+math.floor(seg.selected_index/page_size)*page_size
 end
 return true
end
function M.key_map_initialize(env)
 local select_keys <const> = env.engine.schema.select_keys
 if select_keys and select_keys~="" then
  keyMap={["space"]=-1}
  local count=0
  for substr in select_keys:gmatch(".") do
   keyMap[substr]=count
   count=count+1
  end
 end
end
return M