local tran;
return
{
 init=function(env) tran=Component.Translator(env.engine,"","script_translator@"..env.name_space); end,
 func=function(input,seg)
  if not input:find("[A-Z]") then return; end;
  local query <const> =tran:query(input:lower(),seg);
  if not query then return; end;
  for cand in query:iter() do
   cand.comment="「"..cand.comment:sub(-3,-2):upper().."」";
   yield(cand);
  end;
 end,
};