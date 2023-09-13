local cmdMap=dofile(exist("custom_command.txt"))
for k, v in pairs(cmdMap) do
 for i=1, #v do
  if v[i][3] then
   cmdMap[k][i][1]='"'..cmdMap[k][i][1]..'"'
  end
 end
end

local batchDir=user..Sep.."build"..Sep.."run.bat" --获取 batch 路径
io.open(batchDir,"w"):close() --清空 batch 命令
local batchCmd='"'..batchDir..'"'

local cplMap={}
local keyMap={
 ["Return"]="Enter",
 ["KP_Enter"]="Enter",
 ["Tab"]="Tab",
 ["BackSpace"]="BackSpace",
}

local sendCommand,command
local symbol,code_start
return
{
 {
  init=function(env)
   symbol=env.engine.schema.config:get_string("recognizer/lua/quickstart")
   code_start=#symbol+1
  end,
  func=function(key,env)
   if key:release() then
    if sendCommand then
     sendCommand=false
     os.execute(command)--os.execute 会导致lua暂停,因此用 sendCommand 变量指示在键 Release 时执行
     return 0
    end
    return 2
   end
   local ctx=env.engine.context
   if not ctx:is_composing() then
    cplMap={}
    return 2
   end
   local keyName=keyMap[key:repr()]
   if not keyName then return 2 end--键不合法则直接Return
   local input=ctx.input
   if not input:find("^"..symbol) then return 2 end
   local code=input:sub(code_start)
   if keyName=="Enter" then
    if not cmdMap[code] then return 2 end
    local index=tonumber(ctx:get_selected_candidate().type)
    if not index then return 2 end
    local cmdEntry=cmdMap[code][index]
    if not cmdEntry then return 2 end
    if cmdEntry[3] then
     io.open(batchDir,"w"):write(string.gsub('chcp 65001\nif exist S (start "" S)','S',cmdEntry[1])):close()
     command=batchCmd
    else
     command=cmdEntry[1]
    end
    sendCommand=true
    ctx:clear()
    return 1
   else
    if #cplMap==0 then--命令未完整且 cplMap 长度为零则重新获取 cplMap 补全列表
     for name in pairs(cmdMap) do
      if name~=code and name:find("^"..code) then
       table.insert(cplMap,name)
      end
     end
     table.sort(cplMap,function(a,b) return #a>#b end)
     table.insert(cplMap,1,code)
    end
    if keyName=="Tab" then--补全状态按 Tab 可以在 cplMap 列表中循环
     ctx:clear()
     ctx:push_input(symbol..cplMap[#cplMap])
     table.remove(cplMap,#cplMap)
     return 1
    elseif keyName=="BackSpace" then--补全状态按 BackSpace 会退出补全状态并归还编码
     if code==cplMap[1] then cplMap={} return 2 end
     ctx:pop_input(#code)
     ctx:push_input(cplMap[1])
     cplMap={}
     return 1
    end
   end
  end
 }
 ,
 function(_,seg,env)
  if not seg:has_tag("quickstart") then return end
  tipsAdd(env,"〔命令行〕")
  local input=env.engine.context.input
  local code=input:sub(code_start)
  if code=="" then
   local cand=Candidate("",seg.start,seg._end,symbol,"Tab补全")
   cand.quality=8102
   yield(cand)
  end
  if cmdMap[code] then
   for i=1,#cmdMap[code] do
    local cand=Candidate(i,seg.start,seg._end,cmdMap[code][i][2],"快速启动")
    cand.quality=8102
    yield(cand)
   end
  end
 end
}
