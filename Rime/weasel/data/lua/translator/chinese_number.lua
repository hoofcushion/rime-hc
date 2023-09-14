local map=
{
 ["upper"]=
 {
  ["unit"]=
  {[0]="零","壹","贰","叁","肆","伍","陆","柒","捌","玖"},
  ["magnitude"]=
  {[0]="","拾","佰","仟"},
  ["quatermag"]=
  {[0]="","万","亿","兆","京","垓","秭","穰","沟","涧","正","载","极"},
  ["decimag"]=
  {"角","分","厘","毫"},
 },
 ["lower"]=
 {
  ["unit"]=
  {[0]="〇","一","二","三","四","五","六","七","八","九"},
  ["magnitude"]=
  {[0]="","十","百","千"},
  ["quatermag"]=
  {[0]="","万","亿","兆","京","垓","秭","穰","沟","涧","正","载","极"},
  ["decimag"]=
  {"角","分","厘","毫"},
 }
}
map.intMax=#map.upper.quatermag*#map.upper.unit

local function tranInteger(str,style)
 local len=#str
 if len==1 then
  return style.unit[tonumber(str)]
 end
 local result={}
 local after,mag=false,false
 for i=1,len do
  local digit=tonumber(str:sub(i,i))
  if digit~=0 then
   if after then
    table.insert(result,style.unit[0])
    after=false
   end
   if not mag then
    mag=true
   end
   table.insert(result,style.unit[digit])
   table.insert(result,style.magnitude[(len-i)%4])
  else
   after=true
  end
  if mag and (len-i)%4==0 then
   table.insert(result,style.quatermag[(len-i+1)//4])
   mag=false
  end
 end
 return table.concat(result)
end
local function tranDecimal(str,style,money)
 local result={}
 if not money then
  for i=1,#str do
   local digit=tonumber(str:sub(i,i))
   table.insert(result,style.unit[digit])
  end
  return table.concat(result)
 end
 local before,after=false,false
 local len=math.min(#str,#style.decimag)
 for i=1,len do
  local digit=tonumber(str:sub(i,i))
  if digit~=0 then
   if before and after then
    table.insert(result,style.unit[0])
    after=false
    before=false
   end
   table.insert(result,style.unit[digit])
   table.insert(result,style.decimag[i])
   after=true
  else
   before=true
  end
 end
 return table.concat(result)
end
local function numberSep(partInteger,partDecimal,money)
 return
  partDecimal and
  (money and "元"   or "点") or
  (money and "元整" or  "" )
end
local characterizer=function(str,map,mode)
 local style=map[mode%2==1 and "upper" or "lower"]
 local money=(mode+1)%4<=1
 local partInteger=str:match("^(%d+)")
 local partDecimal=str:match("%.(%d+)$")
 local result={}
 if not (partInteger=="0" and money and partDecimal)  then --金额模式整数为0时 不转换整数部分
  table.insert(result,tranInteger(partInteger,style))
  table.insert(result,numberSep(partInteger,partDecimal,money))
 end
 if partDecimal then
  table.insert(result,tranDecimal(partDecimal,style,money))
 end
 return table.concat(result)
end
local comments={
 "大写数字",
 "小写数字",
 "大写金额",
 "小写金额",
}
local symbol
local code_start
-- function dubug(code)
--  for i=1,4 do
--   print(characterizer(code,map,i))
--  end
-- end
-- dubug("0.010101010")
return
{
 init=function(env)
  symbol=env.engine.schema.config:get_string("recognizer/lua/"..env.name_space)
  code_start=#symbol+1
 end,
 func=function(input,seg,env)
  if not seg:has_tag(env.name_space) then return end
  local code=input:sub(code_start)
  if code=="" then
   tipsAdd(env,"〔请输入数字〕")
   return
  elseif not (code:find("^%d+$") or code:find("^%d-%.%d*$")) then
   tipsAdd(env,"〔数字不合法〕")
   return
  elseif #code:match("^(%d+)")>map.intMax then
   tipsAdd(env,"〔位数超过限制〕")
   return
  end
  tipsAdd(env,"〔大写数字〕")
  for i=1,4 do
   local text=characterizer(code,map,i)
   if text then
    yield(Candidate("uppder_num",seg.start,seg._end,text,comments[i]))
   end
  end
 end
}