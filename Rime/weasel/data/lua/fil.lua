return function(input)
 local cands={}
 local candsReverse={}
 for cand in input:iter() do
  if cands[cand.text] then
   if cands[cand.text].comment=="" then
    cands[cand.text].comment=cand.comment
   end
  else
   if cand.type:find("user") then
    cand.comment=cand.comment..'*'
   end
   cands[cand.text]=cand
   table.insert(candsReverse,cand.text)
  end
 end
 for _,index in ipairs(candsReverse) do
  yield(cands[index])
 end
end