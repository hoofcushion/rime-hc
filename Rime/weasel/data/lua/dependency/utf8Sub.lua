local utf8_offset <const> =utf8.offset;
local string_sub <const> =string.sub;
utf8.sub=function(str,start,final)
 local len_p <const> =#str+1;
 if final then
  local i1 <const> =start<0 and len_p or 1;
  local i2 <const> =final<0 and len_p or 1;
  final=final+1;
  start,final=utf8_offset(str,start,i1),utf8_offset(str,final,i2);
  final=final-1;
  str=string_sub(str,start,final);
  return str;
 end;
 local i1 <const> =start<0 and len_p or 1;
 start=utf8_offset(str,start,i1);
 str=string_sub(str,start);
 return str;
end;