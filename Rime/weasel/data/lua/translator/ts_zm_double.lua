local tran
return {
 init=function(env)
  tran=Component.Translator(env.engine,"","script_translator@"..env.name_space)
 end,
 func=function(input,seg,env)
  local query=tran:query(input,seg) if not query then return end
  local count=0
  for cand in query:iter() do
   yield(cand)
   count=count+1
   if count==60 then break end
  end
 end
}