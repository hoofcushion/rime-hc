local Keytools <const> = require("keytools")
local M={}
local H={}
local function get_option_map(optionList)
 local optionMap={}
 for i=0,optionList.size-1 do
  local name <const> = optionList:get_at(i):get_map():get_value("name"):get_string()
  local text <const> = name:gsub("^fil_","")
  local auto_save <const> = H.switcher:is_auto_save(name)
  local optionMapEntry <const> = {text=text,option_name=name,auto_save=auto_save}
  if not optionMap[name] then optionMap[name]={} end
  table.insert(optionMap[name],optionMapEntry)
 end
 return optionMap
end
M.prosessor={}
---@return nil/
function M.prosessor.init(env)
 Keytools.key_map_initialize(env)
 H.switcher=Switcher(env.engine)
 H.symbol=env.engine.schema.config:get_string("recognizer/lua/"..env.name_space)
 H.code_start=#H.symbol+1
 H.optionMap=get_option_map(env.engine.schema.config:get_list("switches"))
end
---@return 0|1|2
function M.prosessor.func(key,env)
 local ctx <const> = env.engine.context
 local item <const> = H.optionMap[string.sub(ctx.input,H.code_start)]
 if not item then
  return 2
 end
 if not Keytools.move_true_index(key:repr(),env) then
  return 2
 end
 local cand <const> = seg:get_selected_candidate()
 local optionEntry <const> = item[tonumber(cand.type:match("index_(%d)"))]
 if not optionEntry then
  return 2
 end
 local name <const> = optionEntry.option_name
 local target_state <const> = not env.engine.context:get_option(name)
 ctx:set_option(name,target_state)
 if optionEntry.auto_save then
  H.switcher.user_config:set_bool("var/option/"..name,target_state)
 end
 return 1
end
M.translator={}
---@return nil
function M.translator.func(_,seg,env)
 if not seg:has_tag(env.name_space) then
  return
 end
 tipsEnv(env,"〔选项切换〕",true)
 local code <const> = env.engine.context.input:sub(H.code_start)
 local item <const> = H.optionMap[code]
 if not item then
  return
 end
 for index,optionEntry in ipairs(item) do
  local state <const> = env.engine.context:get_option(optionEntry.option_name)
  local cand=Candidate("index_"..index,seg.start,seg._end,optionEntry.text,state and "开" or "关")
  cand.preedit=code
  cand.quality=8102
  yield(cand)
 end
end
return M