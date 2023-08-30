local function auto_uppercase(input,cand)
 if input:find("^[A-Z][A-Z]")
  then return cand.text:upper()
 end
 return cand.text:gsub("^(.)",string.upper)
end
local module
local tran
return {
 init=function(env)
  module=env.engine.schema.config:get_map("module_en")
  tran=Component.Translator(env.engine,"","table_translator@"..(module and "module_en" or "translator"))
 end,
 func=function(input,seg)
  if module and #input==1 then return end
  local query=tran:query(input:lower(),seg) if not query then return end
  local count=0
  for cand in query:iter() do
   if input:find("^[A-Z]") then
    yield(ShadowCandidate(cand,cand.type,auto_uppercase(input,cand),cand.comment))
   else
    yield(cand)
   end
   if module then
    count=count+5/(#cand.text+5)
    if count>1 then return end
   else
    count=count+1
    if count>100 then return end
   end
  end
 end
}