function [ int ] = LTint_RSM( U,sigmau,sigmaw,resp,lmSTD,lmSTDdot,joint_full_env )

[std] = predict(lmSTD,[U,sigmau,sigmaw]);

[stddot] = predict(lmSTDdot,[U,sigmau,sigmaw]);

if any([std<0 stddot<0])
    std = 1e-5;
    stddot = 1e-5;
end

Tshort = 600;

[ Fx_d ] = short_term_extreme( std,stddot,Tshort,resp );


int = Fx_d*joint_full_env;

end

