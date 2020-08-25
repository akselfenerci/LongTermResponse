function [ c,ceq  ] = limit_state_ECM( u,beta )

c = [];

ceq = norm(u) - beta;

end

