local function strReverse(str)
 local result={}
 for i=utf8.len(str),1,-1 do
  table.insert(result,utf8Sub(str,i,i))
 end
 return table.concat(result)
end
local opction_name
return{
 init=function(env)
  local name=env.name_space:match("^%*?(.*)$")
  opction_name=env.engine.schema.config:get_string(name.."/opction_name") or name
 end,
 tags_match=function(seg,env)
  return env.engine.context:get_option(opction_name)
 end,
 func=function(input,env)
  for cand in input:iter() do
   cand.preedit=strReverse(cand.preedit)
   yield(ShadowCandidate(cand,strReverse(cand.type),strReverse(cand.text),strReverse(cand.comment)))
  end
 end
}