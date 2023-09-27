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
 local select_keys <const> =env.engine.schema.select_keys
 if select_keys and select_keys~="" then
  keyMap={["space"]=-1}
  local count=0
  for substr in select_keys:gmatch(".") do
   keyMap[substr]=count
   count=count+1
  end
 end
end
local insert <const> =function(map,index,entry)
 if not map[index] then map[index]={}; end
 table.insert(map[index],entry)
end
local switcher
local optionMap={}
local symbol
local code_start
local prosessor <const> =
{
 init=function(env)
  keyMapInitialize(env)
  switcher=Switcher(env.engine)
  symbol=env.engine.schema.config:get_string("recognizer/lua/"..env.name_space)
  code_start=#symbol+1
  local optionList <const> =env.engine.schema.config:get_list("switches")
  for i=0,optionList.size-1 do
   local name <const> =optionList:get_at(i):get_map():get_value("name"):get_string()
   local text <const> =name:gsub("^fil_","")
   local code <const> =text:gsub("[^%a]",""):gsub("%u",string.lower)
   local auto_save <const> =switcher:is_auto_save(name)
   local optionMapEntry={text=text,option_name=name,auto_save=auto_save}
   insert(optionMap,name,optionMapEntry)
   insert(optionMap,code,optionMapEntry)
  end
 end,
 func=function(key,env)
  local ctx <const> =env.engine.context
  local item <const> =optionMap[ctx.input:sub(code_start)]
  if not item then return 2; end
  local index <const> =keyMap[key:repr()]
  if not index then return 2; end
  local seg <const> =ctx.composition:back()
  if index>-1 then
   local page_size <const> =env.engine.schema.page_size
   seg.selected_index=index+math.floor(seg.selected_index/page_size)*page_size
  end
  local cand <const> =seg:get_selected_candidate()
  local optionEntry <const> =item[tonumber(cand.type:match("index_(%d)"))]
  if not optionEntry then return 2; end
  local name <const> =optionEntry.option_name
  local target_state <const> =not env.engine.context:get_option(name)
  ctx:set_option(name,target_state)
  if optionEntry.auto_save then
   switcher.user_config:set_bool("var/option/"..name,target_state)
  end
  return 1
 end,
}
local translator <const> =
{
 func=function(_,seg,env)
  if not seg:has_tag(env.name_space) then return; end
  tipsAdd(env,"〔选项切换〕")
  local code <const> =env.engine.context.input:sub(code_start)
  local item <const> =optionMap[code]
  if not item then return; end
  for index,optionEntry in ipairs(item) do
   local state <const> =env.engine.context:get_option(optionEntry.option_name)
   local cand=Candidate("index_"..index,seg.start,seg._end,optionEntry.text,state and "开" or "关")
   cand.preedit=code
   cand.quality=8102
   yield(cand)
  end
 end,
}
return {prosessor,translator}