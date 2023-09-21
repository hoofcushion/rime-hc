local tran
return
{
 init=function(env) tran=Component.Translator(env.engine,"","script_translator@"..env.name_space); end,
 func=function(input,seg)
  local query <const> =tran:query(input,seg)
  if not query then return; end
  for cand in query:iter() do
   local cmt=cand.comment
   cand.comment=""
   if cand.type=="sentence" then
    local cmtjq=string.gsub(string.gsub(string.gsub(cmt,"[A-Z] "," "),"[A-Z]|","|"),"[A-Z]］","］")
    yield(ShadowCandidate(cand,"fancha",cmt:gsub("|['`][A-Z]+",""),"【左手全码】"))
    yield(ShadowCandidate(cand,"fancha",cmt:gsub("['`][A-Z]+|",""),"【右手全码】"))
    yield(ShadowCandidate(cand,"",cand.text:gsub(" $",""),""))
    yield(ShadowCandidate(cand,"fancha",cmt:gsub('"',""),"【左右全码】"))
    yield(ShadowCandidate(cand,"fancha",cmtjq:gsub("|['`][A-Z]+",""),"【左手简拼】"))
    yield(ShadowCandidate(cand,"fancha",cmtjq:gsub("['`][A-Z]+|",""),"【右手简拼】"))
   else
    if cmt:find("|") then
     yield(ShadowCandidate(cand,"fancha",cmt:gsub("|.+","]"),cand.text))
     yield(ShadowCandidate(cand,"fancha",cmt:gsub(".+|","["),cand.text))
    else
     yield(ShadowCandidate(cand,"fancha",cmt,cand.text:gsub(" $","")))
    end
   end
  end
 end,
}