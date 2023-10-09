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
tipsEnv=function(ctx,str,add)
 local comp <const> =env.engine.context.composition
 if comp:empty() then return; end
 local seg=comp:back()
 if add then
  seg.prompt=seg.prompt..str
 else
  seg.prompt=str
 end
end
tipsCtx=function(ctx,str,add)
 local comp <const> =ctx.composition
 if comp:empty() then return; end
 local seg=comp:back()
 if add then
  seg.prompt=seg.prompt..str
 else
  seg.prompt=str
 end
end