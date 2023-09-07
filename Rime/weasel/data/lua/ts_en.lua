local function auto_uppercase(input,text)
 if input:find("^[A-Z][A-Z]") then
  return text:upper()
 end
 return text:gsub("^(.)",string.upper)
end
local module
local tran
local fmain=function(input,seg)
 local query=tran:query(input:lower(),seg) if not query then return end
 local count=0
 for cand in query:iter() do
  if input:find("^[A-Z]") then
   yield(ShadowCandidate(cand,nil,auto_uppercase(input,cand.text),nil))
  else
   yield(cand)
  end
  count=count+1
  if count>60 then return end
 end
end
local fmodule=function(input,seg)
 if #input==1 then return end
 local query=tran:query(input:lower(),seg) if not query then return end
 local count=0
 for cand in query:iter() do
  if input:find("^[A-Z]") then
   yield(ShadowCandidate(cand,nil,auto_uppercase(input,cand.text),nil))
  else
   yield(cand)
  end
  count=count+5/(#cand.text+5)
  if count>1 then return end
 end
end
return {
 init=function(env)
  module=env.engine.schema.config:get_map("module_en")
  tran=Component.Translator(env.engine,"","table_translator@"..(module and "module_en" or "translator"))
 end,
 func=(module and fmodule or fmain)
}