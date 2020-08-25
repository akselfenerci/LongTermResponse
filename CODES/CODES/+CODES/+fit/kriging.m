classdef kriging < CODES.fit.meta
    % Train a Kriging (<a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/kriging.html');web(file);">HTML</a>)
    % This class inherits from CODES.fit.meta and allows one to train a
    % Kriging using advanced capabilities
    % <html>Copyright &copy; 2015 Computational Optimal Design of Engineering System Laboratory. University of Arizona.</html>\n%%\n
    
    properties(Access=public)
        Y_sc                % Scaled training values
        sigma_y_2           % Estimated variance of the output
        sigma_n_2           % Training output variance
        beta                % Kringing mean function parameters
        theta               % Kriging covariance function parameters
        L                   % Choleski decomposition of covaraince matrix of the training samples
        scalers_y           % Scaling value for gradients (y)
    end
    properties(Access=public,Hidden=true)
        dace_model          % Dace model
    end
    properties(Access=protected)
        solver_type         % Sovler type, CODES or DACE
        theta_min           % Lower bound on theta
        theta_max           % Upper bound on theta
        theta_fixed         % Is theta fixed
        display             % Display level
        mean_fun_name       % Kringing mean function name
        mean_fun            % Kringing mean function
        mean_basis          % Matrix of basis function for mean
        mean_jac            % Jacobian matric of the mean function
        cov_fun_name        % Kriging covariance function
        cov_fun             % Kriging covariance function
        alpha               % alpha factor for prediction
        residual            % Residuals for integral criterion
        regression          % Wether regression or not
        delta_2             % nugget (sigma_n/sigma_y)^2
        fixed_delta_2       % Wether sigma_n_2 is fixed or not
        LR                  % Intermediate lower choleski decomposition of covariance matrix
        scale_method_y      % Scale method for the values: 'square', 'circle' or 'none'
        mean_y              % Mean of Y
        std_y               % Standard deviation of Y
        lb_y                % Lower bound on Y
        ub_y                % Upper bound on Y
    end
    methods(Access=public)
        function kr=kriging(x,y,varargin)
            % Constructor of kriging
            %
            % Syntax
            %   svm=CODES.fit.svm(x,y) trains an Kriging on (x,y)
            %   svm=CODES.fit.svm(x,y,param,value) use parameters param and
            %   values value, refer to the <a
            %   href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/doc/html/kriging.html');web(file);">HTML</a>
            %   documentation for details
            %
            % See also
            % eval
            input=inputParser;
            input.KeepUnmatched=true;
            input.PartialMatching=false;
            input.addOptional('theta',[],@isnumeric);               % Kernel hyper-parameter
            input.addOptional('delta_2',0,@isnumeric);              % Nugget for regression
            input.addOptional('mean_fun','poly0',...
                @(x)strcmpi(x,'poly0'));                            % Mean function
            input.addOptional('cov_fun','gauss',...
                @(x)strcmpi(x,'gauss'));                            % Covariance function
            input.addOptional('scale_y','square',...
                @(x)strcmpi(x,'square')||...
                strcmpi(x,'circle')||...
                strcmpi(x,'none'));                                 % Scaling of the ouput
            input.addOptional('solver','CODES',...
                @(x)strcmpi(x,'CODES')||...
                strcmpi(x,'DACE'));                                 % Kriging solver
            input.addOptional('regression',false,@islogical);       % Enable regression
            input.addOptional('display',true,@islogical);           % Display output
            input.addOptional('theta_min',[],@isnumeric);           % Minimum value for theta (DACE)
            input.addOptional('theta_max',[],@isnumeric);           % Maximum value for theta (DACE)
%             input.addOptional('full_LH',false,@islogical);        % Future feature
            input.parse(varargin{:})
            in=input.Results;
            unmatched=input.Unmatched;
            % Pre checks
            if strcmpi(in.solver,'DACE')
                unmatched.scale='none';
                in.scale_y='none';
            end
            % Initialize
            kr=kr@CODES.fit.meta(x,y,unmatched);
            % Protection
            assert(size(unique(kr.X,'rows'),1)==size(kr.X,1),'Design sites must be unique');
            assert(size(kr.X,1)~=1,'More than one design site is needed to build a kriging');
            if strcmpi(in.solver,'CODES')
                assert(any(strcmp(input.UsingDefaults,'theta_min')) && any(strcmp(input.UsingDefaults,'theta_max')),'''theta_min'' and ''theta_max'' require ''solver'' to be set to ''DACE''');
            end
            if strcmpi(in.solver,'DACE')
                assert(~any(strcmp(input.UsingDefaults,'theta')),'''theta'' must be defined when ''solver'' is set to ''DACE''');
                assert(any(strcmp(input.UsingDefaults,'delta_2')),'''delta_2'' requires ''solver'' to be set to ''CODES''');
                if any(strcmp(input.UsingDefaults,'mean_fun'))
                    in.mean_fun=@CODES.fit.dace.regpoly0;
                else
                    assert(isa(in.mean_fun,'function_handle'),'''mean_fun'' must be a function_handle if ''solver'' is set to ''DACE''');
                end
                if any(strcmp(input.UsingDefaults,'cov_fun'))
                    in.cov_fun=@CODES.fit.dace.corrgauss;
                else
                    assert(isa(in.cov_fun,'function_handle'),'''cov_fun'' must be a function_handle if ''solver'' is set to ''DACE''');
                end
                if ~any(strcmp(input.UsingDefaults,'theta_min')) || ~any(strcmp(input.UsingDefaults,'theta_max'))
                    assert(~any(strcmp(input.UsingDefaults,'theta_min')) && ~any(strcmp(input.UsingDefaults,'theta_max')),'Both bounds ''theta_min'' and ''theta_max'' must be defined if any is');
                end
            end
            % Store
            kr.regression=in.regression;
            kr.mean_fun_name=in.mean_fun;
            kr.cov_fun_name=in.cov_fun;
            kr.scale_method_y=in.scale_y;
            kr.display=in.display;
            kr.delta_2=in.delta_2;
            kr.fixed_delta_2=~any(strcmp(input.UsingDefaults,'delta_2'));
            kr.theta_fixed=any(strcmp(input.UsingDefaults,'theta_min'));
            kr.theta=in.theta;
            kr.theta_min=in.theta_min;
            kr.theta_max=in.theta_max;
            kr.solver_type=in.solver;
            % Train
            kr=kr.train;
        end
        function y_sc=scale_y(kr,y)
            % Perform scaling of y
            %
            % Syntax
            %   y_sc=CODES.fit.meta.scale_y(y_unsc) scale y_unsc
            %
            % See also
            % unscale_y
            switch kr.scale_method_y
                case 'square'
                    y_sc=bsxfun(@rdivide,bsxfun(@minus,y,kr.lb_y),kr.ub_y-kr.lb_y);
                case 'circle'
                    y_sc=bsxfun(@rdivide,bsxfun(@minus,y,kr.mean_y),kr.std_y);
                case 'none'
                    y_sc=y;
            end
        end
        function y=unscale_y(kr,y_sc)
            % Perform unscaling of y
            %
            % Syntax
            %   y_sc=CODES.fit.meta.unscale_y(y_unsc) scale y_unsc
            %
            % See also
            % scale_y
            switch kr.scale_method_y
                case 'square'
                    y=bsxfun(@plus,bsxfun(@times,y_sc,kr.ub_y-kr.lb_y),kr.lb_y);
                case 'circle'
                    y=bsxfun(@plus,bsxfun(@times,y_sc,kr.std_y),kr.mean_y);
                case 'none'
                    y=y_sc;
            end
        end
        function kr=train(kr)
            % Pre-process the data (scaling mainly), find best
            % hyper-parameters and train kriging.
            % This function is not meant to be used on its own, but is
            % provided for advanced users
            %
            % Syntax
            %   kr=CODES.fit.kriging.train train the kriging using option
            %   stored in kr
            %   
            % See also
            % solve
            kr=kr.pre_proc;
            switch upper(kr.solver_type)
                case 'CODES'
                    % Selection of hyper-parameters
                    [min_theta,max_theta,mean_theta]=kr.point_dist;      
                    options=psoptimset('Display','none','InitialMeshSize',0.7,...
                        'SearchMethod',@MADSPositiveBasis2N,'TolMesh',10^-3,'MeshExpansion',6);
                    min_theta=min_theta/5;max_theta=max_theta*5;
                    range_log_theta=log10(max_theta)-log10(min_theta);
                    if kr.regression && ~kr.fixed_delta_2
                        optimum=patternsearch(@(x)-kr.redLogLH(10^(x(1)*range_log_theta+log10(min_theta)),x(2)^2),...
                            [(log10(mean_theta)-log10(min_theta))/range_log_theta 0],[],[],[],[],[0 0],[1 1],[],options);
                        kr.theta=10^(optimum(1)*range_log_theta+log10(min_theta));
                        kr.delta_2=optimum(2)^2;
                    else
                        kr.theta=patternsearch(@(x)-kr.redLogLH(10^(x*range_log_theta+log10(min_theta))),...
                            (log10(mean_theta)-log10(min_theta))/range_log_theta,[],[],[],[],0,1,[],options);
                        kr.theta=10^(kr.theta*range_log_theta+log10(min_theta));
                    end
                    kr=kr.solve;
                case 'DACE'
                    if kr.theta_fixed
                        kr.dace_model=CODES.fit.dace.dacefit(kr.X,kr.Y,kr.mean_fun_name,kr.cov_fun_name,kr.theta);
                    else
                        kr.dace_model=CODES.fit.dace.dacefit(kr.X,kr.Y,kr.mean_fun_name,kr.cov_fun_name,kr.theta,kr.theta_min,kr.theta_max);
                    end
            end
        end
        function kr=solve(kr)
            % Simply train the kriging.
            % This function is not meant to be used on its own, but is
            % provided for advanced users
            %
            % Syntax
            %   kr=CODES.fit.kriging.solve train the kriging using option
            %   stored in kr
            %   
            % See also
            % train
            switch kr.mean_fun_name
                case 'poly0'
                    kr.mean_fun=@(x,beta)repmat(beta,size(x,1),1);
                    kr.mean_basis=ones(size(kr.X_sc,1),1);
                    kr.mean_jac=@(x)zeros(1,kr.dim,size(x,1));
            end
            switch kr.cov_fun_name
                case 'gauss'
                    kr.cov_fun=@CODES.fit.build.gauss;
            end
            % Compute Kriging elements
            R=kr.cov_fun(kr.X_sc,kr.X_sc,kr.theta)+kr.delta_2*eye(kr.n);
            corr=(10+kr.n)*eps;p=1;
            while p~=0
                [kr.LR,p]=chol(R+corr*eye(kr.n),'lower');
                corr=corr+(10+kr.n)*eps;                    % Add conditioning if need be
            end
            if kr.display && corr~=2*(10+kr.n)*eps
                warning('Had to condition R');
            end
            kr.beta=(kr.mean_basis'*(kr.LR'\(kr.LR\kr.mean_basis)))\(kr.mean_basis'*(kr.LR'\(kr.LR\kr.Y_sc)));
            kr.residual=kr.Y_sc-kr.mean_fun(kr.X_sc,kr.beta);
            kr.sigma_y_2=kr.residual'*(kr.LR'\(kr.LR\kr.residual))/(kr.n);
            kr.sigma_n_2=kr.sigma_y_2*kr.delta_2;
            kr.L=sqrt(kr.sigma_y_2)*kr.LR;
            kr.alpha=kr.L'\(kr.L\kr.residual);
        end
        function kr=add(kr,x,y)
            % Retrain kr after adding a new sample (x,y)
            %
            % Syntax
            %   kr=CODES.fit.kriging.add(x,y) add a new sample x with
            %   function value y
            assert(size(unique([kr.X;x],'rows'),1)==size([kr.X;x],1),'Design sites must be unique');
            kr=add@CODES.fit.meta(kr,x,y);
        end
        function varargout=eval(kr,x)
            % Evaluate prediction at new samples x
            %
            % Syntax
            %   y_hat=CODES.fit.kriging.eval(x) return the Kriging
            %   predictor values y_hat of the samples x
            %   [y_hat,grad]=CODES.fit.kriging.eval(x) return the gradients
            %   at x
            %   
            % See also
            % eval_var eval_all P_pos
            eval@CODES.fit.meta(kr,x)
            switch upper(kr.solver_type)
                case 'CODES'
                    x_sc=kr.scale(x);                                                                   % Scale data
                    if nargout<2
                        sigma_partial=kr.cov_fun(x_sc,kr.X_sc,kr.theta);
                        sigma_partial=kr.sigma_y_2*sigma_partial';
                    else
                        [sigma_partial,cov_jac]=kr.cov_fun(x_sc,kr.X_sc,kr.theta);
                        sigma_partial=kr.sigma_y_2*sigma_partial';cov_jac=kr.sigma_y_2*cov_jac;         % Add the variance to the covariance matrix
                    end
                    varargout{1}=kr.unscale_y(kr.mean_fun(x_sc,kr.beta)+sigma_partial'*kr.alpha);       % Return the mean
                    if nargout>1                                                                        % Add grad of the mean
                        grad=permute(sum(bsxfun(@times,kr.mean_jac(x_sc),kr.beta),1),[3 2 1])+permute(sum(bsxfun(@times,cov_jac,kr.alpha),1),[3 2 1]);
                        varargout{2}=grad*diag(kr.scalers)/kr.scalers_y;
                    end
                case 'DACE'
                    if nargout<2
                        varargout{1}=CODES.fit.dace.predictor(x,kr.dace_model);
                    else
                        varargout{1}=zeros(size(x,1),1);
                        varargout{2}=zeros(kr.dim,size(x,1));
                        for i=1:size(x,1)                                                       % Forced to loop due to DACE code
                            [varargout{1}(i,:),varargout{2}(:,i)]=CODES.fit.dace.predictor(x(i,:),kr.dace_model);
                        end
                        varargout{2}=varargout{2}';
                    end
            end
        end
        function varargout=eval_var(kr,x)
            % Evaluate prediction variance at samples x
            %
            % Syntax
            %   y_hat=CODES.fit.kriging.eval_var(x) return the Kriging
            %   predictor variance y_hat of the samples x
            %   [y_hat,grad]=CODES.fit.kriging.eval(x) return the gradients
            %   at x
            %   
            % See also
            % eval eval_all P_pos
            assert(size(x,2)==kr.dim,['Dimension of x should be ' num2str(kr.dim) ' instead of ' num2str(size(x,2)) '.'])
            switch kr.solver_type
                case 'CODES'
                    x_sc=kr.scale(x);                                                                   % Scale data
                    if nargout<2
                        sigma_partial=kr.cov_fun(x_sc,kr.X_sc,kr.theta);
                        sigma_partial=kr.sigma_y_2*sigma_partial';
                    else
                        [sigma_partial,cov_jac]=kr.cov_fun(x_sc,kr.X_sc,kr.theta);
                        sigma_partial=kr.sigma_y_2*sigma_partial';cov_jac=kr.sigma_y_2*cov_jac;         % Add the variance to the correlation matrix
                    end
                    v=kr.L\sigma_partial;
                    varargout{1}=abs(kr.sigma_y_2*(ones(size(x_sc,1),1)+kr.delta_2)-sum(v.^2,1)')/kr.scalers_y^2;
                    if nargout>1                                                                        % Add grad of the variance
                        grad_sigma=permute(sum(bsxfun(@times,-2*permute(cov_jac,[2 1 3]),permute((kr.L'\(kr.L\sigma_partial)),[3 1 2])),2),[3 1 2]);
                        varargout{2}=grad_sigma*diag(kr.scalers)/kr.scalers_y^2;
                    end
                case 'DACE'
                    if nargout<2
                        if size(x,1)~=1
                            [~,varargout{1}]=CODES.fit.dace.predictor(x,kr.dace_model);
                        else
                            [~,temp]=CODES.fit.dace.predictor([x;x],kr.dace_model);
                            varargout{1}=temp(1,:);
                        end
                    else
                        varargout{1}=zeros(size(x,1),1);
                        varargout{2}=zeros(kr.dim,size(x,1));
                        for i=1:size(x,1)                                                       % Forced to loop due to DACE code
                            [~,~,varargout{1}(i,:),varargout{2}(:,i)]=CODES.fit.dace.predictor(x(i,:),kr.dace_model);
                        end
                        varargout{2}=varargout{2}';
                    end
            end
        end
        function varargout=eval_all(kr,x)
            % Evaluate prediction value and variance at x
            %
            % Syntax
            %   y_hat=CODES.fit.kriging.eval(x) return the Kriging
            %   predictor values y_hat of the samples x
            %   [y_hat,var_hat]=CODES.fit.kriging.eval(x) return the
            %   Kriging predictor variance var_hat
            %   [y_hat,var_hat,dy]=CODES.fit.kriging.eval(x) returns the
            %   gradient of the prediction dy
            %   [y_hat,var_hat,dy,dvar]=CODES.fit.kriging.eval(x) return
            %   the gradient of the prediction variance dvar
            %   
            % See also
            % eval eval_var P_pos
            assert(size(x,2)==kr.dim,['Dimension of x should be ' num2str(kr.dim) ' instead of ' num2str(size(x,2)) '.'])
            switch upper(kr.solver_type)
                case 'CODES'
                    x_sc=kr.scale(x);                                                                   % Scale data
                    if nargout<3
                        sigma_partial=kr.cov_fun(x_sc,kr.X_sc,kr.theta);
                        sigma_partial=kr.sigma_y_2*sigma_partial';
                    else
                        [sigma_partial,cov_jac]=kr.cov_fun(x_sc,kr.X_sc,kr.theta);
                        sigma_partial=kr.sigma_y_2*sigma_partial';cov_jac=kr.sigma_y_2*cov_jac;         % Add the the variance
                    end
                    varargout{1}=kr.unscale_y(kr.mean_fun(x_sc,kr.beta)+sigma_partial'*kr.alpha);       % Return the mean
                    if nargout>1                                                                        % Add the the variance
                        v=kr.L\sigma_partial;
                        varargout{2}=abs(kr.sigma_y_2*(ones(size(x_sc,1),1)+kr.delta_2)-sum(v.^2,1)')/kr.scalers_y^2;
                    end
                    if nargout>2                                                                        % Add grad of the mean
                        grad=permute(sum(bsxfun(@times,kr.mean_jac(x_sc),kr.beta),1),[3 2 1])+permute(sum(bsxfun(@times,cov_jac,kr.alpha),1),[3 2 1]);
                        varargout{3}=grad*diag(kr.scalers)/kr.scalers_y;
                    end
                    if nargout>3                                                                        % Add grad of the variance
                        grad_sigma=permute(sum(bsxfun(@times,-2*permute(cov_jac,[2 1 3]),permute((kr.L'\(kr.L\sigma_partial)),[3 1 2])),2),[3 1 2]);
                        varargout{4}=grad_sigma*diag(kr.scalers)/kr.scalers_y^2;
                    end
                case 'DACE'
                    switch nargout
                        case 1
                            varargout{1}=CODES.fit.dace.predictor(x,kr.dace_model);
                        case 2
                            if size(x,1)~=1
                                [varargout{1},varargout{2}]=CODES.fit.dace.predictor(x,kr.dace_model);
                            else
                                [temp1,temp2]=CODES.fit.dace.predictor([x;x],kr.dace_model);
                                varargout{1}=temp1(1,:);
                                varargout{2}=temp2(1,:);
                            end
                        case 3
                            nb_x=size(x,1);
                            varargout{1}=zeros(nb_x,1);
                            varargout{2}=zeros(nb_x,1);
                            varargout{3}=zeros(kr.dim,nb_x);
                            for i=1:nb_x
                                [varargout{1}(i,:),varargout{3}(:,i),varargout{2}(i,:)]=CODES.fit.dace.predictor(x(i,:),kr.dace_model);
                            end
                            varargout{3}=varargout{3}';
                        case 4
                            nb_x=size(x,1);
                            varargout{1}=zeros(nb_x,1);
                            varargout{2}=zeros(nb_x,1);
                            varargout{3}=zeros(kr.dim,nb_x);
                            varargout{4}=zeros(kr.dim,nb_x);
                            for i=1:nb_x
                                [varargout{1}(i,:),varargout{3}(:,i),varargout{2}(i,:),varargout{4}(:,i)]=CODES.fit.dace.predictor(x(i,:),kr.dace_model);
                            end
                            varargout{3}=varargout{3}';
                            varargout{4}=varargout{4}';
                    end
            end
        end
        function varargout=P_pos(kr,x,threshold)
            % Compute the probability of the kriging prediction to be
            % higher than a threshold
            %
            % Syntax
            %   p=CODES.fit.kriging.P_pos(x) return the probability of
            %   the prediction to be higher then 0
            %   p=CODES.fit.kriging.P_pos(x,th) return the probability
            %   of the prediction to be higher then th
            %   [p,dp]=CODES.fit.kriging.eval(x) return the gradient of the
            %   probabilities dp
            %   
            % See also
            % eval eval_var eval_all
            if nargin<3
                threshold=0;
            end
            if nargout>1
                [mean,var,grad_mean,grad_var]=kr.eval_all(x);
                sigma=sqrt(var);
                grad_sigma=0.5*bsxfun(@rdivide,grad_var,sigma);
                varargout{1}=1-normcdf(threshold,mean,sigma);
                varargout{2}=bsxfun(@times,...
                                            bsxfun(@rdivide,bsxfun(@times,grad_mean,sigma)...
                                            +bsxfun(@times,grad_sigma,(threshold-mean))...
                                            ,sigma.^2)...
                                    ,normpdf((threshold-mean)./sigma));
            else
                [mean,var]=kr.eval_all(x);
                varargout{1}=1-normcdf(threshold,mean,sqrt(var));
            end
        end
        function logL=redLogLH(kr,theta,delta_2)
            % Compute the reduced log likelihood
            %
            % Syntax
            %   lh=CODES.fit.kriging.redLogLH return the log likelihood
            %   using the parameters stored in kr
            %   lh=CODES.fit.kriging.redLogLH(theta) return the log
            %   likelihood using theta
            %   lh=CODES.fit.kriging.redLogLH(theta,delta_2) return the log
            %   likelihood using delta_2
            if nargin>2
                kr.delta_2=delta_2;
            end
            if nargin>1
                kr.theta=theta;
            end
            kr=kr.solve;
            logL=-0.5*kr.n*log(kr.sigma_y_2)-sum(log(diag(kr.LR)));
        end
        function varargout=plot(kr,varargin)
            % Display the kriging
            %
            % Syntax
            %   CODES.fit.kriging.plot plot the kriging
            %   CODES.fit.kriging.plot(param,value) use set of parameters
            %   param and values value, refer to the <a
            %   href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/doc/html/kriging.html');web(file);">HTML</a>
            %   documentation for details
            %   h=CODES.fit.kriging.plot(...) returns graphical handles
            input=inputParser;
            input.KeepUnmatched=true;
            input.addOptional('new_fig',false,@islogical);  % Create a new figure
            input.addOptional('CI',true,@islogical);        % Confidence interval
            input.addOptional('alpha',0.05,@isnumeric);     % Confidence level
            input.addOptional('CI_color','k',@(x)...
                ischar(x)||all(size(x)==[1 3]));            % Confidence level
            input.addOptional('CI_alpha',0.3,@isnumeric);   % Transparence level
            input.addOptional('lb',kr.lb_x,@isnumeric);     % Lower bound of plot
            input.addOptional('ub',kr.ub_x,@isnumeric);     % Upper bound of plot
            input.addOptional('legend',true,@islogical);    % Add legend
            input.addOptional('prev_leg',{},@iscell);       % Previous legend entry
            input.parse(varargin{:})
            in=input.Results;
            if in.new_fig
                figure('Position',[200 200 500 500])
            end
            lq=in.alpha/2;
            uq=1-in.alpha/2;
            if in.CI
                switch kr.dim
                    case 1
                        x_l=linspace(in.lb,in.ub,100)';
                        [mean_kr,var_kr]=kr.eval_all(x_l);
                        CI=bsxfun(@plus,mean_kr,bsxfun(@times,sqrt(var_kr),norminv([lq uq])));
                        CI_h=fill([x_l;flipud(x_l)],[CI(:,1);flipud(CI(:,2))],in.CI_color,'FaceAlpha',in.CI_alpha,'EdgeColor','none');
                        hold on
                    case 2
                        [X_g,Y_g]=meshgrid(linspace(in.lb(1),in.ub(1),100),...
                                       linspace(in.lb(2),in.ub(2),100));
                        [mean_kr,var_kr]=kr.eval_all([X_g(:) Y_g(:)]);
                        CI=bsxfun(@plus,mean_kr,bsxfun(@times,sqrt(var_kr),norminv([lq uq])));
                        CI_h=zeros(1,2);
                        CI_h(1)=mesh(X_g,Y_g,reshape(CI(:,1),size(X_g)),'EdgeColor','none','FaceColor',in.CI_color,'FaceAlpha',in.CI_alpha);
                        hold on
                        CI_h(2)=mesh(X_g,Y_g,reshape(CI(:,2),size(X_g)),'EdgeColor','none','FaceColor',in.CI_color,'FaceAlpha',in.CI_alpha,'HandleVisibility','off');
                end
                [handles,leg]=plot@CODES.fit.meta(kr,input.Unmatched,...
                    'legend',in.legend,'lb',in.lb,'ub',in.ub);
                if in.legend
                    leg=[in.prev_leg {['Kriging ' num2str(100-100*in.alpha) '% CI']} leg];
                    legend(leg{:},'Location','southeast');
                end
            else
                [handles,leg]=plot@CODES.fit.meta(kr,input.Unmatched,...
                    'legend',in.legend,'prev_leg',in.prev_leg,'lb',in.lb,'ub',in.ub);
            end
            if nargout~=0
                if in.CI
                    varargout{1}=[handles CI_h];
                else
                    varargout{1}=handles;
                end
            end
            if nargout>1
                varargout{2}=leg;
            end
        end
    end
    methods(Access=protected,Hidden=true)
        function kr=pre_proc(kr)
            % Pre-process the data
            kr=pre_proc@CODES.fit.meta(kr);
            kr.mean_y=mean(kr.Y);
            kr.std_y=std(kr.Y);
            kr.lb_y=min(kr.Y);
            kr.ub_y=max(kr.Y);
            kr.Y_sc=kr.scale_y(kr.Y);
            switch kr.scale_method_y
                case 'square'
                    kr.scalers_y=1./(kr.ub_y-kr.lb_y);
                case 'circle'
                    kr.scalers_y=1./(kr.std_y);
                case 'none'
                    kr.scalers_y=1;
            end
        end
    end
    methods(Access=public,Hidden=true)
        function val=EF(kr,x,k,q)
            % Expected feasibility
            % q=1 : EGRA (Bichon 2008)
            % q=2 : Ranjan 2008
            if nargin<4
                q=1;
            end
            if nargin<3
                k=2;
            end
            [mean,var]=kr.eval_all(x);
            std=sqrt(var);
            t=-mean./std;
            tp=t+k;
            tm=t-k;
            switch q
                case 1
                    val=std.*(...
                        k.*(normcdf(tp)-normcdf(tm))...
                        -t.*(2*normcdf(t)-normcdf(tp)-normcdf(tm))...
                        -(2*normpdf(t)-normpdf(tp)-normpdf(tm)));
                case 2
                    val=std.^2.*(...
                        (k^2-1-t.^2).*(normcdf(tp)-normcdf(tm))...
                        -2*t.*(normpdf(tp)-normpdf(tm))...
                        +tp.*normpdf(tp)-tm.*normpdf(tm));
            end
        end
    end
end
