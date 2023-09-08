local tran
return
{
 init=function(env) tran=Component.Translator(env.engine,"","script_translator@module_cn_en") end,
 func=function(input,seg)
  local query=tran:query(input,seg) if not query then return end
  for cand in query:iter() do
   if cand.type=="sentence" then return end
   cand.comment="『混输』"
   yield(cand)
  end
 end
}