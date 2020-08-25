% FRAME EXAMPLE

clear probdata femodel analysisopt gfundata randomfield systems results output_filename

output_filename = 'outputfile_frame.txt';

mean_P = 300000;
mean_E = 200000;
mean_I = 0.5E+9;
mean_A = 5000;
random = 0;

for i = 1 : 10
   probdata.marg(i,:) = [ 1  mean_E   0.1*mean_E   mean_E 0 0 0 0 0]; 
end

for i = 11 : 20
   probdata.marg(i,:) = [ 1  mean_I   0.1*mean_I   mean_I 0 0 0 0 0]; 
end

for i = 21 : 30
   probdata.marg(i,:) = [ 1  mean_A   0.1*mean_A   mean_A 0 0 0 0 0]; 
end

probdata.marg(31,:) =   [ 2  mean_P   0.15*mean_P  mean_P 0 0 0 0 0];

probdata.correlation = eye(31);

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
analysisopt.target_cov = 0.05;

femodel.ndf = 3;

femodel.node(1,:) =  [  0            0       ];
femodel.node(2,:) =  [  7500         0       ];
femodel.node(3,:) =  [  15000        0       ];
femodel.node(4,:) =  [  0            3000    ];
femodel.node(5,:) =  [  7500         3000    ];
femodel.node(6,:) =  [  15000        3000    ];
femodel.node(7,:) =  [  0            6000    ];
femodel.node(8,:) =  [  7500         6000    ];
femodel.node(9,:) =  [  15000        6000    ];

femodel.el(1,:) =  [ 2  1  4 (random) (random) (random)  ];
femodel.el(2,:) =  [ 2  2  5 (random) (random) (random)  ];
femodel.el(3,:) =  [ 2  3  6 (random) (random) (random)  ];
femodel.el(4,:) =  [ 2  4  5 (random) (random) (random)  ];
femodel.el(5,:) =  [ 2  5  6 (random) (random) (random)  ];
femodel.el(6,:) =  [ 2  4  7 (random) (random) (random)  ];
femodel.el(7,:) =  [ 2  5  8 (random) (random) (random)  ];
femodel.el(8,:) =  [ 2  6  9 (random) (random) (random)  ];
femodel.el(9,:) =  [ 2  7  8 (random) (random) (random)  ];
femodel.el(10,:) = [ 2  8  9 (random) (random) (random)  ];

femodel.loading(1,:) = [ 4  (random)  1   1   ];
femodel.loading(2,:) = [ 7  (random)  1   2   ];

femodel.nodal_spring = 0;

femodel.fixed_dof(1,:) = [ 1   1 1 1 ];
femodel.fixed_dof(2,:) = [ 2   1 1 1 ];
femodel.fixed_dof(3,:) = [ 3   1 1 1 ];

for i = 1 : 10
   femodel.id(i,:) = [ i   2   i     ];
end
for i = 11 : 20
   femodel.id(i,:) = [ i   3  (i-10) ];
end
for i = 21 : 30
   femodel.id(i,:) = [ i   4  (i-20) ];
end
femodel.id(31,:) =   [ 31  1   1   ];
femodel.id(32,:) =   [ 31  1   2   ];

gfundata(1).evaluator = 'FERUMlinearfecode';
gfundata(1).type = 'displacementlimit';
gfundata(1).parameter = 'no';
gfundata(1).resp = [ 9  1 ];
gfundata(1).lim = 45;

randomfield.mesh = 0;