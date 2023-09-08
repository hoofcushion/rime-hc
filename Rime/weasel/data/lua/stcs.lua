local filter,option_name
local keyMap={["space"]=-1,["1"]=0,["2"]=1,["3"]=2,["4"]=3,["5"]=4,["6"]=5,["7"]=6,["8"]=7,["9"]=8,["0"]=9,["KP_1"]=0,["KP_2"]=1,["KP_3"]=2,["KP_4"]=3,["KP_5"]=4,["KP_6"]=5,["KP_7"]=6,["KP_8"]=7,["KP_9"]=8,["KP_0"]=9,}
return {
 init=function(env)
  local name=env.name_space:match("^%*?(.*)$")
  filter=Opencc(env.engine.schema.config:get_string(name.."/opencc_config"))
  option_name=env.engine.schema.config:get_string(name.."/option_name")
 end,
 func=function(key,env)
  if not env.engine.context:has_menu() then return 2 end
  if not keyMap[key:repr()] then return 2 end
  if not env.engine.context:get_option(option_name) then return 2 end
  local ctx,index=env.engine.context,keyMap[key:repr()]
  local seg=ctx.composition:back()
  if index~=-1 then
   local page_size=env.engine.schema.page_size
   seg.selected_index=math.floor(seg.selected_index/page_size)*page_size+index
  end
  if seg:get_selected_candidate()._end~=#ctx.input then return 2 end
  env.engine:commit_text(filter:convert_text(ctx:get_commit_text()))
  ctx:clear()
  return 1
 end
}