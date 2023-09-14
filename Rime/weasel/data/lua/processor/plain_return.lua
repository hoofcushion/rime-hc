local keyMap={[65293]=true,[65421]=true}
return function(key,env)
 if env.engine.context:has_menu() and keyMap[key.keycode] then
  env.engine:commit_text(env.engine.context.input)
  env.engine.context:clear()
  return 1
 end
 return 2
end