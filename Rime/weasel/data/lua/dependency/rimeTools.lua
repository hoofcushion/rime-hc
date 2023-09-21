Sep=package.config:sub(1,1)
user=rime_api:get_user_data_dir()
data=rime_api:get_shared_data_dir()
userS=user..Sep
dataS=data..Sep
exist=function(name)
 local file
 local filePath
 filePath=userS..name
 file=io.open(filePath,"r")
 if file then
  file:close()
  return filePath
 end
 filePath=dataS..name
 file=io.open(filePath,"r")
 if file then
  file:close()
  return filePath
 end
 log:error("could not find "..name)
end
tipsAdd=function(env,str)
 local comp <const> =env.engine.context.composition
 if comp:empty() then return; end
 local seg=comp:back()
 seg.prompt=seg.prompt..str
end
tipsRep=function(env,str)
 local comp <const> =env.engine.context.composition
 if comp:empty() then return; end
 local seg=comp:back()
 seg.prompt=str
end