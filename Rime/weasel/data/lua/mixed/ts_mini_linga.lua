local miniLookupTable <const> ={}
local miniTable <const> ={}
do
 local tableIndex=0
 local file <const> =io.open(exist("ts_mini_linga_dict.txt"),"r")
 for line in file:lines() do
  local word,hanzi,sinifi=line:match("^(.-)\t(.-)\t(.+)$")
  local miniEntry <const> ={word,hanzi,sinifi,word..hanzi..sinifi}
  tableIndex=tableIndex+1
  miniLookupTable[word]=tableIndex
  miniTable[tableIndex]=miniEntry
 end
 file:close()
end
local startPrompt
local codeBeginning
local search <const> =
{
 init=function(env)
  startPrompt=env.engine.schema.config:get_string("recognizer/lua/"..env.name_space)
  codeBeginning=#startPrompt+1
 end,
 func=function(input,seg,env)
  if not seg:has_tag(env.name_space) then
   return
  end
  local context=env.engine.context
  local contextInput <const> =context.input
  if not string.find(contextInput,"^"..startPrompt) then
   return
  end
  local inputCode <const> =string.sub(contextInput,codeBeginning)
  for _,miniEntry in ipairs(miniTable) do
   if contextInput==startPrompt or string.find(miniEntry[4],inputCode) then
    local text <const> =miniEntry[1]
    local comment <const> =miniEntry[2].."\t"..miniEntry[3]
    local cand=Candidate("",seg.start,seg._end,text,comment)
    cand.quality=8102
    cand.preedit=inputCode
    yield(cand)
   end
  end
 end,
}
local autoUppercase <const> =function(input,text)
 if string.find(input,"^%u") then
  if string.find(input,".%u$") then
   return string.gsub(text,"%l",string.upper)
  end
  return string.gsub(text,"%l",string.upper,1)
 end
 return text
end
local function miniHanzify(str)
 local result=""
 for word,others in str:gmatch("([%a-]+)([^%a-]*)") do
  if string.find(word,"%-") then
   word=string.gsub(word,"%-"," ")
   local compound="「"..miniHanzify(word).."」"
   result=result..compound
  else
   local miniEntry=miniTable[miniLookupTable[word]]
   if miniEntry then
    result=result..miniEntry[2]
   else
    result=result..word
   end
  end
  result=result..others
 end
 return result
end
local TranslatorList <const> ={}
local isModule
local candLimitCounter
local translator <const> =
{
 init=function(env)
  isModule=env.name_space~="translator"
  candLimitCounter=isModule and
   function(yieldCount,text)
    if yieldCount>1 then
     return false
    end
    return yieldCount+5/(#text+5)
   end
   or
   function(yieldCount)
    if yieldCount==10 then
     return false
    end
    return yieldCount+1
   end
  local engineCallName <const> =isModule and "ts_mini_linga" or "translator"
  TranslatorList[#TranslatorList+1]=Component.Translator(env.engine,"","script_translator@"..engineCallName)
  TranslatorList[#TranslatorList+1]=Component.Translator(env.engine,"","table_translator@"..engineCallName)
 end,
 func=function(input,seg)
  local candYieldMap={}
  local yieldCount=0
  for i=1,#TranslatorList do
   local Translator <const> =TranslatorList[i]
   local query <const> =Translator:query(string.lower(input),seg)
   if not query then
    return
   end
   for cand in query:iter() do
    local text=cand.text
    text=string.gsub(text," $","")
    text=string.gsub(text," %-","-")
    text=autoUppercase(input,text)
    cand.preedit=autoUppercase(input,cand.preedit)
    if candYieldMap[text] then
     goto next
    else
     candYieldMap[text]=true
    end
    local comment_hanzi <const> =string.gsub(miniHanzify(text)," ","")
    yieldCount=candLimitCounter(yieldCount,text)
    if not yieldCount then
     return
    end
    yield(ShadowCandidate(cand,cand.type,text,comment_hanzi))
    ::next::
   end
  end
 end,
}
return {search,translator}