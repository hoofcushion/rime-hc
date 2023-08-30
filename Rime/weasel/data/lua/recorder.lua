local chineseUnicodeRanges = {
 {min=0x04e00,max=0x09fff},
 {min=0x03400,max=0x04dbf},
 {min=0x20000,max=0x2a6df},
 {min=0x2a700,max=0x2b73f},
 {min=0x2b740,max=0x2b81f},
 {min=0x2b820,max=0x2ceaf},
 {min=0x2ceb0,max=0x2ebef},
 {min=0x30000,max=0x3134f},
 {min=0x31350,max=0x323af},
 {min=0x031c0,max=0x031ef},
 {min=0x02e80,max=0x02eff},
 {min=0x02f00,max=0x02fdf},
 {min=0x0f900,max=0x0fadf},
 {min=0x2f800,max=0x2fa1f},
 {min=0x02ff0,max=0x02fff},
 {min=0x03100,max=0x0312f},
 {min=0x031a0,max=0x031bf},
}
local function isPureChinese(str)
 for i=1,utf8Len(str) do
  local charCode=utf8.codepoint(utf8Sub(str,1,1))
  for _,range in pairs(chineseUnicodeRanges) do
   if charCode>=range.min and charCode<=range.max then
    return true
   end
  end
 end
 return false
end
local append_new_line=function(lct)
 local path
 if utf8.len(lct)==1 then 
  path=rime_api:get_user_data_dir().."/recorder/char.txt"
 else
  path=rime_api:get_user_data_dir().."/recorder/recorder.txt"
 end
 local file=io.open(path,"r") or io.open(path,"w"):close() and io.open(path,"r")
 if not file then return end
 local lines={[0]=lct.."\t1"}
 for line in file:lines() do
  local v=line:match("^"..lct.."\t(%d+)$")
  if v then
   lines[0]=lct.."\t"..1+v
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
  commit_notifier=env.engine.context.commit_notifier:connect(
  function(ctx)
   local lct=ctx:get_commit_text()
   if isPureChinese(lct) then
    append_new_line(lct)
   end
  end)
 end,
 func=function()
 end,
 fini=function()
  commit_notifier:disconnect()
 end
}