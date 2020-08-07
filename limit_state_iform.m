function [ c,ceq  ] = limit_state_iform( u,beta )

c = [];

ceq = norm(u) - beta;

end

