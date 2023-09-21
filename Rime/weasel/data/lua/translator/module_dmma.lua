local tran
return
{
 init=function(env) tran=Component.Translator(env.engine,"","script_translator@"..env.name_space); end,
 func=function(input,seg)
  if seg.length~=4 or input:find("%u") then return; end
  local query <const> =tran:query(input:lower(),seg)
  if not query then return; end
  local count=0
  for cand in query:iter() do
   cand.comment="「"..cand.comment:sub(-3,-2):upper().."」"
   cand.quality=cand.quality-0.125
   yield(cand)
   count=count+1
   if count==3 then break; end
  end
 end,
}