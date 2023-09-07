local prefix_len
return
{
 init=function(env)
  prefix_len=#env.engine.schema.config:get_string("recognizer/lua/module_fnua")
 end,
 func=function(key,env)
  if not env.engine.context:has_menu() or key:repr()~="space" then
   return 2
  end
  local ctx=env.engine.context
  local cand=ctx:get_selected_candidate()
  if cand.type=="fancha" then
   ctx:pop_input(ctx.composition:back().length+prefix_len)
   ctx:push_input(cand.text:gsub("[^%a;]",""):lower())
   return 1
  end
 end
}