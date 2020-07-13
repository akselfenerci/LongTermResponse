

clear probdata femodel analysisopt gfundata randomfield systems results output_filename

output_filename = 'outputfile_basicgfun_6rvs_inverse.txt';


%probdata.marg(1,:) =  [ 2  500   100  500  0 0 0 0 0];
probdata.marg(1,:) =  [ 2  2000   400   2000  0 0 0 0 0];
probdata.marg(2,:) =  [ 6  5   0.5   5     0 0 0 0 0];
probdata.marg(3,:) =  [ 2  450   90   450   0 0 0 0 0];
probdata.marg(4,:) =  [ 2  1800    360   1800  0 0 0 0 0];
probdata.marg(5,:) =  [ 6  4.5    0.45   4.5     0 0 0 0 0];


probdata.correlation = [     1.0   0.2    0    0    0 ;
                             0.2   1.0    0    0    0 ;
                             0     0     1.0   0.3  0.2;
                             0     0     0.3   1.0  0.2;
                             0     0     0.2   0.2  1.0];
                      
probdata.parameter = distribution_parameter(probdata.marg);
                      
analysisopt.ig_max    = 200;
analysisopt.il_max    = 5;
analysisopt.e1        = 0.001;
analysisopt.e2        = 0.001; 
analysisopt.step_code = 0;
analysisopt.grad_flag = 'ddm';

analysisopt.e3 = 0.001;           % Tolerance on how close to beta target is the solution point 
analysisopt.beta_target = 2.4;    % Target value for the index of reliability

gfundata(1).evaluator = 'basic';
gfundata(1).type = 'expression';
gfundata(1).parameter = 'no';



gfundata(1).deterministic_parameter_start_value = 200;

gfundata(1).expression = '1.7 - x(1)/(1000*x(2)) - (theta(1)/(200*x(2)))^2 - x(4)/(1000*x(5)) - (x(3)/(200*x(5)))^2';
gfundata(1).dgdq = { '-1/(1000*x(2))' ;
                     '(20*x(1)*x(2)+ theta(1)^2)/(20000*x(2)^3)';
                     '-x(3)/(20000*x(5)^2)' ;
                     '-1/(1000*x(5))' ;
                     '(20*x(4)*x(5)+x(3)^2)/(20000*x(5)^3)'};
                 
gfundata(1).dgdthetadeter = { '-theta(1)/(20000*x(2)^2)'};
                  
                  
femodel = 0;
randomfield.mesh = 0;