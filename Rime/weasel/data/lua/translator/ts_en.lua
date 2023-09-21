local function auto_uppercase(input,text)
 if input:find("^[A-Z][A-Z]") then
  return text:upper()
 end
 return text:gsub("^(.)",string.upper)
end
local tran
local fmain=function(input,seg)
 local query <const> =tran:query(input:lower(),seg)
 if not query then return; end
 local count=0
 for cand in query:iter() do
  if input:find("^[A-Z]") then
   yield(ShadowCandidate(cand,"",auto_uppercase(input,cand.text),""))
  else
   yield(cand)
  end
  count=count+1
  if count>60 then return; end
 end
end
local fmodule=function(input,seg)
 if #input==1 then return; end
 local query <const> =tran:query(input:lower(),seg)
 if not query then return; end
 local count=0
 for cand in query:iter() do
  cand.quality=cand.quality-0.0625
  if input:find("^[A-Z]") then
   yield(ShadowCandidate(cand,"",auto_uppercase(input,cand.text),""))
  else
   yield(cand)
  end
  count=count+5/(#cand.text+5)
  if count>1 then return; end
 end
end
local module
local func
return
{
 init=function(env)
  module=env.name_space~="translator"
  tran=Component.Translator(env.engine,"","table_translator@"..env.name_space)
  func=module and fmodule or fmain
 end,
 func=function(input,seg)
  func(input,seg)
 end,
}