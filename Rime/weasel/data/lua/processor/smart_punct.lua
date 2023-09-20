local keyMap <const> ={[44]=true,[46]=true};
local beforeMap <const> =
{
 [","]=true,
 ["."]=true,
 ["0"]=true,
 ["1"]=true,
 ["2"]=true,
 ["3"]=true,
 ["4"]=true,
 ["5"]=true,
 ["6"]=true,
 ["7"]=true,
 ["8"]=true,
 ["9"]=true,
};
return function(key,env)
 if
 keyMap[key.keycode] and not env.engine.context:is_composing()
 then
  local lc <const> =env.engine.context.commit_history:back();
  if lc then
   if beforeMap[lc.text:sub(-1)] then
    return 0;
   end;
  end;
 end;
 return 2;
end;