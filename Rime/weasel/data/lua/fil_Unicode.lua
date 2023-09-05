local function strUincode(str)
 local result={}
 for i=1,utf8.len(str) do
  table.insert(result,string.format("0x%x",utf8.codepoint(utf8.sub(str,i,i))))
 end
 return table.concat(result," ")
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
   cand.preedit=strUincode(cand.preedit)
   yield(ShadowCandidate(cand,strUincode(cand.type),strUincode(cand.text),strUincode(cand.comment)))
  end
 end
}