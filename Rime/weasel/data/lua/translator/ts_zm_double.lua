local tran={}
return {
 init=function(env)
  tran.main=Component.Translator(env.engine,"","script_translator@"..env.name_space)
 end,
 func=function(input,seg,env)
  local query=tran.main:query(input,seg) if not query then return end
  local comp_count=0
  local quality_factor
  local last_len,text_len,dup=0,0,1
  for cand in query:iter() do
   text_len=utf8.len(cand.text)
   if text_len==1 then--单字直接yield
    dup=1
    comp_count=0
    goto yield
   end
   if text_len==last_len then--连续的相同长度的候选只能出现12个
    if dup==3 then
     goto next
    end
    dup=dup+1
   else
    last_len=text_len
    dup=1
   end
   ::yield::
   yield(cand)
   ::next::
  end
 end
}