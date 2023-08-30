return function(input)
 local cand_tab={}
 local reverse_tab={}
 for cand in input:iter() do
  if cand_tab[cand.text] then
   if cand_tab[cand.text].comment=="" then
    cand_tab[cand.text].comment=cand.comment
   end
  else
   cand_tab[cand.text]=cand
   table.insert(reverse_tab,cand.text)
   if cand.type:find("user") then
    cand.comment=cand.comment..'*'
   end
  end
 end
 for i=1,#reverse_tab do
  yield(cand_tab[reverse_tab[i]])
 end
end