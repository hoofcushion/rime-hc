local function indexValidate(index,length)
 if index>length then
  index=length
 elseif index<0 then
  index=length+index+1
 end
 return index
end
utf8.sub=function(str,startIndex,endIndex)
 local length=utf8.len(str)
 return endIndex and
 str:sub(utf8.offset(str,indexValidate(startIndex,length)),utf8.offset(str,indexValidate(endIndex,length)+1)-1)
 or
 str:sub(utf8.offset(str,indexValidate(startIndex,length)))
end