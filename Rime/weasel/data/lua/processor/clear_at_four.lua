local mem
return
{
 init=function(env)
  mem=Memory(env.engine,env.engine.schema)
 end,
 func=function(key,env)
  local ctx=env.engine.context
  if #ctx.input==4 and not mem:dict_lookup(ctx.input,true,1) then
   ctx:clear()
   return 1
  end
  return 2
 end
}