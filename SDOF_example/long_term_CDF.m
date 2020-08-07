function [ Flong,varargout ] = long_term_CDF( Uvals,sigmauvals,sigmawvals, joint_full_env,Fxd )

ints = bsxfun(@times,joint_full_env,Fxd);

Flong = trapz(Uvals,trapz(sigmauvals,trapz(sigmawvals,ints,3),1),2);


end

