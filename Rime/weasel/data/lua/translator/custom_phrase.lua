local tran
return
{
 init=function(env) tran=Component.Translator(env.engine,"","table_translator@custom_phrase") end,
 func=function(input,seg)
  local query=tran:query(input,seg) if not query then return end
  for cand in query:iter() do
   cand.comment="『自定义』"
   yield(cand)
  end
 end
}