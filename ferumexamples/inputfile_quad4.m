% QUAD4 EXAMPLE

clear probdata femodel analysisopt gfundata randomfield systems results output_filename

% Define the name and type of the file to store the output of the analysis:
output_filename = 'ouputfile_quad4.txt';

mean_E = 200000;
nu = 0.25;
thick = 1.0;
random = 0;

probdata.marg(1,:) =  [ 2  mean_E   0.2*mean_E  mean_E 0 0 0 0 0];
probdata.marg(2,:) =  [ 2  mean_E   0.2*mean_E  mean_E 0 0 0 0 0];
probdata.marg(3,:) =  [ 2  mean_E   0.2*mean_E  mean_E 0 0 0 0 0];
probdata.marg(4,:) =  [ 2  mean_E   0.2*mean_E  mean_E 0 0 0 0 0];

probdata.correlation= eye(4);

probdata.parameter = distribution_parameter(probdata.marg);

analysisopt.ig_max = 100;
analysisopt.il_max = 5;
analysisopt.e1 = 0.001;
analysisopt.e2 = 0.001; 
analysisopt.step_code = 0;
analysisopt.grad_flag = 'DDM';
analysisopt.sim_point = 'dspt';
analysisopt.stdv_sim  = 1;
analysisopt.num_sim   = 10000;
analysisopt.target_cov = 0.025;

femodel.ndf = 2;

femodel.node(1,:) = [   0.0     0.0    ];
femodel.node(2,:) = [   4.0     0.0    ];
femodel.node(3,:) = [  10.0     0.0    ];
femodel.node(4,:) = [   0.0     4.5    ];
femodel.node(5,:) = [   5.5     5.5    ];
femodel.node(6,:) = [  10.0     5.0    ];
femodel.node(7,:) = [   0.0    10.0    ];
femodel.node(8,:) = [   4.2    10.0    ];
femodel.node(9,:) = [  10.0    10.0    ];

femodel.el(1,:) = [ 3  1  2  5  4  (random) nu thick 1 ];
femodel.el(2,:) = [ 3  2  3  6  5  (random) nu thick 1 ];
femodel.el(3,:) = [ 3  5  6  9  8  (random) nu thick 1 ];
femodel.el(4,:) = [ 3  4  5  8  7  (random) nu thick 1 ];

femodel.loading(1,:) = [ 6   100000   1    1.0  ];

femodel.nodal_spring=0;

femodel.fixed_dof(1,:) = [ 1   1 1 ];
femodel.fixed_dof(2,:) = [ 4   1 0 ];
femodel.fixed_dof(3,:) = [ 7   1 0 ];

femodel.id(1,:) = [  1   2   1  ];
femodel.id(2,:) = [  2   2   2  ];
femodel.id(3,:) = [  3   2   3  ];
femodel.id(4,:) = [  4   2   4  ];
   
gfundata(1).evaluator = 'FERUMlinearfecode';
gfundata(1).type = 'displacementlimit';
gfundata(1).parameter = 'no';
gfundata(1).resp = [  6  1  ];
gfundata(1).lim = 1.0 ;

randomfield.mesh = 0;

