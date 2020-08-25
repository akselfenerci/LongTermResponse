% Inverse Reliability problem

clear probdata femodel analysisopt gfundata randomfield systems results output_filename


output_filename = 'outputfile_inverse_form.txt';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DATA FIELDS IN 'PROBDATA':
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

probdata.marg(1,:) =  [ 1  0   1   0.2  0 0 0 0 0];
probdata.marg(2,:) =  [ 1  0   1   0.2  0 0 0 0 0];
probdata.marg(3,:) =  [ 1  0   1   0.2  0 0 0 0 0];
probdata.marg(4,:) =  [ 1  0   1   0.2  0 0 0 0 0];

% Determine the parameters,the mean and standard deviation associated with the distribution of each random variable
probdata.parameter = distribution_parameter(probdata.marg);

% Correlation matrix (square matrix with dimension equal to number of r.v.'s)
probdata.correlation = eye(4);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DATA FIELDS IN 'ANALYSISOPT':
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

analysisopt.ig_max = 100;        % Maximum number of iterations allowed in the search algorithm
analysisopt.il_max = 5;
analysisopt.e1 = 0.001;         % Tolerance on how close design point is to limit-state surface
analysisopt.e2 = 0.001;         % Tolerance on how accurately the gradient points towards the origin
analysisopt.step_code = 0;      % 0: step size by Armijo rule, otherwise: given value is the step size.
analysisopt.grad_flag = 'ddm';  % 'DDM': direct differentiation, 'FFD': forward finite difference

% Simulation analysis
analysisopt.sim_point = 'dspt'; % 'dspt': design point, 'origin': origin in standard normal space (simulation analysis)
analysisopt.stdv_sim  = 1;      % Standard deviation of sampling distribution in simulation analysis
analysisopt.num_sim   = 1000;   % Number of simulations in simulation analysis
analysisopt.target_cov = 0.05;  % Target coefficient of variation of failure probability in simulation analysis

% Inverse FORM analysis
analysisopt.e3 = 0.001;         % Tolerance on how close to beta target is the solution point 
analysisopt.beta_target = 2;    % Target value for the index of reliability

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DATA FIELDS IN 'GFUNDATA' (one structure per gfun):
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Type of limit-state function evaluator
% (Alternatives: 'basic', 'FERUMlinearfecode', 'FERUMnonlinearfecode', 'fedeas')
gfundata(1).evaluator = 'basic';
gfundata(1).type = 'expression';
gfundata(1).parameter = 'no';


% In case of 'expression' limit-state function and Inverse FORM analysis
gfundata(1).deterministic_parameter_start_value = 0.1 ;
gfundata(1).expression = 'exp(-theta(1)*(x(1)+ 2*x(2) + 3*x(3))) - x(4) + 1.5';
% Give explicit derivative expressions with respect to the deterministic parameter if DDM is used :
gfundata(1).dgdq = { '-  theta(1)*exp(-theta(1)*(x(1)+ 2*x(2) + 3*x(3)))' ;
   						'-2*theta(1)*exp(-theta(1)*(x(1)+ 2*x(2) + 3*x(3)))';
							'-3*theta(1)*exp(-theta(1)*(x(1)+ 2*x(2) + 3*x(3)))';
							'-1'};


gfundata(1).dgdthetadeter = { '-(x(1)+ 2*x(2) + 3*x(3))*exp(-theta(1)*(x(1)+ 2*x(2) + 3*x(3)))'};


femodel = 0;
randomfield.mesh = 0;

