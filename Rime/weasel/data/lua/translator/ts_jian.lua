local tran;
local quality;
return
{
 init=function(env)
  mem=Memory(env.engine,Schema(env.name_space),"translator");
  quality=env.engine.schema.config:get_int(env.name_space.."/initial_quality") or 1;
 end,
 func=function(input,seg)
  if seg._end~=1 then return; end;
  mem:dict_lookup(input,false,1);
  local count=0;
  for entry in mem:iter_dict() do
   local cand <const> =Candidate("jian",seg.start,seg._end,entry.text,"");
   cand.quality=quality;
   yield(cand);
   count=count+1;
   if count==30 then break; end;
  end;
 end,
};