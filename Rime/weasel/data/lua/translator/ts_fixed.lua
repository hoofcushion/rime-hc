local function toSimpleCand(cand)
 local ncand <const> =Candidate(cand.type,cand.start,cand._end,cand.text,cand.comment)
 ncand.quality=cand.quality
 ncand.preedit=cand.preedit
 return ncand
end

local function setup (user_opts)
 local opts <const> ={
  syllableLength=2
 }
 if type(user_opts)=="table" then
  for k,v in next,user_opts do
   opts[k]=v
  end
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
  local uncompleteCandCount=0
  local quality_factor
  local previousTextLength=0
  local currentTextLength=0
  local duplicateTextCount=1
  for cand in query:iter() do
   if not quality_factor then
    quality_factor=math.abs(utf8.len(cand.text)*opts.syllableLength-#input)-0.25
   end
   cand.quality=cand.quality-quality_factor/8
   currentTextLength=utf8.len(cand.text)
   if currentTextLength==1 then
    duplicateTextCount=1
    uncompleteCandCount=0
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
   if cand._end-cand._start~=currentTextLength*opts.syllableLength then
    if uncompleteCandCount==3 then
     goto next
    end
    if currentTextLength<4 then
     cand.comment=cand.comment.."〔补〕"
    end
    uncompleteCandCount=uncompleteCandCount+1
   else
    uncompleteCandCount=0
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
end
local M <const> = {
 setup=setup
}
return M