-- 来自 https://github.com/shewer/librime-lua-script/blob/main/lua/component/unicode.lua
-- 没有许可信息
-- 做了一部分修改
local symbol
local code_start
local baseMap={
 H={base=16,expattern="[^a-f0-9]",limit="110000"},
 D={base=10,expattern="[^0-9]"   ,limit="1114112"},
 O={base=8, expattern="[^0-7]"   ,limit="4200000"},
 B={base=2, expattern="[^1-2]"   ,limit="100010000000000000000"},
}
return
{
 init=function(env)
  symbol=env.engine.schema.config:get_string("recognizer/lua/unicode")
  code_start=#symbol+1
 end,
 func=function(_,seg,env)
  if not seg:has_tag("unicode") then return end
  local tip={"〔Unicode〕"}

  local code=env.engine.context.input:sub(code_start)
  if code=="" then
   tips(env,table.concat(tip))
   return
  end

  local sBase=code:match("^([HDOB])") or code:match("([HDOB])$") or "H"
  local Base=baseMap[sBase]
  local nBase=Base.base
  table.insert(tip,"〔"..nBase.." 进制〕")

  local sCode=code:match("([a-f0-9]+)")
  if not sCode then --如果没有超出 sCode,则提示
   tips(env,table.concat(tip))
   return
  elseif sCode:find(Base.expattern) then
   table.insert(tip,"〔进制错误〕")
   tips(env,table.concat(tip))
   return
  end

  local nCode=tonumber(sCode,nBase)
  if not nCode then
   table.insert(tip,"〔数值错误〕")
   tips(env,table.concat(tip))
   return
  end
  if nCode>1114112 then
   table.insert(tip,"〔超出范围: "..Base.limit.."〕")
   tips(env,table.concat(tip))
   return
  end
  for i=0,9 do
   local nCode=nCode+i
   if nCode>1114112 then
    return
   end
   local cand=Candidate("unicode",seg.start,seg._end,utf8.char(nCode),"0x"..nCode)
   cand.preedit=code
   yield(cand)
  end
  tips(env,table.concat(tip)) --如果没有超出编码范围,则提示
 end
}