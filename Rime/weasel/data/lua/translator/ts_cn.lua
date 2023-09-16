local length=2
local tran={}
return {
 init=function(env)
  tran.jian=Component.Translator(env.engine,"","table_translator@module_cn_jian")
  tran.lock=Component.Translator(env.engine,"","table_translator@module_lock")
  tran.main=Component.Translator(env.engine,"","script_translator@"..env.name_space)
 end,
 func=function(input,seg,env)
  local query
  local ctxInpLen=#env.engine.context.input
  if #env.engine.context.input==1 then
   query=tran.jian:query(input,seg) if not query then return end
   local count=0
   for cand in query:iter() do
    yield(cand)
    count=count+1
    if count==12 then break end
   end
   return
  end
  query=tran.lock:query(input,seg) if not query then return end
  local yielded={}
  for cand in query:iter() do
   if cand._end-cand.start~=ctxInpLen then break end
   yielded[cand.text]=cand
  end
  query=tran.main:query(input,seg) if not query then return end
  local comp_count=0
  local quality_factor
  local last_len,text_len,dup=0,0,1
  for cand in query:iter() do
   if not quality_factor then
    quality_factor=math.abs(utf8.len(cand.text)*length-#input)-0.25
   end
   cand.quality=cand.quality-quality_factor/8
   text_len=utf8.len(cand.text)
   if text_len==1 then--单字直接yield
    dup=1
    comp_count=0
    goto yield
   end
   if text_len==last_len then--连续的相同长度的候选只能出现12个
    if dup==12 then
     goto next
    end
    dup=dup+1
   else
    last_len=text_len
    dup=1
   end
   if cand._end-cand._start~=text_len*length then--候选补全提示
    if comp_count==3 then
     goto next
    end
    if text_len<4 then
     cand.comment=cand.comment.."〔补〕"
    end
    comp_count=comp_count+1
   else
    comp_count=0
   end
   ::yield::
   if yielded[cand.text] then
    yielded[cand.text].quality=cand.quality
    yielded[cand.text].preedit=cand.preedit
    yield(yielded[cand.text])
    goto next
   end
   yield(cand)
   ::next::
  end
 end
}