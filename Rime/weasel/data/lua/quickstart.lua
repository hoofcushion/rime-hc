local commandMap=dofile(exist("custom_command.txt"))
for k, v in pairs(commandMap) do
 for i=1, #v do
  if v[i][3] then
   commandMap[k][i][1]='"'..commandMap[k][i][1]..'"'
  end
 end
end

local batchDir=user..Sep.."build"..Sep.."run.bat" --获取 batch 路径
io.open(batchDir,"w+"):close() --清空 batch 命令

local keyMap={
 ["Return"]="Enter",
 ["KP_Enter"]="Enter",
 ["Tab"]="Tab",
 ["BackSpace"]="BackSpace",
}

local sendCommand,command
local completionMap={}
local symbol,code_start
return
{
 {
  init=function(env)
   symbol=env.engine.schema.config:get_string("recognizer/lua/quickstart")
   code_start=#symbol+1
  end,
  func=function(key,env)
   if sendCommand then
    sendCommand=false
    os.execute(command)--os.execute 会导致lua暂停,因此用 sendCommand 变量指示在键 Release 时执行
    return 0
   end
   local ctx=env.engine.context
   local input=ctx.input
   if input=="" then
    completionMap={}
    return 2
   end
   local keyEvent=key:repr()
   if not keyMap[keyEvent] then return 2 end--键不合法则直接Return
   local code=input:sub(code_start)
   if commandMap[code] and keyMap[keyEvent]=="Enter" then--命令正确的情况下按回车则执行命令
    local index=tonumber(ctx:get_selected_candidate().type:match(": (%d+)"))
    if not index then return 2 end
    sendCommand=true
    local commandEntry=commandMap[code][index]
    if commandEntry[3] then
     local batchCode=string.gsub('chcp 65001\nif exist S (start "" S)','S',commandEntry[1])
     io.open(batchDir,"w+"):write(batchCode):close()
     command='"'..batchDir..'"'
    else
     command=commandEntry[1]
    end
    ctx:clear()
    return 1
   end
   if input:find("^"..symbol) then--命令未完整进入补全状态
    if #completionMap==0 then--命令未完整且 completionMap 长度为零则重新获取 completionMap 补全列表
     for k, v in pairs(commandMap) do
      if k:find("^"..code..".") then
       table.insert(completionMap,k)
      end
     end
     table.sort(completionMap,function(a,b) return #a>#b end)
     table.insert(completionMap,1,code)
    end
    if keyMap[keyEvent]=="Tab" then--补全状态按 Tab 可以在 completionMap 列表中循环
     ctx:pop_input(#code)
     ctx:push_input(completionMap[#completionMap])
     table.remove(completionMap,#completionMap)
     return 1
    end
    if keyMap[keyEvent]=="BackSpace" and code~=completionMap[1] then--补全状态按 BackSpace 会退出补全状态并归还编码
     ctx:pop_input(#code)
     ctx:push_input(completionMap[1])
     completionMap={}
     return 1
    end
    completionMap={}
   end
   return 2
  end
 }
 ,
 function(_,seg,env)
  if not seg:has_tag("quickstart") then return end
  tips(env,"〔命令行〕")
  local input=env.engine.context.input
  local code=input:sub(code_start)
  if code=="" then
   local cand=Candidate(env.name_space,seg.start,seg._end,symbol,"Tab补全")
   cand.quality=8102
   yield(cand)
  end
  if commandMap[code] then
   for i=1, #commandMap[code] do
    local cand=Candidate(env.name_space..": "..i,seg.start,seg._end,commandMap[code][i][2],"快速启动")
    cand.quality=8102
    yield(cand)
   end
  end
 end
}
