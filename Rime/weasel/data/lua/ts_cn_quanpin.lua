local tran={}
return {
 init=function(env)
  tran.lock=Component.Translator(env.engine,"","table_translator@module_lock")
  tran.main=Component.Translator(env.engine,"","script_translator@translator")
 end,
 func=function(input,seg,env)
  local query
  query=tran.lock:query(input,seg) if not query then return end
  local yielded={}
  for cand in query:iter() do
   if cand._end~=#input then break end
   yielded[cand.text]=true
  end
  query=tran.main:query(input,seg) if not query then return end
  local last_len,dup=0,0
  local text_len
  for cand in query:iter() do
   if yielded[cand.text] then
    local cand_lock=Candidate("lock",seg.start,seg._end,cand.text,"")
    cand_lock.quality=cand.quality
    cand_lock.preedit=cand.preedit
    yield(cand_lock)
    goto next
   end
   text_len=utf8.len(cand.text)
   if text_len==1 then--单字直接yield
    last_len,dup=0,0
   else
    if text_len==last_len then--连续的相同长度的候选只能出现12个
     dup=dup+1
    else
     last_len=text_len
     dup=0
    end
    if dup==12 then
     goto next
    end
   end
   yield(cand)
   ::next::
  end
 end
}