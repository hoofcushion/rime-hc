-- 来自https://github.com/baopaau/rime-lua-collection
-- 没有许可信息
-- 做了一部分修改
bmi=function(centimeter,kilogram) --BMI 指数计算器
 return kilogram*10000/centimeter^2 .." kg/m²"
end
hoai=function(year,month,day) --我几岁？ How old am I? 输入年月日，计算距今多少年
 if
 type(day)~="number" or day<1 or
 type(month)~="number" or month<1 or
 type(year)~="number" or year<1970
 then
  return
 end
 day=tostring(day)
 month=tostring(month)
 year=tostring(year)
 local time_now <const> =os.time()
 local time_then <const> =os.time({year=year,month=month,day=day})
 return (time_now-time_then)/31556925.445
end
cos=math.cos
sin=math.sin
tan=math.tan
acos=math.acos
asin=math.asin
atan=math.atan
rad=math.rad
deg=math.deg
abs=math.abs
floor=math.floor
ceil=math.ceil
mod=math.fmod
gcd=function(a,b) --接收两个数字
 a,b=b,a%b
 return b~=0 and gcd(a,b) or a
end --返回最大公约数
trunc=function(x,dc)
 if dc==nil then
  return math.modf(x)
 end
 return x-mod(x,dc)
end
round=function(x,dc)
 dc=dc or 1
 local dif <const> =mod(x,dc)
 if abs(dif)>dc/2 then
  return x<0 and x-dif-dc or x-dif+dc
 end
 return x-dif
end
random=math.random
randomseed=math.randomseed
inf=math.huge
MAX_INT=math.maxinteger
MIN_INT=math.mininteger
pi=math.pi
sqrt=math.sqrt
root=function(x,y)
 return x^(1/y)
end
exp=math.exp
e=exp(1)
ln=math.log
log=function(x,base)
 base=base or 10
 return ln(x)/ln(base)
end
min=function(arr)
 local m=inf
 for k,x in ipairs(arr) do
  m=x<m and x or m
 end
 return m
end
max=function(arr)
 local m=-inf
 for k,x in ipairs(arr) do
  m=x>m and x or m
 end
 return m
end
sum=function(t)
 local acc=0
 for k,v in ipairs(t) do
  acc=acc+v
 end
 return acc
end
avg=function(t)
 return sum(t)/#t
end
isinteger=function(x)
 return math.fmod(x,1)==0
end
--iterator . array
array=function(...)
 local arr <const> ={}
 for v in ... do
  arr[#arr+1]=v
 end
 return arr
end
--iterator<-[form,to)
irange=function(from,to,step)
 if to==nil then
  to=from
  from=0
 end
 step=step or 1
 local i=from-step
 to=to-step
 return function()
  if i<to then
   i=i+step
   return i
  end
 end
end
--array<-[form,to)
range=function(from,to,step)
 return array(irange(from,to,step))
end
--array . reversed iterator
irev=function(arr)
 local i=#arr+1
 return function()
  if i>1 then
   i=i-1
   return arr[i]
  end
 end
end
--array . reversed array
arev=function(arr)
 return array(irev(arr))
end
test=function(f,t)
 for k,v in ipairs(t) do
  if not f(v) then
   return false
  end
 end
 return true
end
--# Functional
map=function(t,...)
 local ta <const> ={}
 for k,v in pairs(t) do
  local tmp=v
  for _,f in pairs({...}) do
   tmp=f(tmp)
  end
  ta[k]=tmp
 end
 return ta
end
filter=function(t,...)
 local ta <const> ={}
 local i=1
 for k,v in pairs(t) do
  local erase=false
  for _,f in pairs({...}) do
   if not f(v) then
    erase=true
    break
   end
  end
  if not erase then
   ta[i]=v
   i=i+1
  end
 end
 return ta
end
foldr=function(t,f,acc)
 for k,v in pairs(t) do
  acc=f(acc,v)
 end
 return acc
end
foldl=function(t,f,acc)
 for v in irev(t) do
  acc=f(acc,v)
 end
 return acc
end
chain=function(t)
 local ta=t
 local function cf(f,...)
  if f~=nil then
   ta=f(ta,...)
   return cf
  else
   return ta
  end
 end
 return cf
end
--# Statistics
fac=function(n)
 local acc=1
 for i=2,n do
  acc=acc*i
 end
 return acc
end
nPr=function(n,r)
 return fac(n)/fac(n-r)
end
nCr=function(n,r)
 return nPr(n,r)/fac(r)
end
MSE=function(t)
 local ss=0
 local s=0
 local n=#t
 for k,v in ipairs(t) do
  ss=ss+v*v
  s=s+v
 end
 return sqrt((n*ss-s*s)/(n*n))
end
--# Linear Algebra
--# Calculus
--Linear approximation
lapproxd=function(f,delta)
 local delta <const> =delta or 1e-8
 return function(x)
  return (f(x+delta)-f(x))/delta
 end
end
--Symmetric approximation
sapproxd=function(f,delta)
 local delta <const> =delta or 1e-8
 return function(x)
  return (f(x+delta)-f(x-delta))/delta/2
 end
end
--近似導數
deriv=function(f,delta,dc)
 dc=dc or 1e-4
 local fd <const> =sapproxd(f,delta)
 return function(x)
  return round(fd(x),dc)
 end
end
--Trapezoidal rule
trapzo=function(f,a,b,n)
 local dif <const> =b-a
 local acc=0
 for i=1,n-1 do
  acc=acc+f(a+dif*(i/n))
 end
 acc=acc*2+f(a)+f(b)
 acc=acc*dif/n/2
 return acc
end
--近似積分
integ=function(f,delta,dc)
 delta=delta or 1e-4
 dc=dc or 1e-4
 return function(a,b)
  if b==nil then
   b=a
   a=0
  end
  local n <const> =round(abs(b-a)/delta)
  return round(trapzo(f,a,b,n),dc)
 end
end
--Runge-Kutta
rk4=function(f,timestep)
 local timestep <const> =timestep or 0.01
 return function(start_x,start_y,time)
  local x=start_x
  local y=start_y
  local t <const> =time
  --loop until i>=t
  for i=0,t,timestep do
   local k1 <const> =f(x,y)
   local k2 <const> =f(x+(timestep/2),y+(timestep/2)*k1)
   local k3 <const> =f(x+(timestep/2),y+(timestep/2)*k2)
   local k4 <const> =f(x+timestep,y+timestep*k3)
   y=y+(timestep/6)*(k1+2*k2+2*k3+k4)
   x=x+timestep
  end
  return y
 end
end
date=os.date
time=os.time
path=function()
 return debug.getinfo(1).source:match("@?(.*/)")
end
local serialize <const> =function(obj)
 local type=type(obj)
 if type=="number" then
  return isinteger(obj) and floor(obj) or obj
 elseif type=="boolean" then
  return tostring(obj)
 elseif type=="string" then
  return '"'..obj..'"'
 elseif type=="table" then
  local str="{"
  local i=1
  for k,v in pairs(obj) do
   if i~=k then
    str=str.."["..serialize(k).."]="
   end
   str=str..serialize(v)..","
   i=i+1
  end
  str=str:len()>3 and str:sub(0,-3) or str
  return str.."}"
 elseif pcall(obj) then --function類型
  return "callable"
 end
 return obj
end
--greedy：隨時求值（每次變化都會求值，否則結尾爲特定字符時求值）
local greedy=true
local symbol
local code_start
local translator <const> =
{
 init=function(env)
  symbol=env.engine.schema.config:get_string("recognizer/lua/"..env.name_space)
  code_start=#symbol+1
 end,
 func=function(input,seg,env)
  if not seg:has_tag(env.name_space) then
   return
  end
  tipsEnv(env,"〔表达式〕",true)
  local expfin=greedy or input:find(";$")
  local exp=(greedy or not expfin) and input:sub(code_start) or input:sub(code_start,-2)
  --空格輸入可能
  exp=exp:gsub("#"," ")
  if exp=="" then
   return
  end
  yield(Candidate("number",seg.start,seg._end,exp,"表達式"))
  if not expfin then
   return
  end
  local expe=exp
  --鏈式調用語法糖
  expe=expe:gsub("%$"," chain ")
  --lambda語法糖
  do
   local count
   repeat
    expe,count=expe:gsub("\\%s*([%a%d%s,_]-)%s*%.(.-)|"," (function(%1) return%2 end) ")
   until count==0
  end
  --yield(Candidate("number",seg.start,seg._end,expe,"展開"))
  --防止危險操作，禁用os和io命名空間
  if expe:find("io%.") or expe:find("os%.") then
   yield(Candidate("number",seg.start,seg._end,"os和io命名空間被禁用",""))
   return
  end
  --return語句保證了只有合法的Lua表達式才可執行
  local result=expe:find("return ") and load(expe)() or load("return "..expe)()
  if result==nil then
   return
  end
  result=serialize(result)
  result=tostring(result)
  yield(Candidate("number",seg.start,seg._end,result,"值"))
  if result and (result:find("^'.*'$") or result:find("^\".*\"$")) then
   yield(Candidate("number",seg.start,seg._end,result:sub(2,-2),"无引号"))
  end
  yield(Candidate("number",seg.start,seg._end,exp.."="..result,"等式"))
 end,
}
return translator