local tran
return
{
 init=function(env)
  tran=Component.Translator(env.engine,"","script_translator@"..env.name_space)
 end,
 func=function(input,seg,env)
  local query=tran:query(input,seg) if not query then return end
  for cand in query:iter() do
   local cmt=cand.comment
   cand.comment=""
   if cand.type~="sentence" then
    yield(ShadowCandidate(cand,"fancha",cmt,cand.text:sub(1,-2)))
   else
    yield(ShadowCandidate(cand,"fancha",cmt,""))
   end
  end
 end
}
