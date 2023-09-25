local LENGTH <const> =2
local least_code_length
local tran
return
{
 init=function(env)
  tran=Component.Translator(env.engine,"","script_translator@"..env.name_space)
  least_code_length=env.engine.schema.config:get_int(env.name_space.."/least_code_length") or 1
 end,
 func=function(input,seg,env)
  if seg._end<least_code_length then return; end
  local query <const> =tran:query(input,seg)
  if not query then return; end
  local comp_count=0
  local quality_factor
  local last_len,text_len,dup=0,0,1
  for cand in query:iter() do
   if not quality_factor then
    quality_factor=math.abs(utf8.len(cand.text)*LENGTH-#input)-0.25
   end
   cand.quality=cand.quality-quality_factor/8
   text_len=utf8.len(cand.text)
   if text_len==1 then
    dup=1
    comp_count=0
    goto yield
   end
   if text_len==last_len then
    if dup==12 then
     goto next
    end
    dup=dup+1
   else
    last_len=text_len
    dup=1
   end
   if cand._end-cand._start~=text_len*LENGTH then
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
   if cand._end-cand.start==#env.engine.context.input and text_len==1 then
    local ncand <const> =Candidate(cand.type,cand.start,cand._end,cand.text,cand.comment)
    ncand.quality=cand.quality
    ncand.preedit=cand.preedit
    cand=ncand
   end
   yield(cand)
   ::next::
  end
 end,
}