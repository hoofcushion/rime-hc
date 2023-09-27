local dict={}
do
 local word={}
 local file=io.open(exist("ts_fanganlianxi.txt"),"r")
 for line in file:lines() do
  local a,b=line:match("^(.-)\t(.+)$")
  if a then
   table.insert(word,{a,b})
  end
 end
 file:close()
 local map={}
 local file=io.open(exist("ts_fanganlianxi_algebra.txt"),"r")
 for line in file:lines() do
  local a,b=line:match("^(.-)\t(.+)$")
  if a then
   map[a]=b
  end
 end
 file:close()
 for _,v in ipairs(word) do
  table.insert(dict,{v[1],v[2]:gsub("%a+",map)})
 end
end
local DICT_ENTRY_LIMIT <const> =#dict
math.randomseed(os.time())
local cands_tab={}
local cands_exists={}
local start,final=1,100
local CANDS_MIN_AMOUNT <const> =10
local cands_insert=function()
 local entry=dict[math.random(start,final)]
 if cands_exists[entry[1]] then
  repeat
   entry=dict[math.random(start,final)]
  until not cands_exists[entry[2]]
 end
 local text=entry[1]
 local code=entry[2]
 cands_exists[text]=true
 table.insert(cands_tab,{text,code,code:gsub(" ","")})
end
local cands_remove=function()
 cands_exists[cands_tab[1][1]]=nil
 table.remove(cands_tab,1)
end
local cands_rotate=function()
 cands_remove()
 cands_insert()
end
local cands_clear=function()
 cands_tab={}
 cands_exists={}
 for i=1,CANDS_MIN_AMOUNT do
  cands_insert()
 end
end
cands_clear()
local hit_table={}
local hit_count=0
local continuous=0
local combo=0
local time_limit=5
local time_last=nil
local now=os.time()
local reset <const> =function()
 hit_table={}
 hit_count=0
 continuous=0
 combo=0
 time_limit=5
 time_last=nil
 now=os.time()
end
local function hit_update()
 if not (hit_table[1] and os.time()-hit_table[1][1]>60) then
  return
 end
 hit_count=hit_count-(hit_table[1][2])
 table.remove(hit_table,1)
 hit_update()
end

local lianxu_update <const> =function(input)
 if continuous then
  if #input<continuous then
   combo=0
   local a=continuous-#input==1
   continuous=false
   if a then return true; end
  elseif #input-continuous<=1 then
   continuous=#input
  end
 else
  combo=0
 end
end
local combo_map <const> =
{
 ["1"]="１",
 ["2"]="２",
 ["3"]="３",
 ["4"]="４",
 ["5"]="５",
 ["6"]="６",
 ["7"]="７",
 ["8"]="８",
 ["9"]="９",
 ["0"]="０",
}
local print_combo <const> =function()
 local str=tostring(combo)
 if #str>1 then return str.." "; end
 str=str:gsub("[0-9]",combo_map)
 return str
end
local time_used <const> =function()
 return now-time_last
end
local pos <const> =function(str)
 local pos={}
 local start_pos,end_pos=string.find(str," ")
 while start_pos do
  table.insert(pos,start_pos)
  start_pos,end_pos=string.find(str," ",end_pos+1)
 end
 return pos
end
local insert <const> =function(str,positions)
 local len <const> =#str
 for i,pos in ipairs(positions) do
  if len<pos then break; end
  str=str:sub(1,pos-1).." "..str:sub(pos)
 end
 return str
end
local syllable <const> =function(raw,code)
 return insert(raw,pos(code))
end
local tip_map={}
tip_map.wrong=
{"Wrong!","Try harder!","Open your Eyes!","What is wrong with you?","Don't hit that.","You blind?",
 "Stop.","Go do something else.","Wait...","What?","Why.","Idiot.","Can't even worse.","I wish that did't...",
}
local failedtips <const> =function(env)
 if combo>4 then
  tipsAdd(env,"So sad!")
 else
  tipsAdd(env,tip_map.wrong[math.random(1,#tip_map.wrong)])
 end
end
local successtips <const> =function(env)
 if combo~=0 and time_used()>time_limit then
  tipsAdd(env,"Wait too long!")
  continuous=false
 else
  if not time_last or time_used()>60 then
   tipsAdd(env,"First!") --第一击
  elseif continuous then
   if combo>4 then
    tipsAdd(env,print_combo().."Combo!") --五连起显示连击次数
   else
    local len <const> =utf8.len(cands_tab[1][1])
    if time_used()<len*(1.5-0.125*len) then
     tipsAdd(env,"Excellent!")
    else
     tipsAdd(env,"Perfect!")
    end
   end
  end
  continuous=0
  combo=combo+1
 end
end
local initial_code
local initial_code_l
local code_start
local key_map=
{
 ["bracketleft"]="clear",
 ["bracketright"]="skip",
 ["apostrophe"]="reset",
}
local key_actions=
{
 clear=function(ctx)
  ctx:clear()
  ctx:push_input(initial_code)
  return 1
 end,
 skip=function(ctx)
  cands_rotate()
  ctx:clear()
  ctx:push_input(initial_code)
  return 1
 end,
 reset=function(ctx)
  reset()
  return 1
 end,
}
local symbol
local prosessor <const> =
{
 init=function(env)
  initial_code=env.engine.schema.config:get_string("speller/initial_code")
  initial_code_l=#initial_code
  code_start=initial_code_l+1
  symbol=env.engine.schema.config:get_string("speller/symbol")
 end,
 func=function(_,env)
  if not env.engine.context:is_composing() then return 2; end
  local ctx <const> =env.engine.context
  local ctx_inp <const> =ctx.input
  if ctx_inp:find("^"..symbol) then
   if ctx_inp:find(symbol.."$") then
    local code=ctx_inp:sub(1+initial_code_l,-1-initial_code_l)
    if code:find("s%d+t%d+") then
     start,final=code:match("s(%d+)t(%d+)")
     start=tonumber(start)
     final=tonumber(final)
     if start>=1 and final<=DICT_ENTRY_LIMIT then
      if final-start<=CANDS_MIN_AMOUNT then
       final=start+CANDS_MIN_AMOUNT+1
      end
      cands_clear()
     end
     ctx:clear()
     return 1
    end
   end
   return 2
  end
  local input <const> =ctx.input:sub(code_start)
  now=os.time()
  if lianxu_update(input) then
   tipsAdd(env,"I see that.")
  end
  local key <const> =_:repr()
  if key_map[key] then
   return key_actions[key_map[key]](ctx)
  end
  local pattern <const> =cands_tab[1][3]
  if #input==#pattern then
   if input==pattern then
    cands_rotate()
    local text_len <const> =utf8.len(cands_tab[1][1])
    table.insert(hit_table,{os.time(),text_len})
    hit_count=hit_count+text_len
    time_last=os.time()
    successtips(env)
   else
    continuous=false
    failedtips(env)
   end
   ctx:pop_input(#input)
   return 1
  end
  return 2
 end,
}
local translator <const> =
{
 function(input,seg,env)
  hit_update()
  tipsAdd(env,"〔"..hit_count.."/min〕")
  for k,dict in ipairs(cands_tab) do
   local cand <const> =Candidate("",seg.start,seg._end,dict[1],dict[2])
   cand.preedit=syllable(input:sub(2),dict[2])
   yield(cand)
  end
 end,
}
return {prosessor,translator}