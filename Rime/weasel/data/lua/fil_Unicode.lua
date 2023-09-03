local function strUincode(str)
 local result={}
 for i=1,utf8.len(str) do
  table.insert(result,string.format("0x%x",utf8.codepoint(utf8Sub(str,i,i))))
 end
 return table.concat(result," ")
end
return function(input,env)
 if env.engine.context:get_option(env.name_space) then
  for cand in input:iter() do
   cand.preedit=strUincode(cand.preedit)
   yield(ShadowCandidate(cand,strUincode(cand.type),strUincode(cand.text),strUincode(cand.comment)))
  end
  return
 end
 for cand in input:iter() do
  yield(cand)
 end
end