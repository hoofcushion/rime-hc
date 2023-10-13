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
local keyMapInitialize <const> =function(env)
 local select_keys=env.engine.schema.select_keys
 if select_keys and select_keys~="" then
  keyMap={["space"]=-1}
  local count=0
  for substr in select_keys:gmatch(".") do
   keyMap[substr]=count
   count=count+1
  end
 end
end
local symbol
local prefix_len
local processor <const> =
{
 init=function(env)
  keyMapInitialize(env)
  symbol=env.engine.schema.config:get_string("recognizer/lua/"..env.name_space)
  prefix_len=#symbol
 end,
 func=function(key,env)
  local ctx <const> =env.engine.context
  if ctx:has_menu() then
   local index <const> =keyMap[key:repr()]
   if not index then
    return 2
   end
   local seg <const> =ctx.composition:back()
   if index>-1 then
    local page_size <const> =env.engine.schema.page_size
    seg.selected_index=index+math.floor(seg.selected_index/page_size)*page_size
   end
   local cand <const> =seg:get_selected_candidate()
   if cand.type=="fancha" then
    local ctxlen <const> =#ctx.input
    local result=cand.text:gsub("[^%a;]",""):lower()
    if cand._end~=ctxlen then
     result=result..symbol
     if seg._end==ctxlen then
      result=result..ctx.input:sub(cand._end+1)
     end
    end
    ctx:pop_input(prefix_len+seg.length)
    ctx:push_input(result)
    ctx.caret_pos=#ctx.input
    return 1
   end
  end
  return 2
 end,
}
return processor