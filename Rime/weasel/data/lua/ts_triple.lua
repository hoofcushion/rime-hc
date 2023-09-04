local length=3
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
   yielded[cand.text]=cand
  end
  query=tran.main:query(input,seg) if not query then return end
  local comp_count=0
  local quality_factor
  local last_len,text_len,dup=0,0,0
  for cand in query:iter() do
   if not quality_factor then
    quality_factor=math.abs(utf8.len(cand.text)*length-#input)-0.25
   end
   cand.quality=cand.quality-quality_factor/8
   if yielded[cand.text] then
    yield(yielded[cand.text])
    goto next
   end
   text_len=utf8.len(cand.text)
   if text_len==1 then--单字直接yield
    last_len,dup,comp_count=0,0,0
    yield(cand)
    goto next
   end
   if text_len==last_len then--连续的相同长度的候选只能出现12个
    if dup==11 then
     goto next
    end
    dup=dup+1
   else
    last_len=text_len
    dup=0
   end
   if cand._end-cand._start~=text_len*length then--候选补全提示
    comp_count=comp_count+1
    if comp_count>3 then
     goto next
    end
    if text_len<4 then
     cand.comment=cand.comment.."〔补〕"
    end
   else
    comp_count=0
   end
   yield(cand)
   ::next::
  end
 end
}