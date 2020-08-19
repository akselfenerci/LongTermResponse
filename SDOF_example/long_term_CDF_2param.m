function [ Flong,varargout ] = long_term_CDF_2param( Uvals,sigmauvals, joint_full_env,Fxd )

ints = bsxfun(@times,joint_full_env,Fxd);

Flong = trapz(Uvals,trapz(sigmauvals,ints,1),2);

if nargout > 1
    varargout{1} = bsxfun(@times,joint_full_env,1-Fxd);
end



end

