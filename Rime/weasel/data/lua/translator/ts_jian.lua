local tran
return {
 init=function(env)
  tran=Component.Translator(env.engine,"","table_translator@"..env.name_space)
 end,
 func=function(input,seg,env)
  if #env.engine.context.input~=1 then return end
  local query=tran:query(input,seg) if not query then return end
  local count=0
  for cand in query:iter() do
   yield(cand)
   count=count+1
   if count==12 then break end
  end
 end
}