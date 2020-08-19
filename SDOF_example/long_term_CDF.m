function [ Flong,varargout ] = long_term_CDF( Uvals,sigmauvals,sigmawvals, joint_full_env,Fxd )

ints = bsxfun(@times,joint_full_env,Fxd);

Flong = trapz(Uvals,trapz(sigmauvals,trapz(sigmawvals,ints,3),1),2);

if nargout > 1
    cont1 = squeeze(trapz(sigmawvals,bsxfun(@times,joint_full_env,1-Fxd),3));
    cont2 = squeeze(trapz(sigmauvals,bsxfun(@times,joint_full_env,1-Fxd),1));
    varargout{1} = cont1;
    
    varargout{2} = cont2;
    
    varargout{3} = bsxfun(@times,joint_full_env,1-Fxd);
end



end

