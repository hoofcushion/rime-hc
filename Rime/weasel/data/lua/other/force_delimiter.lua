return function(input)
 for cand in input:iter() do
  cand.preedit=cand.preedit:gsub(" ","|")
  yield(cand)
 end
end