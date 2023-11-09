local function toSimpleCand(cand)
 local ncand <const> =Candidate(cand.type,cand.start,cand._end,cand.text,cand.comment)
 ncand.quality=cand.quality
 ncand.preedit=cand.preedit
 return ncand
end
local T <const> = {}
T.init=function(env)
 T.Translator=Component.Translator(env.engine,"","script_translator@"..env.name_space)
end
T.func=function(input,seg,env)
 local query <const> =T.Translator:query(input,seg)
 if not query then
  return
 end
 local previousTextLength=0
 local currentTextLength=0
 local duplicateTextCount=1
 for cand in query:iter() do
  currentTextLength=utf8.len(cand.text)
  if currentTextLength==1 then
   duplicateTextCount=1
   goto yield
  end
  if currentTextLength==previousTextLength then
   if duplicateTextCount==12 then
    goto next
   end
   duplicateTextCount=duplicateTextCount+1
  else
   previousTextLength=currentTextLength
   duplicateTextCount=1
  end
  ::yield::
  if cand._end-cand.start==#env.engine.context.input and currentTextLength==1 then
   cand=toSimpleCand(cand)
  end
  yield(cand)
  ::next::
 end
end
return T