return function(key,env)
 local ctx <const> =env.engine.context;
 if ctx:is_composing() and #ctx.input==4 and not ctx:has_menu() then
  ctx:clear();
  return 1;
 end;
 return 2;
end;