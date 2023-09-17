local keyMap={['space']=-1,['0']=9,['1']=0,['2']=1,['3']=2,['4']=3,['5']=4,['6']=5,['7']=6,['8']=7,['9']=8}
local function keyMapInitialize(env)
 local select_keys=env.engine.schema.select_keys
 if select_keys and select_keys~="" then
  keyMap={['space']=-1}
  local count=0
  for substr in select_keys:gmatch(".") do
   keyMap[substr]=count
   count=count+1
  end
 end
end
local filter
local option_name
return
{
 init=function(env)
  keyMapInitialize(env)
  local name=env.name_space:match("^%*?(.*)$")
  filter=Opencc(env.engine.schema.config:get_string(name.."/opencc_config"))
  option_name=env.engine.schema.config:get_string(name.."/option_name")
 end,
 func=function(key,env)
  local ctx=env.engine.context
  if ctx:has_menu() and ctx:get_option(option_name) then
   local index=keyMap[key:repr()]
   if not index then
    return 2
   end
   local seg=ctx.composition:back()
   if index>-1 then
    local page_size=env.engine.schema.page_size
    seg.selected_index=index+math.floor(seg.selected_index/page_size)*page_size
   end
   if seg:get_selected_candidate()._end~=#ctx.input then
    return 2
   end
   env.engine:commit_text(filter:convert_text(ctx:get_commit_text()))
   ctx:clear()
   return 1
  end
  return 2
 end
}