function [ Fx,MPP ] = form_CDF_value( x,x0,TT )

options = optimoptions(@fmincon,...
    'Display','none','Algorithm','sqp');

obj_fun = @(x) norm(TT(x)); 

problem = createOptimProblem('fmincon','x0',x0,...
    'objective',obj_fun,...
    'Aeq',[0 0 0 1],...
    'beq',x,...
    'options',options);
gs = GlobalSearch;

xopt = run(gs,problem);

MPP = xopt;

Fx = normcdf(norm(TT(MPP)));

end

