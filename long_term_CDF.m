function [ Flong ] = long_term_CDF( fun,Uvals,sigmauvals,sigmawvals,X,Y,Z,joint_full_env,lmSTD,lmSTDdot )

[std] = predict(lmSTD,[X(:),Y(:),Z(:)]);

[stddot] = predict(lmSTDdot,[X(:),Y(:),Z(:)]);

std(std<0) = 1e-5;
stddot(stddot<0) = 1e-5;


Fx_d = arrayfun(fun, std, stddot);

ints = bsxfun(@times,joint_full_env,reshape(Fx_d,size(X)));

Flong = trapz(Uvals,trapz(sigmauvals,trapz(sigmawvals,ints,3),2),1);



end

