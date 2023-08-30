local tran
return{
 init=function(env) tran=Component.Translator(env.engine,"","table_translator@custom_cn_phrase") end,
 func=function(input,seg)
  local query=tran:query(input,seg) if not query then return end
  for cand in query:iter() do
   if cand.start~=0 then return end
   cand.type="custom_cn_phrase"
   yield(cand)
  end
 end
}