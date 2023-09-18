local function strReverse(str)
 local result={}
 for i=utf8.len(str),1,-1 do
  table.insert(result,utf8.sub(str,i,i))
 end
 return table.concat(result)
end
local option_name
return
{
 init=function(env)
  local name=env.name_space:match("^%*?(.*)$")
  option_name=env.engine.schema.config:get_string(name.."/option_name") or name
 end,
 tags_match=function(seg,env)
  return env.engine.context:get_option(option_name)
 end,
 func=function(input)
  for cand in input:iter() do
   cand:get_genuine().preedit=strReverse(cand.preedit)
   yield(ShadowCandidate(cand,cand.type,strReverse(cand.text),strReverse(cand.comment)))
  end
 end
}