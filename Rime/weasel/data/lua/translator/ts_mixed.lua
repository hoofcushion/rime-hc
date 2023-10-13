local limit <const> =60
local pinyin
local zhengma
local actions <const> =
{
 function(input,seg,query)
  local cand_count=0
  for cand in query[1]:iter() do
   yield(cand)
   cand_count=cand_count+1
   if cand_count>=limit then
    return
   end
  end
 end,
 function(input,seg,query)
  local cand_count=0
  for cand in query[2]:iter() do
   yield(cand)
   cand_count=cand_count+1
   if cand_count>=limit then
    return
   end
  end
 end,
 function(input,seg,query)
  local cand_count=0
  local count=0
  for cand in query[2]:iter() do
   yield(cand)
   count=count+1
   if count==3 then
    break
   end
  end
  cand_count=cand_count+count
  count=0
  for cand in query[1]:iter() do
   yield(cand)
   count=count+1
   if count==3 then
    break
   end
  end
  cand_count=cand_count+count
  for cand in query[2]:iter() do
   yield(cand)
   cand_count=cand_count+1
   if cand_count>=limit then
    return
   end
  end
  for cand in query[1]:iter() do
   yield(cand)
   cand_count=cand_count+1
   if cand_count>=limit then
    return
   end
  end
 end,
}
local translator <const> =
{
 init=function(env)
  pinyin=Component.Translator(env.engine,"","script_translator@ts_cn")
  zhengma=Component.Translator(env.engine,"","table_translator@"..env.name_space)
 end,
 func=function(input,seg,env)
  if #env.engine.context.input>4 then
   local query <const> =pinyin:query(input,seg)
   if not query then
    return
   end
   local cand_count=0
   for cand in query:iter() do
    yield(cand)
    cand_count=cand_count+1
    if cand_count>=limit then
     return
    end
   end
   return
  end
  local query={}
  table.insert(query,pinyin:query(input,seg))
  table.insert(query,zhengma:query(input,seg))
  if query[1] or query[2] then
   actions[(query[1] and 1 or 0)+(query[2] and 2 or 0)](input,seg,query)
  end
 end,
}
return translator