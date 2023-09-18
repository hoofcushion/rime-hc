local rangeMap={
  min=11904,max=205743,
 {min=11904,max=12031},
 {min=12032,max=12255},
 {min=12272,max=12287},
 {min=12544,max=12591},
 {min=12704,max=12735},
 {min=12736,max=12783},
 {min=13312,max=19903},
 {min=19968,max=40959},
 {min=63744,max=64223},
 {min=131072,max=173791},
 {min=173824,max=177983},
 {min=177984,max=178207},
 {min=178208,max=183983},
 {min=183984,max=191471},
 {min=194560,max=195103},
 {min=196608,max=201551},
 {min=201552,max=205743},
}
local function isPureChinese(str)
 for i=1,utf8.len(str) do
  local uCode=utf8.codepoint(utf8.sub(str,i,i))
  if uCode<rangeMap.min or uCode>rangeMap.max then return false end
  for _,range in ipairs(rangeMap) do
   if uCode<range.min and uCode>range.max then return false end
  end
 end
 return true
end
local function saveRecord(lct,filename)
 local path=user.."/recorder/"..filename
 local file=io.open(path,"r") or io.open(path,"w"):close() and io.open(path,"r")
 if not file then return end
 local lines={[0]=lct.."\t1"}
 for line in file:lines() do
  local v=line:match("^"..lct.."\t(%d+)$")
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
local commit_notifier
return {
 init=function(env)
  commit_notifier=env.engine.context.commit_notifier:connect(function(ctx)
   local lct=ctx:get_commit_text()
   local filename
   if isPureChinese(lct) then
    if utf8.len(lct)==1 then
     filename="recorder_characters.txt"
    else
     filename="recorder_words.txt"
    end
   else
    filename="recorder_others.txt"
   end
   saveRecord(lct,filename)
  end)
 end,
 func=function()
  return 2
 end,
 fini=function()
  commit_notifier:disconnect()
 end
}