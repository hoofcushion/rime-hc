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

local Reverse
local utf8_len <const> =utf8.len
local table_insert <const> =table.insert
local table_concat <const> =table.concat
local string_match=string.match
local str2zmcode <const> =function(str)
 local result={}
 for i=1,utf8_len(str) do
  table_insert(result,string_match(Reverse:lookup(utf8_sub(str,i,i)),"^%S+"))
 end
 return table_concat(result," ")
end
local two <const> =function(str)
 local result={}
 for sub in str:gmatch("%S+") do
  if #sub>2 then
   sub=sub:gsub("^(..).+$","%1")
  else
   sub=sub:gsub("^.$","%1%1")
  end
  table.insert(result,sub)
 end
 return table.concat(result," ")
end
local tran
local translator <const> =
{
 init=function(env)
  tran=Component.Translator(env.engine,"","script_translator@"..env.name_space)
  Reverse=ReverseLookup(env.engine.schema.config:get_string("translator/dictionary"))
 end,
 func=function(input,seg)
  local query <const> =tran:query(input,seg)
  if not query then return; end
  local fst=true
  for cand in query:iter() do
   yield(ShadowCandidate(cand,"fancha",str2zmcode(cand.text),cand.text))
   if fst then
    yield(ShadowCandidate(cand,"fancha",two(str2zmcode(cand.text)),cand.text))
    fst=false
   end
  end
 end,
}
return translator