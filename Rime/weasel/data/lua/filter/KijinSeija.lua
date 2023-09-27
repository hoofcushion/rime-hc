local string_sub <const> =string.sub
local utf8_offset <const> =utf8.offset
local utf8_sub <const> =function(str,start,final)
 local len_p <const> =#str+1
 if final then
  local i1 <const> =start<0 and len_p or 1
  local i2 <const> =final<0 and len_p or 1
  final=final+1
  start,final=utf8_offset(str,start,i1),utf8_offset(str,final,i2)
  final=final-1
  str=string_sub(str,start,final)
  return str
 end
 local i1 <const> =start<0 and len_p or 1
 start=utf8_offset(str,start,i1)
 str=string_sub(str,start)
 return str
end
local utf8_len <const> =utf8.len
local table_insert <const> =table.insert
local table_concat <const> =table.concat
local strReverse <const> =function(str)
 local result={}
 for i=utf8_len(str),1,-1 do
  table_insert(result,utf8_sub(str,i,i))
 end
 return table_concat(result)
end
local option_name
local filter <const> =
{
 init=function(env)
  local name <const> =env.name_space:match("^%*?(.*)$")
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
 end,
}
return filter