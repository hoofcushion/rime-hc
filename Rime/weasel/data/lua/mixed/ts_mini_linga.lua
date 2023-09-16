local mini={}
mini.array={}
mini.table={}
do
 local index=0
 local file=io.open(exist("ts_mini_linga_dict.txt"),"r")
 for line in file:lines() do
  local a,b,c=line:match("^(.-)\t(.-)\t(.+)$")
  index=index+1
  mini.array[a]=index
  table.insert(mini.table,{a,b,c,a..b..c})
 end
 file:close()
end
mini.reverse=function(self,str)
 return self.table[self.array[str]]
end
mini.hanzify=function(self,str)
 local r=""
 for w,s in str:gmatch("([%a-]+)([^%a-]*)") do
  if w:find("%-") then
   r=r.."「"..self:hanzify(w:gsub("%-"," ")).."」"
  else
   local v=self:reverse(w:gsub("%-"," "))
   r=r..(v and v[2] or w)
  end
  r=r..s
 end
 return r
end
local tran={}
local module
local symbol
local code_start
return
{
 {
  init=function(env)
   symbol=env.engine.schema.config:get_string("recognizer/lua/"..env.name_space)
   code_start=#symbol+1
  end,
  func=function(_,seg,env)
   if not seg:has_tag(env.name_space) then return end
   local input=env.engine.context.input
   if not input:find("^"..symbol) then return end
   tipsAdd(env,"〔Mini Name Jage〕")
   local code=input:sub(code_start)
   for i,v in ipairs(mini.table) do
    if input==symbol or v[4]:find(code) then
     local cand=Candidate("",seg.start,seg._end,v[1],v[2].."\t"..v[3])
     cand.quality=8102
     cand.preedit=code
     yield(cand)
    end
   end
  end
 },
 {
  init=function(env)
   module=env.name_space~="translator"
   local name_space=module and "ts_mini_linga" or "translator"
   tran[1]=Component.Translator(env.engine,"","script_translator@"..name_space)
   tran[2]=Component.Translator(env.engine,"","table_translator@"..name_space)
  end,
  func=function(input,seg)
   if module and #input==1 then return end
   if input:find("^y") or input:find("^h$") then return end
   local yielded={}
   local count=0
   for i=1,#tran do
    local query=tran[i]:query(input,seg) if not query then return end
    for cand in query:iter() do
     if #input-cand._end+cand.start+1==input:reverse():find("[why]") then goto next end
     local text=cand.text:gsub(" $",""):gsub(" %-","-")
     if yielded[text] then goto next end
     yielded[text]=true
     if input:find("^%u") then--auto uppercase
      text=text:gsub("%a",string.upper,1)
     end
     yield(ShadowCandidate(cand,cand.type,text,mini:hanzify(text):gsub(" ","")))
     if module then
      count=count+5/(#cand.text+5)
      if count>1 then return end
     else
      count=count+1
      if count>100 then return end
     end
     ::next::
    end
   end
  end
 }
}