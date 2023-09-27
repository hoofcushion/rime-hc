local tran
local symbol
local code_start
local comment <const> ="『符号』"
local translator <const> =
{
 init=function(env)
  symbol=env.engine.schema.config:get_string("recognizer/lua/"..env.name_space)
  code_start=#symbol+1
  tran=Component.Translator(env.engine,"","table_translator@"..env.name_space)
 end,
 func=function(input,seg,env)
  if not seg:has_tag(env.name_space) then return; end
  tipsAdd(env,"〔符号输出〕")
  local input <const> =input:sub(code_start)
  if input=="" then return; end
  local query <const> =tran:query(input,seg)
  if not query then return; end
  for cand in query:iter() do
   cand.comment=comment
   cand._end=seg._end
   yield(cand)
  end
 end,
}
return translator