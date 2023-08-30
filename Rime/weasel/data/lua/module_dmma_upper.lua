local tran
return{
 init=function(env) tran=Component.Translator(env.engine,"","script_translator@module_dmma") end,
 func=function(input,seg,env)
  if not input:find("[A-Z]") then return end
  local query=tran:query(input:lower(),seg) if not query then return end
  tips(env,"〔大写辅码〕")
  for cand in query:iter() do
   cand.comment="「"..cand.comment:sub(-3,-2):upper().."」"
   yield(cand)
  end
 end
}