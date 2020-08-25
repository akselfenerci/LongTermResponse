% FRAME EXAMPLE

clear probdata femodel analysisopt gfundata randomfield systems results output_filename

output_filename = 'outputfile_frame 99rvs_invers_problem.txt';

% Define random variables
% Load P1 to P5
mean_P_1_5 = 60;
% Load P6
mean_P6 = 30;
% Load P7 and P9
mean_P_7_9 = 100;
% Load P_8
mean_P8 = 200;

% E side column members (ksi)
mean_E_side = 28000;
% E center column members (ksi)
mean_E_center = 30000;
% E beam column members (ksi)
mean_E_beam = 26000;

% A side column members (sq in.)
mean_A_side = 21;
% A center column members (sq in.)
mean_A_center = 26.9;
% A beam column members (sq in.)
mean_A_beam = 16.0;

% I side column members (in.e4)
mean_I_side = 2100;
% I center column members (in.e4)
mean_I_center = 2690;
% I beam column members (in.e4)
mean_I_beam = 1600;


random = 0;
% A coefficient of variation of 0.1 is choosen for all the variables


for i = 1 : 12
   probdata.marg(i,:) = [ 2  mean_E_side   0.1*mean_E_side   mean_E_side 0 0 0 0 0]; 
end
for i = 13 : 18
   probdata.marg(i,:) = [ 2  mean_E_center   0.1*mean_E_center   mean_E_center 0 0 0 0 0]; 
end
for i = 19 : 30
   probdata.marg(i,:) = [ 2  mean_E_beam   0.1*mean_E_beam   mean_E_beam 0 0 0 0 0]; 
end

for i = 31 : 42
   probdata.marg(i,:) = [ 2  mean_A_side   0.1*mean_A_side   mean_A_side 0 0 0 0 0]; 
end
for i = 43 : 48
   probdata.marg(i,:) = [ 2  mean_A_center   0.1*mean_A_center   mean_A_center 0 0 0 0 0]; 
end
for i = 49 : 60
   probdata.marg(i,:) = [ 2  mean_A_beam   0.1*mean_A_beam   mean_A_beam 0 0 0 0 0]; 
end

for i = 61 : 72
   probdata.marg(i,:) = [ 2  mean_I_side   0.1*mean_I_side   mean_I_side 0 0 0 0 0]; 
end
for i = 73 : 78
   probdata.marg(i,:) = [ 2  mean_I_center   0.1*mean_I_center   mean_I_center 0 0 0 0 0]; 
end
for i = 79 : 90
   probdata.marg(i,:) = [ 2  mean_I_beam   0.1*mean_I_beam   mean_I_beam 0 0 0 0 0]; 
end


for i = 91:95
   probdata.marg(i,:) = [ 2  mean_P_1_5   0.1*mean_P_1_5  mean_P_1_5 0 0 0 0 0];
end
probdata.marg(96,:) =   [ 2  mean_P6      0.1*mean_P6     mean_P6 0 0 0 0 0];
probdata.marg(97,:) =   [ 2  mean_P_7_9   0.1*mean_P_7_9  mean_P_7_9 0 0 0 0 0];
probdata.marg(98,:) =   [ 2  mean_P8      0.1*mean_P8     mean_P8 0 0 0 0 0];
probdata.marg(99,:) =   [ 2  mean_P_7_9   0.1*mean_P_7_9  mean_P_7_9 0 0 0 0 0];

probdata.correlation = eye(99);

probdata.parameter = distribution_parameter(probdata.marg);

analysisopt.ig_max     = 100;
analysisopt.il_max     = 5;
analysisopt.e1        = 0.001;
analysisopt.e2        = 0.001; 
analysisopt.step_code = 0;
analysisopt.grad_flag = 'ddm';
analysisopt.sim_point = 'dspt';
analysisopt.stdv_sim  = 1;
analysisopt.num_sim   = 1000;
analysisopt.target_cov = 0.05;

analysisopt.e3 = 0.001;
analysisopt.beta_target = 2.16;    % Target value for the index of reliability

femodel.ndf = 3;


% Define the nodes of the frame
counter = 0;
for i=1:21
   femodel.node(i,:) =  [  300*mod(i-1,3)    120*counter  ];
   if mod(i,3)==0
      counter = counter + 1;
   end
end

% Define the element
femodel.el(1,:) =   [ 2  1  4 (random) (random) (random)  ];
femodel.el(2,:) =   [ 2  2  5 (random) (random) (random)  ];
femodel.el(3,:) =   [ 2  3  6 (random) (random) (random)  ];
femodel.el(4,:) =   [ 2  4  5 (random) (random) (random)  ];
femodel.el(5,:) =   [ 2  5  6 (random) (random) (random)  ];
femodel.el(6,:) =   [ 2  4  7 (random) (random) (random)  ];
femodel.el(7,:) =   [ 2  5  8 (random) (random) (random)  ];
femodel.el(8,:) =   [ 2  6  9 (random) (random) (random)  ];
femodel.el(9,:) =   [ 2  7  8 (random) (random) (random)  ];
femodel.el(10,:) =  [ 2  8  9 (random) (random) (random)  ];
femodel.el(11,:) =  [ 2  7  10 (random) (random) (random)  ];
femodel.el(12,:) =  [ 2  8  11 (random) (random) (random)  ];
femodel.el(13,:) =  [ 2  9  12 (random) (random) (random)  ];
femodel.el(14,:) =  [ 2  10 11 (random) (random) (random)  ];
femodel.el(15,:) =  [ 2  11 12 (random) (random) (random)  ];
femodel.el(16,:) =  [ 2  10 13 (random) (random) (random)  ];
femodel.el(17,:) =  [ 2  11 14 (random) (random) (random)  ];
femodel.el(18,:) =  [ 2  12 15 (random) (random) (random)  ];
femodel.el(19,:) =  [ 2  13 14 (random) (random) (random)  ];
femodel.el(20,:) =  [ 2  14 15 (random) (random) (random)  ];
femodel.el(21,:) =  [ 2  13 16 (random) (random) (random)  ];
femodel.el(22,:) =  [ 2  14 17 (random) (random) (random)  ];
femodel.el(23,:) =  [ 2  15 18 (random) (random) (random)  ];
femodel.el(24,:) =  [ 2  16 17 (random) (random) (random)  ];
femodel.el(25,:) =  [ 2  17 18 (random) (random) (random)  ];
femodel.el(26,:) =  [ 2  16 19 (random) (random) (random)  ];
femodel.el(27,:) =  [ 2  17 20 (random) (random) (random)  ];
femodel.el(28,:) =  [ 2  18 21 (random) (random) (random)  ];
femodel.el(29,:) =  [ 2  19 20 (random) (random) (random)  ];
femodel.el(30,:) =  [ 2  20 21 (random) (random) (random)  ];



% Define the loads
femodel.loading(1,:) = [ 4   (random)  1   1   ];
femodel.loading(2,:) = [ 7   (random)  1   1   ];
femodel.loading(3,:) = [ 10  (random)  1   1   ];
femodel.loading(4,:) = [ 13  (random)  1   1   ];
femodel.loading(5,:) = [ 16  (random)  1   1   ];
femodel.loading(6,:) = [ 19  (random)  1   1   ];
femodel.loading(7,:) = [ 19  (random)  -2   1   ];
femodel.loading(8,:) = [ 20  (random)  -2   1   ];
femodel.loading(9,:) = [ 21  (random)  -2   1   ];

femodel.nodal_spring = 0;

femodel.fixed_dof(1,:) = [ 1   1 1 1 ];
femodel.fixed_dof(2,:) = [ 2   1 1 1 ];
femodel.fixed_dof(3,:) = [ 3   1 1 1 ];

for i = 1 : 6
   femodel.id(i,:) = [ i   2    6*(i-1)-(i-2)    ];
end
for i = 7 : 12
   femodel.id(i,:) = [ i   2    6*(i-7)-(i-8)+ 2 ];
end
for i = 13 : 18
   femodel.id(i,:) = [ i   2    6*(i-13)-(i-14)+ 1 ];
end
%for i = 19 : 30
femodel.id(19,:) = [ 19   2   4  ];
femodel.id(20,:) = [ 20   2   5  ];
femodel.id(21,:) = [ 21   2   9  ];
femodel.id(22,:) = [ 22   2   10 ];
femodel.id(23,:) = [ 23   2   14 ];
femodel.id(24,:) = [ 24   2   15  ];
femodel.id(25,:) = [ 25   2   19  ];
femodel.id(26,:) = [ 26   2   20  ];
femodel.id(27,:) = [ 27   2   24  ];
femodel.id(28,:) = [ 28   2   25  ];
femodel.id(29,:) = [ 29   2   29  ];
femodel.id(30,:) = [ 30   2   30  ];
%end

for i = 31 : 36
   femodel.id(i,:) = [ i   4    6*(i-31)-(i-32)    ];
end
for i = 37 : 42
   femodel.id(i,:) = [ i   4    6*(i-37)-(i-38)+ 2 ];
end
for i = 43 : 48
   femodel.id(i,:) = [ i   4    6*(i-43)-(i-44)+ 1 ];
end

%for i = 49 : 60
femodel.id(49,:) = [ 49   4   4  ];
femodel.id(50,:) = [ 50   4   5  ];
femodel.id(51,:) = [ 51   4   9  ];
femodel.id(52,:) = [ 52   4   10 ];
femodel.id(53,:) = [ 53   4   14 ];
femodel.id(54,:) = [ 54   4   15  ];
femodel.id(55,:) = [ 55   4   19  ];
femodel.id(56,:) = [ 56   4   20  ];
femodel.id(57,:) = [ 57   4   24  ];
femodel.id(58,:) = [ 58   4   25  ];
femodel.id(59,:) = [ 59   4   29  ];
femodel.id(60,:) = [ 60   4   30  ];
%end

for i = 61 : 66
   femodel.id(i,:) = [ i   3    6*(i-61)-(i-62)    ];
end
for i = 67 : 72
   femodel.id(i,:) = [ i   3    6*(i-67)-(i-68)+ 2 ];
end
for i = 73 : 78
   femodel.id(i,:) = [ i   3    6*(i-73)-(i-74)+ 1 ];
end

%for i = 79 : 90
femodel.id(79,:) = [ 79   3   4  ];
femodel.id(80,:) = [ 80   3   5  ];
femodel.id(81,:) = [ 81   3   9  ];
femodel.id(82,:) = [ 82   3   10 ];
femodel.id(83,:) = [ 83   3   14 ];
femodel.id(84,:) = [ 84   3   15  ];
femodel.id(85,:) = [ 85   3   19  ];
femodel.id(86,:) = [ 86   3   20  ];
femodel.id(87,:) = [ 87   3   24  ];
femodel.id(88,:) = [ 88   3   25  ];
femodel.id(89,:) = [ 89   3   29  ];
femodel.id(90,:) = [ 90   3   30  ];
%end

for i = 91:99
	femodel.id(i,:) =   [ i  1   (i-90)   ];
end


gfundata(1).evaluator = 'FERUMlinearfecode';
gfundata(1).type = 'displacementlimit';
gfundata(1).parameter = 'no';
gfundata(1).resp = [ 21  1 ];
gfundata(1).deterministic_parameter_start_value = 40 ;
gfundata(1).lim = 'theta(1)';

gfundata(1).dgdthetadeter = { '1'};


randomfield.mesh = 0;