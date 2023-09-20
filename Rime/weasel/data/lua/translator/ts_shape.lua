local tran;
return
{
 init=function(env)
  tran=Component.Translator(env.engine,"","script_translator@"..env.name_space);
 end,
 func=function(input,seg,env)
  local query <const> =tran:query(input,seg);
  if not query then return; end;
  local last_len,text_len,dup=0,0,1;
  local count=0;
  for cand in query:iter() do
   if cand._end~=seg._end or seg.length<5 and utf8.len(cand.text)>1 then
    goto next;
   end;
   text_len=utf8.len(cand.text);
   if text_len==1 then
    dup=1;
    comp_count=0;
    goto yield;
   end;
   if text_len==last_len then
    if dup==3 then
     goto next;
    end;
    dup=dup+1;
   else
    last_len=text_len;
    dup=1;
   end;
   ::yield::
   if cand._end-cand.start==#env.engine.context.input and text_len==1 then
    local ncand <const> =Candidate(cand.type,cand.start,cand._end,cand.text,cand.comment);
    ncand.quality=cand.quality;
    ncand.preedit=cand.preedit;
    cand=ncand;
   end;
   yield(cand);
   count=count+1;
   ::next::
   if count==12 then break; end;
  end;
 end,
};