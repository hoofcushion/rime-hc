Sep=package.config:sub(1,1);
user=rime_api:get_user_data_dir();
data=rime_api:get_shared_data_dir();
exist=function(name)
 local function C(path)
  local file=io.open(path,"r");
  return file and file:close() and path;
 end;
 return C(user..Sep..name) or C(data..Sep..name) or error("could not find "..name);
end;
tipsAdd=function(env,str)
 if env.engine.context.composition:empty() then return; end;
 local seg=env.engine.context.composition:back();
 seg.prompt=seg.prompt..str;
end;
tipsRep=function(env,str)
 if env.engine.context.composition:empty() then return; end;
 local seg=env.engine.context.composition:back();
 seg.prompt=str;
end;