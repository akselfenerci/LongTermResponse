% SYSTEM RELIABILITY ANALYSIS

clear probdata femodel analysisopt gfundata randomfield systems results output_filename


% Define the name and type of the file to store the output of the analysis:
output_filename = 'outputfile_system.txt';

probdata.marg(1,:) =  [ 1  100   20   100 0 0 0 0 0];
probdata.marg(2,:) =  [ 1   15    3    15 0 0 0 0 0];
probdata.marg(3,:) =  [ 1    7  2.1     7 0 0 0 0 0];
probdata.marg(4,:) =  [ 1    5  1.5     5 0 0 0 0 0];

probdata.correlation = [1.0 0.2 0.0 0.0;
                        0.2 1.0 0.0 0.0;
                        0.0 0.0 1.0 0.3;
                        0.0 0.0 0.3 1.0];
                     
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
analysisopt.target_cov = 0.05;

femodel = 0;
randomfield = 0;

for i = 1 : 9
   gfundata(i).evaluator = 'basic';
   gfundata(i).type = 'expression';
   gfundata(i).parameter = 'no';
end

gfundata(1).expression = 'x(1)-4*x(3)-4*x(4)';
gfundata(2).expression = 'x(1)-2*x(3)-7*x(4)';
gfundata(3).expression = 'x(2)-0.2*x(3)-0.7*x(4)';
gfundata(4).expression = '2.5*x(1)-10*x(3)-5*x(4)';
gfundata(5).expression = 'x(1)-10*x(4)';
gfundata(6).expression = 'x(2)-0.05*x(1)-0.5*x(4)';
gfundata(7).expression = '2*x(1)-5*x(3)-10*x(4)';
gfundata(8).expression = '-x(1)+10*x(2)';
gfundata(9).expression = 'x(1)-10*x(3)-20*x(4)';

gfundata(1).dgdq = { '1'     '0'  '-4'   '-4'   };
gfundata(2).dgdq = { '1'     '0'  '-2'   '-7'   };
gfundata(3).dgdq = { '0'     '1'  '-0.2' '-0.7' };
gfundata(4).dgdq = { '2.5'   '0'  '-10'  '-5'   };
gfundata(5).dgdq = { '1'     '0'  '0'    '-10'  };
gfundata(6).dgdq = { '-0.05' '1'  '0'    '-0.5' };
gfundata(7).dgdq = { '2'     '0'  '-5'   '-10'  };
gfundata(8).dgdq = { '-1'    '10' '0'    '0'    };
gfundata(9).dgdq = { '1'     '0'  '-10'  '-20'  };

% Cutset Formulation
% (1)'-': compliment event
% (2)'0': divider between cutsets
% (3) the following 'system' corresonds to (e1e4)U(e1e5)U(e1e6)U(e2e7)U(e2e5c)U(e2e8)U(e3e9)
system.system = [1 4 0 1 5 0 1 6 0 2 7 0 0 2 -5 0 2 8 0 3 9 0]; 
system.scis_max = 20000;  % maximum no. of simulation for each scis (Default : 20000)
system.scis_min = 1000;   % minimum no. of simulation for each scis (Default : 1000)
system.cov_max  = 0.05;   % target c.o.v. of each scis (Default : 0.05)

% Note:
% (1) For series system: system.system=[-no.of events]
%      e.g. [-12] : series system with 12 events
% (2) For parallel system: system.system=[no.of events]
%      e.g. [13] : parallel system with 13 events
% (3) system.system=[1],[-1],[0],[] will be considered as component reliability problem