% RANDOM FIELD BEAM EXAMPLE
clear probdata femodel analysisopt gfundata randomfield systems results output_filename


% Define the name and type of the file to store the output of the analysis:
output_filename = 'outputfile_randomfield.txt';

NFEL  = 16;   % Number of structural finite elements
NTERM = 5;    % Number of terms in the eigenvalue expansion
random = 0;

for i = 1 : NTERM
   probdata.marg(i,:) =   [ 1    0    1   0  0 0 0 0 0];
end
probdata.correlation = eye(NTERM);

probdata.parameter = distribution_parameter(probdata.marg);

analysisopt.ig_max     = 100;
analysisopt.il_max     = 5;
analysisopt.e1        = 0.001;
analysisopt.e2        = 0.001; 
analysisopt.step_code = 0;
analysisopt.grad_flag = 'ddm';
analysisopt.sim_point = 'dspt'; 
analysisopt.stdv_sim  = 1;      
analysisopt.num_sim   = 10000;   
analysisopt.target_cov = 0.03;  


femodel.ndf = 3;
for i = 1 : (NFEL+1)
   femodel.node(i,:) =  [  ( (i-1) * 5000/NFEL)      0       ];
end
for i = 1 : NFEL
   femodel.el(i,:) =  [ 2 i  (i+1) (random) 1.86*10^9  1000 ];
end
femodel.loading(1,:) = [   9  100000     2   1  ];
femodel.nodal_spring = 0;
femodel.fixed_dof(1,:) = [  1        1 1 0 ]; 
femodel.fixed_dof(2,:) = [ (NFEL+1)  1 1 0 ]; 
for i = 1 : NFEL
   femodel.id(i,:) = [  i    2    i  ];
end

gfundata(1).evaluator = 'FERUMlinearfecode';
gfundata(1).type = 'displacementlimit';
gfundata(1).parameter = 'no';
gfundata(1).resp = [ 9  2 ];
gfundata(1).lim = 1.0;

randomfield.mesh = [ 0:5000/10:5000 ];
randomfield.meanfunc = '200000';
randomfield.covariancefunc = '20000^2 * exp( -(abs(xn(i)-x(j)))^2 / (3*5000/10)^2 )';
randomfield.nterm      = NTERM;
randomfield.fieldtype  = 1;


