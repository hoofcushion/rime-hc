local map={}
return{
 init=function(env)
  map[env.engine.schema.config:get_string('key_binder/select_first_character')]=1
  map[env.engine.schema.config:get_string('key_binder/select_last_character')]=-1
 end,
 func=function(key,env)
  if not env.engine.context:has_menu() then return 2 end
  local n=map[key:repr()]
  if not n then return 2 end
  env.engine:commit_text(utf8Sub(env.engine.context:get_selected_candidate().text,n,n))
  env.engine.context:clear()
  return 1
 end
}