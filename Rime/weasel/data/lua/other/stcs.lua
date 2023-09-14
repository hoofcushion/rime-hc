local filter,option_name
local keyMap={[32]=-1,[49]=0,[50]=1,[51]=2,[52]=3,[53]=4,[54]=5,[55]=6,[56]=7,[57]=8,[48]=9,[65457]=0,[65458]=1,[65459]=2,[65460]=3,[65461]=4,[65462]=5,[65463]=6,[65464]=7,[65465]=8,[65456]=9,}
return {
 init=function(env)
  local name=env.name_space:match("^%*?(.*)$")
  filter=Opencc(env.engine.schema.config:get_string(name.."/opencc_config"))
  option_name=env.engine.schema.config:get_string(name.."/option_name")
 end,
 func=function(key,env)
  if not env.engine.context:has_menu() then return 2 end
  if not keyMap[key.keycode] then return 2 end
  if not env.engine.context:get_option(option_name) then return 2 end
  local ctx,index=env.engine.context,keyMap[key.keycode]
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