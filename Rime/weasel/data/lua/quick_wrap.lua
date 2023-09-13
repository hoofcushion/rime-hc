local select_mode=false
local keyMap={[48]=10,[49]=1,[50]=2,[51]=3,[52]=4,[53]=5,[54]=6,[55]=7,[56]=8,[57]=9,[65456]=10,[65457]=1,[65458]=2,[65459]=3,[65460]=4,[65461]=5,[65462]=6,[65463]=7,[65464]=8,[65465]=9,}
local function get_pos(str)
 local result_tab={[10]=#str}
 local position=0
 for sub in str:gmatch("[^ ]+") do
  position=position+#sub
  table.insert(result_tab,position)
 end
 return result_tab
end
return
{
 func=function(key,env)
  if key:release() then return 2 end
  local ctx=env.engine.context
  if not ctx:is_composing() then return 2 end
  if key.keycode==65508 then
   ctx.caret_pos=0
   ctx.caret_pos=#ctx.input
   select_mode=true
   tipsRep(env,"跳转模式")
   return 1
  end
  if not keyMap[key.keycode] then return 2 end
  if not select_mode then return 2 end
  select_mode=false
  local wrap_position=get_pos(ctx:get_script_text())[keyMap[key.keycode]]
  if wrap_position then
   ctx.caret_pos=wrap_position
  end
  tipsRep(env,"")
  return 1
 end
}