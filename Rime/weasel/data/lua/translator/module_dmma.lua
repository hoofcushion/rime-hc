local tran
return
{
 init=function(env) tran=Component.Translator(env.engine,"","script_translator@"..env.name_space) end,
 func=function(input,seg,env)
  if #input~=4 or input:find("%u") then return end
  local query=tran:query(input:lower(),seg) if not query then return end
  tipsAdd(env,"〔小写辅码〕")
  local a=0
  for cand in query:iter() do
   cand.comment="「"..cand.comment:sub(-3,-2):upper().."」"
   cand.quality=cand.quality-0.125
   yield(cand)
   a=a+1
   if a==3 then break end
  end
 end
}