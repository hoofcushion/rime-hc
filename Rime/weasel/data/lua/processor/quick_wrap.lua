local wrap_mode=false
local keyMap <const> =
{
 ["0"]=10,
 ["1"]=1,
 ["2"]=2,
 ["3"]=3,
 ["4"]=4,
 ["5"]=5,
 ["6"]=6,
 ["7"]=7,
 ["8"]=8,
 ["9"]=9,
 ["KP_0"]=10,
 ["KP_1"]=1,
 ["KP_2"]=2,
 ["KP_3"]=3,
 ["KP_4"]=4,
 ["KP_5"]=5,
 ["KP_6"]=6,
 ["KP_7"]=7,
 ["KP_8"]=8,
 ["KP_9"]=9,
}
local get_pos <const> =function(script_text,rank)
 local result_tab <const> ={[10]=#script_text}
 local position=0
 for sub in script_text:gmatch("[^ ]+") do
  position=position+#sub
  table.insert(result_tab,position)
 end
 return result_tab[rank] or result_tab[10]
end
return
{
 func=function(key,env)
  if not env.engine.context:has_menu() then return 2; end
  local keyName <const> =key:repr()
  local ctx <const> =env.engine.context
  if wrap_mode and keyMap[keyName] then
   wrap_mode=false
   ctx.caret_pos=get_pos(ctx:get_script_text(),keyMap[keyName])
   tipsRep(env,"跳转完毕")
  elseif keyName=="Control+Control_R" then
   wrap_mode=true
   ctx.caret_pos=0
   ctx.caret_pos=#ctx.input
   tipsRep(env,"跳转模式")
  else
   return 2
  end
  return 1
 end,
}