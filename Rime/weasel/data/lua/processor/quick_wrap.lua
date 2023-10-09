local keyMap <const> =
{
 [48]=10, -- [0]
 [49]=1,  -- [1]
 [50]=2,  -- [2]
 [51]=3,  -- [3]
 [52]=4,  -- [4]
 [53]=5,  -- [5]
 [54]=6,  -- [6]
 [55]=7,  -- [7]
 [56]=8,  -- [8]
 [57]=9,  -- [9]
}
local get_pos <const> =function(script_text,rank)
 local result_tab <const> ={}
 local position=0
 for sub in script_text:gmatch("[^ ]+") do
  position=position+#sub
  table.insert(result_tab,position)
 end
 return result_tab[rank] or #script_text
end
local wrap_mode=false
local Actions <const> ={
 [0]={
  [0]=function(ctx)
   wrap_mode=true
   ctx.caret_pos=0
   ctx.caret_pos=#ctx.input
   tipsCtx(ctx,"跳转模式")
   return 1
  end,
 },
 [1]={
  [0]=function(ctx)
   wrap_mode=false
   tipsCtx(ctx,"跳转关闭")
   return 1
  end,
  [1]=function(ctx,keyValue)
   wrap_mode=false
   if keyValue~=10 then
    ctx.caret_pos=get_pos(ctx:get_script_text(),keyValue)
   end
   tipsCtx(ctx,"跳转完毕")
   return 1
  end,
  [2]=function(ctx)
   wrap_mode=false
   return 2
  end,
 },
}
for i=1,127 do
 print(i,string.char(i))
end
local start_key
local processor <const> =
{
 init=function(env)
  start_key=env.engine.schema.config:get_string(env.name_space)
 end,
 func=function(key,env)
  if key:release() then
   return 2
  end
  local ctx <const> =env.engine.context
  if not ctx:has_menu() then
   wrap_mode=false
   return 2
  end
  local keyValue <const> =keyMap[key.keycode]
  local keyName <const> =key:repr()
  local a=wrap_mode and 1 or 0
  local b=
   keyName==start_key and 0
   or keyValue and 1
   or 2
  local action=Actions[a][b]
  if action then
   return action(ctx,keyValue)
  end
  return 2
 end,
}
return processor