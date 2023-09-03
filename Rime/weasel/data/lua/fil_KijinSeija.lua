local function strReverse(str)
 local result={}
 for i=utf8.len(str),1,-1 do
  table.insert(result,utf8Sub(str,i,i))
 end
 return table.concat(result)
end
return function(input,env)
 if env.engine.context:get_option(env.name_space) then
  for cand in input:iter() do
   cand.preedit=strReverse(cand.preedit)
   yield(ShadowCandidate(cand,strReverse(cand.type),strReverse(cand.text),strReverse(cand.comment)))
  end
  return
 end
 for cand in input:iter() do
  yield(cand)
 end
end