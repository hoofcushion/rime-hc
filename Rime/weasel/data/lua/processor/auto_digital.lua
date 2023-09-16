local keymap={comma=true,period=true}
return function (key,env)
 if
  keymap[key:repr()]
  and not env.engine.context:is_composing()
  and env.engine.context.commit_history:back().text:find("%d$")
 then
  return 0
 end
 return 2
end