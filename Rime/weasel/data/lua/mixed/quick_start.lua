local BATCH_DIR <const> =user..Sep.."build"..Sep.."run.bat"
local DIRECT_CMD <const> ="start /b cmd /c "
local BATCH_CMD <const> ='start "'..BATCH_DIR..'" '
io.open(BATCH_DIR,"w")
 :write('@echo off\nchcp 65001\nif exist "%1" (start "" "%1")')
 :close() --清空 batch 命令
local commandMap=dofile(exist("custom_command.txt"))
for commandName,commandItem in pairs(commandMap) do
 for commandIndex,commandEntry in ipairs(commandItem) do
  if commandEntry.batch then
   commandMap[commandName][commandIndex].command='"'..commandEntry.command..'"'
  end
 end
end
local completionList={}
local ascendByStringLength_CodePoint <const> =function(string_a,string_b)
 local strLen_a <const> =#string_a
 local strLen_b <const> =#string_b
 if strLen_a~=strLen_b then
  return strLen_a>strLen_b
 else
  return string_a>string_b
 end
end
local getCompletionList <const> =function(inputCode)
 if #completionList==0 then
  for commandName in pairs(commandMap) do
   local findPattern <const> ="^"..inputCode.."."
   if string.find(commandName,findPattern) then
    completionList[#completionList+1]=commandName
   end
  end
  table.sort(completionList,ascendByStringLength_CodePoint)
  table.insert(completionList,1,inputCode)
 end
end
local sendCommandSignal,executeCommand
local startPrompt,codeBeginning
local KEY_MAP <const> =
{
 ["Return"]="send",
 ["KP_Enter"]="send",
 ["Tab"]="rotate",
 ["BackSpace"]="cancel",
}
local ACTION_MAP <const> =
{
 send=function(context,inputCode)
  local commandItem <const> =commandMap[inputCode]
  if not commandItem then
   return 2
  end
  local currentCandidate <const> =context:get_selected_candidate()
  local commandIndex <const> =tonumber(currentCandidate.type)
  if not commandIndex then
   return 2
  end
  local commandEntry <const> =commandItem[commandIndex]
  if not commandEntry then
   return 2
  end
  if commandEntry.batch then
   executeCommand=BATCH_CMD..commandEntry.command
  else
   executeCommand=DIRECT_CMD..commandEntry.command
  end
  sendCommandSignal=true
  context.input=""
  return 1
 end,
 rotate=function(context,inputCode)
  getCompletionList(inputCode)
  local completionListSize <const> =#completionList
  context.input=startPrompt..completionList[completionListSize]
  completionList[completionListSize]=nil
  return 1
 end,
 cancel=function(context)
  if #completionList==0 then
   return 2
  end
  context.input=startPrompt..completionList[1]
  completionList={}
  return 1
 end,
}
local prosessor <const> =
{
 init=function(env)
  startPrompt=env.engine.schema.config:get_string("recognizer/lua/"..env.name_space)
  codeBeginning=#startPrompt+1
 end,
 func=function(key,env)
  if key:release() then
   if sendCommandSignal then
    sendCommandSignal=false
    os.execute(executeCommand) --os.execute 会导致lua暂停,因此用 sendCommandSignal 变量指示在键 Release 时再 os.execute
    return 1
   end
   return 2
  end
  local context <const> =env.engine.context
  local contextInput <const> =context.input
  if not string.find(contextInput,"^"..startPrompt) then
   completionList={}
   return 2
  end
  local keyEvent <const> =KEY_MAP[key:repr()]
  if not keyEvent then
   return 2
  end
  local inputCode <const> =string.sub(contextInput,codeBeginning)
  return ACTION_MAP[keyEvent](context,inputCode)
 end,
}
local translatorTagName
local translator <const> =
{
 init=function(env)
  translatorTagName=env.name_space
 end,
 func=function(input,seg,env)
  if not seg:has_tag(translatorTagName) then
   return
  end
  local context <const> =env.engine.context
  local contextInput <const> =context.input
  local inputCode <const> =string.sub(contextInput,codeBeginning)
  tipsEnv(env,"〔命令行〕")
  if not commandMap[inputCode] then
   return
  end
  for commandIndex,commandEntry in ipairs(commandMap[inputCode]) do
   local text <const> =commandEntry.text
   local comment <const> =commandEntry.comment or "快速启动"
   local cand <const> =Candidate(commandIndex,seg.start,seg._end,text,comment)
   cand.quality=8102
   yield(cand)
  end
 end,
}
return {prosessor,translator}