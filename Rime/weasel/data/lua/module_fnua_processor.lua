return function(key,env)
  local ctx=env.engine.context
  if ctx:has_menu() and key:repr()=="space" then
   local cand=ctx:get_selected_candidate()
   if cand.type=="fancha" then
    local seg=ctx.composition:toSegmentation()
    local new_input=ctx.input:gsub(ctx.input:sub(seg:get_current_start_position(),seg:get_current_end_position()),cand.text:gsub("[^%a;]",""):lower())
    ctx:clear()
    ctx:push_input(new_input)
    return 1
   end
  end
  return 2
 end