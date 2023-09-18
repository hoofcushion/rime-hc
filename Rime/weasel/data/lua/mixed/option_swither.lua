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
local function insert(map,index,entry)
 if not map[index] then map[index]={} end
 table.insert(map[index],entry)
end
local switcher
local optionMap={}
local symbol
local code_start
return
{
 {
  init=function(env)
   keyMapInitialize(env)
   switcher=Switcher(env.engine)
   symbol=env.engine.schema.config:get_string("recognizer/lua/"..env.name_space)
   code_start=#symbol+1
   local optionList=env.engine.schema.config:get_list("switches")
   for i=0,optionList.size-1 do
    local name=optionList:get_at(i):get_map():get_value("name"):get_string()
    local text=name:gsub("^fil_","")
    local code=text:gsub("[^%a]",""):gsub("%u",string.lower)
    local auto_save=switcher:is_auto_save(name)
    local optionMapEntry={text=text,option_name=name,auto_save=auto_save}
    insert(optionMap,name,optionMapEntry)
    insert(optionMap,code,optionMapEntry)
   end
  end,
  func=function(key,env)
   local ctx=env.engine.context
   local item=optionMap[ctx.input:sub(code_start)]
   if not item then return 2 end

   local index=keyMap[key:repr()]
   if not index then return 2 end
   local seg=ctx.composition:back()
   if index>-1 then
    local page_size=env.engine.schema.page_size
    seg.selected_index=index+math.floor(seg.selected_index/page_size)*page_size
   end

   local cand=seg:get_selected_candidate()

   local optionEntry=item[tonumber(cand.type:match("index_(%d)"))]
   if not optionEntry then return 2 end

   local name=optionEntry.option_name
   local target_state=not env.engine.context:get_option(name)

   ctx:set_option(name,target_state)

   if optionEntry.auto_save then
    switcher.user_config:set_bool("var/option/"..name,target_state)
   end
   return 1
  end
 },
 function(_,seg,env)
  if not seg:has_tag(env.name_space) then return end
  tipsAdd(env,"〔选项切换〕")

  local code=env.engine.context.input:sub(code_start)
  local item=optionMap[code]
  if not item then return end

  for index,optionEntry in ipairs(item) do
   local state=env.engine.context:get_option(optionEntry.option_name)
   local cand=Candidate("index_"..index,seg.start,seg._end,optionEntry.text,state and "开" or "关")
   cand.preedit=code
   cand.quality=8102
   yield(cand)
  end
 end
}