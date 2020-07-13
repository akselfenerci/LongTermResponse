% TRUSS EXAMPLE

clear probdata femodel analysisopt gfundata randomfield systems results output_filename


% Define the name and type of the file to store the output of the analysis:
output_filename = 'outputfile_truss.txt';

random = 0;

for i = 1 : 15
   probdata.marg(i,:) =  [ 2  200000       60000    200000   0 0 0 0 0];
end

probdata.correlation = eye(15);

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
analysisopt.target_cov = 0.025;

femodel.ndf = 2;

femodel.node(1,:) = [  0         0       ];
femodel.node(2,:) = [  5000      0       ];
femodel.node(3,:) = [  0         3000    ];
femodel.node(4,:) = [  5000      3000    ];
femodel.node(5,:) = [  0         6000    ];
femodel.node(6,:) = [  5000      6000    ];
femodel.node(7,:) = [  0         9000    ];
femodel.node(8,:) = [  5000      9000    ];

femodel.el(1,:) = [ 1  1 3 (random) 1000 ];
femodel.el(2,:) = [ 1  1 4 (random) 1000 ];
femodel.el(3,:) = [ 1  2 3 (random) 1000 ];
femodel.el(4,:) = [ 1  2 4 (random) 1000 ];
femodel.el(5,:) = [ 1  3 4 (random) 1000 ];
femodel.el(6,:) = [ 1  3 5 (random) 1000 ];
femodel.el(7,:) = [ 1  3 6 (random) 1000 ];
femodel.el(8,:) = [ 1  4 5 (random) 1000 ];
femodel.el(9,:) = [ 1  4 6 (random) 1000 ];
femodel.el(10,:) =[ 1  5 6 (random) 1000 ];
femodel.el(11,:) =[ 1  5 7 (random) 1000 ];
femodel.el(12,:) =[ 1  5 8 (random) 1000 ];
femodel.el(13,:) =[ 1  6 7 (random) 1000 ];
femodel.el(14,:) =[ 1  6 8 (random) 1000 ];
femodel.el(15,:) =[ 1  7 8 (random) 1000 ];

femodel.loading(1,:) = [ 8 300000  1 1 ];

femodel.nodal_spring = 0;

femodel.fixed_dof(1,:) = [ 1  1 1 ];
femodel.fixed_dof(2,:) = [ 2  1 1 ];

for i = 1 : 15
   femodel.id(i,:) = [ i 2 i ];
end

gfundata(1).evaluator = 'FERUMlinearfecode';
gfundata(1).type = 'displacementlimit';
gfundata(1).parameter = 'yes';


gfundata(1).resp = [ 7  1 ];


gfundata(1).lim = 70.0;

randomfield.mesh = 0;