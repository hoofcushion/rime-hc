local string_sub <const> =string.sub
local utf8_offset <const> =utf8.offset
local utf8_sub <const> =function(str,start,final)
 local len_p <const> =#str+1
 if final then
  local i1 <const> =start<0 and len_p or 1
  local i2 <const> =final<0 and len_p or 1
  final=final+1
  start,final=utf8_offset(str,start,i1),utf8_offset(str,final,i2)
  final=final-1
  str=string_sub(str,start,final)
  return str
 end
 local i1 <const> =start<0 and len_p or 1
 start=utf8_offset(str,start,i1)
 str=string_sub(str,start)
 return str
end
local rangeMinimum <const> =11904
local rangeMaximum <const> =205743
local rangeMap <const> =
{
 {rangeMinimum,12031},
 {12032,       12255},
 {12272,       12287},
 {12544,       12591},
 {12704,       12735},
 {12736,       12783},
 {13312,       19903},
 {19968,       40959},
 {63744,       64223},
 {131072,      173791},
 {173824,      177983},
 {177984,      178207},
 {178208,      183983},
 {183984,      191471},
 {194560,      195103},
 {196608,      201551},
 {201552,      rangeMaximum},
}
local binarySearch <const> =function(rangeMap,uCode)
 local left,right=1,#rangeMap
 while left<=right do
  local mid <const> =(left+right)//2
  local range <const> =rangeMap[mid]
  local min <const> =range[1]
  local max <const> =range[2]
  if uCode>=min and uCode<=max then
   return true
  end
  if uCode<min then
   right=mid-1
  elseif uCode>max then
   left=mid+1
  end
 end
 return false
end
local string_match=string.match
local utf8_len <const> =utf8.len
local utf8_codepoint <const> =utf8.codepoint
local isPureChinese <const> =function(str)
 if str=="" then
  return false
 end
 for i=1,utf8_len(str) do
  local uCode=utf8_codepoint(utf8_sub(str,i,i))
  if uCode>=rangeMinimum and uCode<=rangeMaximum and binarySearch(rangeMap,uCode) then
   return true
  end
 end
 return false
end
local saveRecord <const> =function(lct,path)
 local file=io.open(path,"r") or io.open(path,"w"):close() and io.open(path,"r")
 if not file then
  return
 end
 local lines={[0]=lct.."\t1"}
 for line in file:lines() do
  local v=string_match(line,"^"..lct.."\t(%d+)$")
  if v then
   lines[0]=lct.."\t"..tostring(1+tonumber(v))
  else
   table.insert(lines,line)
  end
 end
 file:close()
 file=io.open(path,"w")
 for i=0,#lines do
  file:write(lines[i].."\n")
 end
 file:close()
end
local filenamelist <const> ={}
do
 local start <const> =user.."/recorder/"
 table.insert(filenamelist,start.."recorder_characters.txt")
 table.insert(filenamelist,start.."recorder_words.txt")
 table.insert(filenamelist,start.."recorder_others.txt")
end
local commit_notifier
local processor <const> =
{
 init=function(env)
  commit_notifier=env.engine.context.commit_notifier:connect(function(ctx)
   local lct=ctx:get_commit_text()
   if isPureChinese(lct) then
    if utf8_len(lct)==1 then
     saveRecord(lct,filenamelist[1])
    else
     saveRecord(lct,filenamelist[2])
    end
   else
    saveRecord(lct,filenamelist[3])
   end
  end)
 end,
 func=function()
  return 2
 end,
 fini=function()
  commit_notifier:disconnect()
 end,
}
return processor