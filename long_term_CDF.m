function [ Flong,varargout ] = long_term_CDF( fun,Uvals,sigmauvals,sigmawvals,X,Y,Z,joint_full_env,lmSTD,lmSTDdot )

[std] = predict(lmSTD,[X(:),Y(:),Z(:)]);

[stddot] = predict(lmSTDdot,[X(:),Y(:),Z(:)]);

std(std<0) = 1e-5;
stddot(stddot<0) = 1e-5;


Fx_d = arrayfun(fun, std, stddot);

ints = bsxfun(@times,joint_full_env,reshape(Fx_d,size(X)));

if nargout > 1
    ints_rev = bsxfun(@times,joint_full_env,1-reshape(Fx_d,size(X)));
    [~,max_idx] = max(ints_rev(:));
    % Max contribution
    varargout{1} = [X(max_idx), Y(max_idx), Z(max_idx)];
end


Flong = trapz(Uvals,trapz(sigmauvals,trapz(sigmawvals,ints,3),1),2);



end

