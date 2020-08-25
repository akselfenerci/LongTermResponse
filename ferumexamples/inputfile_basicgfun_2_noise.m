% EXAMPLE Der Kiureghian example 1

clear probdata femodel analysisopt gfundata randomfield systems results output_filename

output_filename = 'outputfile_basicgfun_2_noise.txt';


probdata.marg(1,:) =  [ 2  120   12   120  0 0 0 0 0 ];
probdata.marg(2,:) =  [ 2  120   12   120  0 0 0 0 0 ];
probdata.marg(3,:) =  [ 2  120   12   120  0 0 0 0 0 ];
probdata.marg(4,:) =  [ 2  120   12   120  0 0 0 0 0 ];
probdata.marg(5,:) =  [ 2  50    15   50   0 0 0 0 0 ];
probdata.marg(6,:) =  [ 2  40    12   40   0 0 0 0 0 ];


probdata.correlation = [ 1.0  0    0    0    0   0  ;
                         0   1.0   0    0    0   0  ;
                         0    0   1.0   0    0   0  ;
                         0    0    0   1.0   0   0  ;
                         0    0    0    0   1.0  0  ;
                         0    0    0    0    0  1.0];
                      
probdata.parameter = distribution_parameter(probdata.marg);
                      
analysisopt.ig_max    = 100;
analysisopt.il_max    = 5;
analysisopt.e1        = 0.001;
analysisopt.e2        = 0.001; 
analysisopt.step_code = 0;
analysisopt.grad_flag = 'DDM';
analysisopt.sim_point = 'dspt';
analysisopt.stdv_sim  = 1;
analysisopt.num_sim   = 100000;
analysisopt.target_cov = 0.0125;

gfundata(1).evaluator = 'basic';
gfundata(1).type = 'expression';
gfundata(1).parameter = 'no';
gfundata(1).expression = 'x(1) + 2*x(2) + 2*x(3) + x(4) - 5*x(5) - 5*x(6) + 0.001*sin(100*x(1))+ 0.001*sin(100*x(2))+ 0.001*sin(100*x(3))+ 0.001*sin(100*x(4))+ 0.001*sin(100*x(5))+ 0.001*sin(100*x(6))';
gfundata(1).dgdq = { '1 + 0.1*cos(100*x(1))' ;
                     '2 + 0.1*cos(100*x(2))' ;
                     '2 + 0.1*cos(100*x(3))';
                     '1 + 0.1*cos(100*x(4))' ;
                     '-5 + 0.1*cos(100*x(5))' ;
                     '-5 + 0.1*cos(100*x(6))'};
femodel = 0;
randomfield.mesh = 0;