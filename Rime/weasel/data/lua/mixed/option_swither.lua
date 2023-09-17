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
local optionMap={
 emoji={{text="Emoji",option_name="fil_emoji"}}
}
return
{
 {
  init=keyMapInitialize,
  func=function(key,env)
   local ctx=env.engine.context
   if not optionMap[ctx.input] then return 2 end
   local index=keyMap[key:repr()]
   if not index then return 2 end
   local seg=ctx.composition:back()
   if index>-1 then
    local page_size=env.engine.schema.page_size
    seg.selected_index=index+math.floor(seg.selected_index/page_size)*page_size
   end
   local cand=seg:get_selected_candidate()
   local optionEntry=optionMap[ctx.input][tonumber(cand.type:match("option_(%d)"))]
   if not optionEntry then return 2 end
   local state=env.engine.context:get_option(optionEntry.option_name)
   ctx:set_option(optionEntry.option_name,not state)
   ctx:clear()
   return 1
  end
 },
 function(input,seg,env)
  if not optionMap[input] then return 2 end
  tipsAdd(env,"〔选项切换〕")
  for index,optionEntry in ipairs(optionMap[input]) do
   local state=env.engine.context:get_option(optionEntry.option_name)
   local cand=Candidate("option_"..index,seg.start,seg._end,optionEntry.text,state and "开" or "关")
   cand.quality=8102
   yield(cand)
  end
 end
}