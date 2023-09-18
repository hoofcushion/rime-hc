local batchDir=user..Sep.."build"..Sep.."run.bat" --获取 batch 路径

io.open(batchDir,"w"):close() --清空 batch 命令

local batchCmd='"'..batchDir..'"'

local cmdMap=dofile(exist("custom_command.txt"))
for name,item in pairs(cmdMap) do
 for index,cmdEntry in ipairs(item) do
  if cmdEntry.batch then
   cmdMap[name][index].command='"'..cmdEntry.command..'"'
  end
 end
end

local keyMap={
 ["Return"]="send",
 ["KP_Enter"]="send",
 ["Tab"]="rotate",
 ["BackSpace"]="cancel"
}

local sendCommand,command

local symbol,code_start

local cplMap={}

local get_cpl=function(code)
 if #cplMap==0 then--命令未完整且 cplMap 长度为零则重新获取 cplMap 补全列表
  for name in pairs(cmdMap) do
   if name~=code and name:find("^"..code) then
    table.insert(cplMap,name)
   end
  end
  table.sort(cplMap,function(a,b) return #a>#b end)
  table.insert(cplMap,1,code)
 end
end

local Action={
 send=function(ctx,code)
  if not cmdMap[code] then return 2 end
  local index=tonumber(ctx:get_selected_candidate().type)
  if not index then return 2 end
  local cmdEntry=cmdMap[code][index]
  if not cmdEntry then return 2 end
  if cmdEntry.batch then
   io.open(batchDir,"w"):write(string.gsub('chcp 65001\nif exist S (start "" S)','S',cmdEntry.command)):close()
   command=batchCmd
  else
   command=cmdEntry.command
  end
  sendCommand=true
  ctx:clear()
  return 1
 end,

 rotate=function(ctx,code)
  get_cpl(code)
  ctx:clear()
  ctx:push_input(symbol..cplMap[#cplMap])
  table.remove(cplMap,#cplMap)
  return 1
 end,

 cancel=function(ctx)
  if #cplMap==0 then return 2 end
  ctx:clear()
  ctx:push_input(symbol..cplMap[1])
  cplMap={}
  return 1
 end,
}

local processor={
 init=function(env)
  symbol=env.engine.schema.config:get_string("recognizer/lua/"..env.name_space)
  code_start=#symbol+1
 end,

 func=function(key,env)
  if key:release() then
   if not sendCommand then return 2 end
   sendCommand=false
   os.execute(command)--os.execute 会导致lua暂停,因此用 sendCommand 变量指示在键 Release 时执行
   return 1
  end

  local ctx=env.engine.context
  if not ctx.input:find("^"..symbol) then
   cplMap={}
   return 2
  end

  local action_type=keyMap[key:repr()]
  if not action_type then return 2 end

  local code=ctx.input:sub(code_start)
  return Action[action_type](ctx,code)
 end
}

local translator=function(_,seg,env)
 if not seg:has_tag(env.name_space) then return end
 tipsAdd(env,"〔命令行〕")

 local input=env.engine.context.input
 local code=input:sub(code_start)
 if not cmdMap[code] then return end

 for index,cmdEntry in ipairs(cmdMap[code]) do
  local cand=Candidate(index,seg.start,seg._end,cmdEntry.text,cmdEntry.comment or "快速启动")
  cand.quality=8102
  yield(cand)
 end
end
return {processor,translator}