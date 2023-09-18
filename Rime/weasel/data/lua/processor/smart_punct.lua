local keyMap={[44]=true,[46]=true}
local beforeMap={[","]=true,["."]=true,["0"]=true,["1"]=true,["2"]=true,["3"]=true,["4"]=true,["5"]=true,["6"]=true,["7"]=true,["8"]=true,["9"]=true,a=true,A=true,b=true,B=true,c=true,C=true,d=true,D=true,e=true,E=true,f=true,F=true,g=true,G=true,h=true,H=true,i=true,I=true,j=true,J=true,k=true,K=true,l=true,L=true,m=true,M=true,n=true,N=true,o=true,O=true,p=true,P=true,q=true,Q=true,r=true,R=true,s=true,S=true,t=true,T=true,u=true,U=true,v=true,V=true,w=true,W=true,x=true,X=true,y=true,Y=true,z=true,Z=true,}
return function (key,env)
 if
  keyMap[key.keycode] and not env.engine.context:is_composing()
 then
  local lc=env.engine.context.commit_history:back()
  if lc then
   if beforeMap[lc.text:sub(-1)] then
    return 0
   end
  end
 end
 return 2
end