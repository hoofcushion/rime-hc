local symbol;
local code_start;
local baseMap <const> =
{
 H={num=16,expattern="[^a-f0-9]",pattern="0-9a-f",limit="10FFFF"},
 D={num=10,expattern="[^0-9]",pattern="0-9",limit="1114111"},
 O={num=8,expattern="[^0-7]",pattern="0-7",limit="4177777"},
 B={num=2,expattern="[^1-2]",pattern="1-2",limit="100001111111111111111"},
};
return
{
 init=function(env)
  symbol=env.engine.schema.config:get_string("recognizer/lua/unicode");
  code_start=#symbol+1;
 end,
 func=function(_,seg,env)
  if not seg:has_tag("unicode") then return; end;
  local tip="〔Unicode〕";
  local code <const> =env.engine.context.input:sub(code_start,seg.length);
  if code=="" then
   tipsAdd(env,tip.."〔请输入编码〕");
   return;
  end;
  local baseTab <const> =baseMap[code:match("([HDOB])") or "H"];
  tip=tip.."〔"..baseTab.num.." 进制〕";
  local sCode=code:match("[a-f0-9]+");
  if not sCode then
   tipsAdd(env,tip.."〔编码错误〕");
   return;
  elseif sCode:find(baseTab.expattern) then
   tipsAdd(env,tip.."〔超出进制范围: "..baseTab.pattern.."〕");
   return;
  end;
  local nCode <const> =tonumber(sCode,baseTab.num);
  if not nCode then
   tipsAdd(env,tip.."〔数值错误〕");
   return;
  elseif nCode>1114111 then
   tipsAdd(env,tip.."〔超出数值范围: "..baseTab.limit.."〕");
   return;
  end;
  for i=0,9 do
   local nCode <const> =nCode+i;
   if nCode>1114111 then
    break;
   end;
   local cand <const> =Candidate("unicode",seg.start,seg._end,utf8.char(nCode),"0x"..nCode);
   cand.preedit=code;
   yield(cand);
  end;
  tipsAdd(env,tip);
 end,
};