function utf8Byte(str,index)
 local uByte=str:byte(index)
 return 
 not uByte                 and 0 or
 uByte> 0   and uByte<=127 and 1 or
 uByte>=192 and uByte<=223 and 2 or
 uByte>=224 and uByte<=239 and 3 or
 uByte>=240 and uByte<=247 and 4
end
function utf8Len(str)
 local totalCount,lastBytes=1,1
 local length=-1
 repeat
  lastBytes=utf8Byte(str,totalCount)
  totalCount=totalCount+lastBytes
  length=length+1
 until lastBytes==0
 return length
end
function utf8Bytes(str,index)
 local totalCount,lastBytes=1,nil
 for i=1,index do
  lastBytes=utf8Byte(str,totalCount)
  totalCount=totalCount+lastBytes
 end
 return totalCount-lastBytes
end
function utf8Sub(str,startIndex,endIndex)
 local length=utf8Len(str)
 if startIndex<0 then
  startIndex=length+startIndex+1
 end
 startIndex=utf8Bytes(str,startIndex)
 if not endIndex then
  return str:sub(startIndex)
 end
 if endIndex<0 then
  endIndex=length+endIndex+1
 end
 endIndex=utf8Bytes(str,endIndex+1)-1
 return str:sub(startIndex,endIndex)
end