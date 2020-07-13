% EXAMPLE Calrel

clear probdata femodel analysisopt gfundata randomfield systems results output_filename

output_filename = 'outputfile_basicgfunc_6rvs.txt';

probdata.marg(1,:) =  [ 2  500   100  500  0 0 0 0 0];
probdata.marg(2,:) =  [ 2  2000   400   2000  0 0 0 0 0];
probdata.marg(3,:) =  [ 6  5   0.5   5     0 0 0 0 0];
probdata.marg(4,:) =  [ 2  450   90   450   0 0 0 0 0];
probdata.marg(5,:) =  [ 2  1800    360   1800  0 0 0 0 0];
probdata.marg(6,:) =  [ 6  4.5    0.45   4.5     0 0 0 0 0];


probdata.correlation = [ 1.0  0.3    0.2    0    0   0 ;
                         0.3   1.0   0.2    0    0   0 ;
                         0.2    0.2   1.0   0    0   0 ;
                         0    0    0   1.0   0.3   0.2;
                         0    0    0    0.3   1.0  0.2;
                         0    0    0    0.2    0.2  1.0];
                      
probdata.parameter = distribution_parameter(probdata.marg);
                      
analysisopt.ig_max     = 100;
analysisopt.il_max     = 5;
analysisopt.e1        = 0.001;
analysisopt.e2        = 0.001; 
analysisopt.step_code = 0;
analysisopt.grad_flag = 'ddm';
analysisopt.sim_point = 'dspt';
analysisopt.stdv_sim  = 1;
analysisopt.num_sim   = 100000;
analysisopt.target_cov = 0.0125;

gfundata(1).evaluator = 'basic';
gfundata(1).type = 'expression';
gfundata(1).parameter = 'yes';

gparam1_1 = 1.7;
gfundata(1).thetag = [ gparam1_1 ];

gfundata(1).expression = 'gfundata(1).thetag(1) - x(2)/(1000*x(3)) - (x(1)/(200*x(3)))^2 - x(5)/(1000*x(6)) - (x(4)/(200*x(6)))^2';
gfundata(1).dgdq = { '-x(1)/(20000*x(3)^2)' ;
                     '-1/(1000*x(3))' ;
                     '(20*x(2)*x(3)+x(1)^2)/(20000*x(3)^3)';
                     '-x(4)/(20000*x(6)^2)' ;
                     '-1/(1000*x(6))' ;
                     '(20*x(5)*x(6)+x(4)^2)/(20000*x(6)^3)'};
gfundata(1).dgthetag = { '1'};
                  
                  
femodel = 0;
randomfield.mesh = 0;