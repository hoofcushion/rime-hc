local Reverse
local str2zmcode <const> =function(str)
 local result={}
 for i=1,utf8.len(str) do
  table.insert(result,Reverse:lookup(utf8.sub(str,i,i)):match("^%S+"))
 end
 return table.concat(result," ")
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
return
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