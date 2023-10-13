local global_comment <const> =""
local Time_Table,Reverse={},{}
do
 local inputTable <const> =dofile(exist("custom_time.txt"))
 --优化算法,将数组优化为哈希表索引,将时间复杂度缩减为O(1)
 for index,entry in ipairs(inputTable) do -- 遍历条
  for _,item in ipairs(entry) do          -- 遍历目
   item.text=load("return "..item.text)   -- 将text封装为函数
  end
  table.insert(Time_Table,entry)          -- 将条目插入Time_Table
  for _,code in ipairs(entry.codes) do    -- 为编码建立索引
   if not Reverse[code] then
    Reverse[code]={}
   end
   table.insert(Reverse[code],index) -- 插入索引
  end
 end
end
-- local function timeDebug(input)
--  if not Reverse[input] then return "编码不存在" end
--  for _,index in ipairs(Reverse[input]) do
--   local entry=Time_Table[index]
--   for _,item in ipairs(entry) do
--    local text=item.text()
--    local comment=item.comment or entry.comment or global_comment
--    print(text,comment)
--   end
--  end
-- end
-- timeDebug("week")
return function(input,seg,env)
 if not Reverse[input] then
  return
 end
 tipsEnv(env,"〔时间输出〕",true)
 for _,index in ipairs(Reverse[input]) do
  local entry <const> =Time_Table[index]
  for _,item in ipairs(entry) do
   local text <const>   =item.text()
   local comment <const> =item.comment or entry.comment or global_comment
   local cand <const>   =Candidate("time_cand",seg.start,seg._end,text,comment)
   cand.quality         =8102
   yield(cand)
  end
 end
end