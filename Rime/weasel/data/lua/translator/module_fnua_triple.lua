local tran
return {
 init=function(env) tran=Component.Translator(env.engine,"","script_translator@"..env.name_space) end,
 func=function(input,seg,env)
  local query=tran:query(input,seg) if not query then return end
  for cand in query:iter() do
   local comment=cand.comment
   cand.comment=""
   if cand.type=="sentence" then
    local commentjq=string.gsub(string.gsub(string.gsub(comment,"[A-Z] "," "),"[A-Z]|","|"),"[A-Z]］","］")
    yield(ShadowCandidate(cand,"fancha",comment:gsub("|['`][A-Z]+",""),"【左手全码】"))
    yield(ShadowCandidate(cand,"fancha",comment:gsub("['`][A-Z]+|",""),"【右手全码】"))
    yield(ShadowCandidate(cand,"",cand.text:gsub(" $",""),""))
    yield(ShadowCandidate(cand,"fancha",comment:gsub('"',""),"【左右全码】"))
    yield(ShadowCandidate(cand,"fancha",commentjq:gsub("|['`][A-Z]+",""),"【左手简拼】"))
    yield(ShadowCandidate(cand,"fancha",commentjq:gsub("['`][A-Z]+|",""),"【右手简拼】"))
   else
    yield(ShadowCandidate(cand,"fancha",comment,cand.text:gsub(" $","")))
   end
  end
 end
}