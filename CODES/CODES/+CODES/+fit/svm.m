classdef svm < CODES.fit.meta
    % Train an SVM (<a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/svm.html');web(file);">HTML</a>)
    % This class inherits from CODES.fit.meta and allows one to train an
    % SVM using advanced capabilities
    % <html>Copyright &copy; 2015 Computational Optimal Design of Engineering System Laboratory. University of Arizona.</html>\n%%\n
    properties(Access=public)
        theta               % Kernel parameters
        C                   % Cost parameters
        bias                % SVM bias (beta_0)
        xis                 % Slack variables
        alphas              % Lagrage multipliers
        SV                  % Support vectors
        param_select        % Parameters selection strategy
        w_plus              % Weight for the +1 samples
        w_minus             % Weight for the -1 samples
    end
    properties(Access=public,Hidden=true)
        beta                % Only for linear svm and primal solver
        K                   % Kernel function
    end
    properties(Access=protected,Hidden=true)
        kernel              % Kernel name
        zero_th=1e-4        % Thresholds to set xis and alphas to 0
        solver              % Solver to use to solve svm problem
        libsvm_model        % Libsvm problem
        SVs                 % Subset of support vectors
        SV_coeffs           % Support vector coefficient
        L                   % Loss
        theta_fixed         % Is theta fixed
        C_fixed             % Is C fixed
        use_weight          % Define if weight should be used
        default_weight      % Define if defult or user defined weight should be used
        psvm_type           % PSVM kind
        A                   % PSVM parameters
        enforce             % Whether or not to enforce no misclassification
    end
    methods(Access=public)
        function svm=svm(x,y,varargin)
            % Constructor of svm
            %
            % Syntax
            %   svm=CODES.fit.svm(x,y) trains an SVM on (x,y)
            %   svm=CODES.fit.svm(x,y,param,value) use parameters param and
            %   values value, refer to the <a
            %   href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/doc/html/svm.html');web(file);">HTML</a>
            %   documentation for details
            %
            % See also
            % eval
            input=inputParser;
            input.KeepUnmatched=true;
            input.PartialMatching=false;
            input.addOptional('theta',[],@isnumeric);       % Kernel parameters
            input.addOptional('kernel','gauss',...
                @(x)strcmpi(x,'gauss')||...
                strcmpi(x,'lin'));                          % Kernel function
            input.addOptional('solver','libsvm',...
                @(x)strcmpi(x,'libsvm')||...
                strcmpi(x,'dual')||...
                strcmpi(x,'primal'));                       % SVM solver
            input.addOptional('loss',1,@isnumeric);         % Loss function
            input.addOptional('C',1e4,@isnumeric);          % Cost parameter
            input.addOptional('weight',false,@islogical);   % Use weight
            input.addOptional('enforce',false,@islogical);  % Whether or not to enforce no misclassification
            input.addOptional('w_plus',1,@isnumeric);       % Weight for the +1 class
            input.addOptional('w_minus',1,@isnumeric);      % Weight for the -1 class
            input.addOptional('param_select','fast',...
                @(x)strcmpi(x,'fast')||...                  % Select sigma as mean distance + to -, C fixed
                strcmpi(x,'loo')||...                       % Select sigma and/or C using Leave one out
                strcmpi(x,'cv')||...                        % Select sigma and/or C using 10 fold cross validation
                strcmpi(x,'chapelle')||...                  % Select sigma and/or C using Leave one out estimate by chapelle
                strcmpi(x,'Nsv')||...                       % Select sigma and/or C to reduce number of support vectors
                strcmpi(x,'loo_bal')||...                   % Select sigma and/or C using Leave one out
                strcmpi(x,'cv_bal')||...                    % Select sigma and/or C using 10 fold cross validation
                strcmpi(x,'chapelle_bal')||...              % Select sigma and/or C using Leave one out estimate by chapelle
                strcmpi(x,'Nsv_bal')||...                   % Select sigma and/or C to reduce number of support vectors
                strcmpi(x,'auc')||...                       % Select sigma and/or C to maximize the auc
                strcmpi(x,'cv_auc')||...                    % Select sigma and/or C to maximize the cv auc
                strcmpi(x,'stiffest'));                     % Select sigma as max value without misclassification
            input.parse(varargin{:})
            in=input.Results;
            % Initialize
            svm=svm@CODES.fit.meta(x,y,input.Unmatched);
            % Test
            assert(any(svm.labels==+1) && any(svm.labels==-1),...
                'Needs labels from both class');
            assert(0<in.loss<=2,'Only L1 and L2 loss function');
            assert(in.C>0,'Cost parameter should be positive');
            if in.loss==2
                assert(~strcmpi(in.solver,'libsvm'),...
                    'L2 loss function not implemented for libsvm');
            end
            if strcmpi(in.solver,'primal')
                assert(strcmpi(in.kernel,'lin'),...
                    sprintf(...
                    ['Primal solver only implemented for linear SVM. ' ...
                    'For possible extensions, see:\n' ...
                    'Chapelle, O., (2007) ' ...
                    'Training a support vector machine in the primal.' ...
                    'Neural Computation, 19(5)1155-1178']));
            end
            if ~any(strcmp(input.UsingDefaults,'w_plus')) ||...
                    ~any(strcmp(input.UsingDefaults,'w_minus'))
                assert(in.weight,...
                    'To specify weight, weight option must be ''on''');
                assert(~any(strcmp(input.UsingDefaults,'w_plus')) &&...
                    ~any(strcmp(input.UsingDefaults,'w_minus')),...
                    'If one weight is specified the other must be too');
            end
            % Store
            svm.enforce=in.enforce;
            svm.solver=in.solver;
            svm.kernel=in.kernel;
            svm.L=in.loss;
            svm.C=in.C;
            svm.theta=in.theta;
            svm.param_select=in.param_select;
            if strcmpi(in.kernel,'lin')
                svm.theta_fixed=true;
            else
                svm.theta_fixed=~any(strcmp(input.UsingDefaults,'theta'));
            end
            svm.C_fixed=~any(strcmp(input.UsingDefaults,'C'));
            % Check for weight definition
            svm.w_plus=in.w_plus;
            svm.w_minus=in.w_minus;
            svm.use_weight=in.weight;
            svm.default_weight=any(strcmp(input.UsingDefaults,'w_plus'));
            % Train
            svm=svm.train;
        end
        function svm=train(svm)
            % Pre-process the data (scaling mainly), find best
            % kernel parameters and solve the SVM problem.
            % This function is not meant to be used on its own, but is
            % provided for advanced users
            %
            % Syntax
            %   svm=CODES.fit.svm.train train the SVM using option stored
            %   in svm
            %   
            % See also
            % solve
            svm=svm.pre_proc;
            if ~(svm.theta_fixed && svm.C_fixed)            % If theta and C are fixed, nothing to do
                if strcmpi(svm.param_select,'fast')         % If fast, find theta, use defined C
                    if ~svm.theta_fixed
                        [~,~,svm.theta]=svm.point_dist;
                    end
                elseif strcmpi(svm.param_select,'stiffest') % If stiffest, max sigma without miscalssification
                    ps_options=psoptimset('Display','off',...
                        'UseParallel',false);
                    [theta_min,theta_max,~]=svm.point_dist;
                    if svm.misc_err(theta_min)~=0
                        warning('Data do not seem to be separable')
                    end
                    svm.theta=patternsearch(@(theta)-2^theta,log2(theta_min),[],[],[],[],...
                        log2(theta_min),log2(theta_max),@(theta)svm.misc_err(2^theta),ps_options);
                    svm.theta=2^svm.theta;
                else
                    switch svm.param_select
                        case 'loo'                          % Find param using loo
                            obj=@(svm)svm.loo;
                        case 'cv'                           % Find param using 10 fold CV
                            obj=@(svm)svm.cv;
                        case 'Nsv'                          % Find param using number of support vectors
                            obj=@(svm)svm.N_sv_ratio;
                        case 'chapelle'                     % Find param using Chapelle estimate of leave one out
                            obj=@(svm)svm.chapelle;
                        case 'loo_bal'                      % Find param using balanced loo
                            obj=@(svm)svm.loo('use_balanced',true);
                        case 'cv_bal'                       % Find param using 10 fold balanced CV
                            obj=@(svm)svm.cv('use_balanced',true);
                        case 'Nsv_bal'                      % Find param using balanced number of support vectors
                            obj=@(svm)svm.N_sv_ratio(true);
                        case 'chapelle_bal'                 % Find param using Chapelle estimate of balanced leave one out
                            obj=@(svm)svm.chapelle(true);
                        case 'auc'                          % Find param using AUC
                            obj=@(svm)100-svm.auc(svm.X,svm.Y);
                        case 'cv_auc'                       % Find param using CV AUC
                            obj=@(svm)100-svm.cv('metric','auc');
                    end
                    ps_options=psoptimset('Display','off',...
                        'UseParallel',false);
                    fminbnd_options=optimset('Display','off');
                    if ~svm.theta_fixed
                        [theta_min,theta_max,theta_mean]=svm.point_dist;
                    end
                    if svm.theta_fixed                      % Theta fixed, only C to search
                        opti=fminbnd(@(C)svm.ps_obj(obj,svm.theta,10^C),...
                            0,6,fminbnd_options);
                        svm.C=10^opti;
                    elseif svm.C_fixed                      % C fixed, only theta to search
                        switch svm.param_select
                            case 'cv'
                                theta_candidate=2.^linspace(log2(theta_min),log2(theta_max),100);
                                perf=zeros(1,length(theta_candidate));
                                if svm.enforce
                                    misclass=zeros(1,length(theta_candidate));
                                end
                                for i=1:length(theta_candidate)
                                    if ~svm.enforce
                                        perf(i)=svm.ps_obj(obj,2^theta_candidate(i),svm.C);
                                    else
                                        [perf(i),misclass(i)]=svm.ps_obj(obj,2^theta_candidate(i),svm.C);
                                    end
                                end
                                if ~svm.enforce
                                    best=find(perf==min(perf),1,'last');
                                    svm.theta=theta_candidate(best);
                                else
                                    best=find(perf(misclass==0)==min(perf(misclass==0)),1,'last');
                                    svm.theta=theta_candidate(best);
                                end
                            otherwise
                                opti=fminbnd(@(theta)svm.ps_obj(obj,2^theta,svm.C),...
                                    log2(theta_min),log2(theta_max),fminbnd_options);
                                svm.theta=2^opti;
                        end
                    else                                    % Both theta and C to search
                        if strcmpi(svm.param_select,'cv_auc')
                            theta_candidate=2.^linspace(log2(theta_min),log2(theta_max),40);
                            C_candidate=10.^linspace(-2,3,40);
%                             perf_val=zeros(length(theta_candidate),length(C_candidate));
                            perf_val=zeros(40,40);
                            perf_fct=@(theta,C)svm.ps_obj(obj,theta,C);
                            parfor i=1:40
                                for j=1:40
                                    perf_val(i,j)=perf_fct(theta_candidate(i),C_candidate(j)); %#ok<PFBNS>
                                end
                            end
                            [theta_ind,C_ind]=find(perf_val==min(perf_val(:)));
                            svm.theta=theta_candidate(theta_ind);
                            svm.C=C_candidate(C_ind);
                        else
                            opti=patternsearch(...
                                @(params)svm.ps_obj(obj,2^params(1),10^params(2)),...
                                [log2(theta_mean) 2],[],[],[],[],...
                                [log2(theta_min) 0],[log2(theta_max) 6],...
                                [],ps_options);
                            svm.theta=2^opti(1);
                            svm.C=10^opti(2);
                        end
                    end
                end
            end
            svm=svm.solve;                                  % Solve the svm problem
        end
        function svm=solve(svm)
            % Simply solve the SVM optimization problem
            % This function is not meant to be used on its own, but is
            % provided for advanced users
            %
            % Syntax
            %   svm=CODES.fit.svm.solve solve the SVM  optimization problem
            %   using option stored in svm
            %   
            % See also
            % train
            switch svm.kernel
                case 'gauss'
                    svm.K=@(x,y)CODES.fit.build.gauss(x,y,svm.theta);
                case 'lin'
                    svm.K=@(x,y)CODES.fit.build.linear(x,y);
            end
            switch svm.solver
                case 'primal'
                    svm=svm.solve_primal;
                case 'dual'
                    svm=svm.solve_dual;
                case 'libsvm'
                    svm=svm.solve_libsvm;
            end
            % Get support vectors
            svm.SV=svm.alphas>0;
            svm.SVs=svm.X_sc(svm.SV,:);
            svm.SV_coeffs=svm.labels(svm.SV,:).*svm.alphas(svm.SV,:);
        end
        function varargout=eval(svm,x)
            % Evaluate new samples x
            %
            % Syntax
            %   y_hat=CODES.fit.svm.eval(x) return the SVM values y_hat of
            %   the samples x
            %   [y_hat,grad]=CODES.fit.svm.eval(x) return the gradients at
            %   x
            %   
            % See also
            % svm
            eval@CODES.fit.meta(svm,x)
            x_sc=svm.scale(x);
            if nargout<2
                K_val=svm.K(x_sc,svm.SVs);
            else
                [K_val,dK_val]=svm.K(x_sc,svm.SVs);
            end
            varargout{1}=K_val*svm.SV_coeffs+svm.bias;
            if nargout>1    % Add grad of the mean
                grad=permute(sum(bsxfun(@times,permute(dK_val,[3 1 2]),...
                                               svm.SV_coeffs'),...
                                 2),...
                             [1 3 2]);
                varargout{2}=grad*diag(svm.scalers);
            end
        end
        function [lb,ub,mean_dist]=point_dist(svm)
            % Returns the minimum, maximum and mean values of the pairwise
            % distances between +1 and -1 samples of svm
            % The mean value is used as initial guess for theta
            %
            % Syntax
            %   [lb,ub,mean_dist]=CODES.fit.svm.point_dist returns the
            %   minimum lb, maximum ub and mean mean_dist values of the
            %   pairwise distances between +1 and -1 samples of svm
            dist=pdist2(svm.X_sc(svm.labels==1,:),svm.X_sc(svm.labels==-1,:));
            lb=min(dist(:));
            ub=max(dist(:));
            mean_dist=mean(dist(:));
        end
        function nb_sv=N_sv_ratio(svm,use_balanced)
            % Returns the support vector ratio (%)
            %
            % Syntax
            %   stat=CODES.fit.svm.N_sv_ratio return the support vector
            %   ratio stat
            %   stat=CODES.fit.svm.N_sv_ratio(use_balanced) returns the
            %   balanced support vector ratio if use_balanced is set to
            %   true
            %   
            % See also
            % loo cv chapelle auc
            if nargin==1
                use_balanced=false;
            end
            assert(islogical(use_balanced),...
                'Argument ''use_balanced'' should be logical');
            if use_balanced
                weights=svm.wm*ones(svm.n,1);
                weights(svm.labels==+1,:)=svm.wp;
                nb_sv=100*mean(weights.*svm.SV);
            else
                nb_sv=100*mean(svm.SV);
            end
        end
        function loo_chapelle=chapelle(svm,use_balanced)
            % Returns Chapelle estimate of the loo error (%)
            % Based on <a href="http://olivier.chapelle.cc/ams/fast_span_estimate.m">fast_span_estimate.m</a>
            %
            % Syntax
            %   stat=CODES.fit.svm.chapelle return the Chapelle estimate of
            %   the loo error stat 
            %   stat=CODES.fit.svm.chapelle(true) return the balanced
            %   Chapelle estimate of the loo error 
            %   
            % See also
            % N_sv_ratio loo cv auc
            if nargin==1
                use_balanced=false;
            end
            assert(islogical(use_balanced),...
                'Argument ''use_balanced'' should be logical');
            if use_balanced
                weights=svm.wm*ones(svm.n,1);
                weights(svm.labels==+1,:)=svm.wp;
            end
            % Compute kernel values
            K_m=svm.K(svm.X_sc,svm.X_sc);
            % Compute the outputs on the training points
            output=svm.labels.*svm.eval(svm.X);
            % Find bounded and unbounded SVs
            sv1=svm.alphas>max(svm.alphas)*svm.zero_th &...
                svm.alphas<svm.C*(1-svm.zero_th);           % Unbounded SV
            sv2=svm.alphas>svm.C*(1-svm.zero_th);           % Bounded SV
            % Degenerate case: if sv1 is empty, then we assume nothing
            % changes (loo = training error)
            if sum(sv1)==0
                if use_balanced
                    loo_chapelle=100*mean(weights.*(output<0));
                else
                    loo_chapelle=100*mean(output<0);
                end
                return;
            end
            % Compute the invert of KSV
            l=sum(sv1);
            KSV=[[K_m(sv1,sv1) ones(l,1)]; [ones(1,l) 0]];
            % A small ridge is added to be sure that the matrix is
            % invertible 
            invKSV=inv(KSV+diag(eps*[ones(1,l) 0]));
            % Compute the span for all support vectors.
            span=zeros(svm.n,1);                            % Initialize the vector
            tmp=diag(invKSV);
            span(sv1)=1./tmp(1:l);                          % Span of unbounded SV
            % If there exists sv of second category, compute their span
            if sum(sv2)~=0
                V=[K_m(sv1,sv2);ones(1,sum(sv2))];
                span(sv2)=diag(K_m(sv2,sv2))-diag(V'*invKSV*V); %#ok<MINV>
            end
            if use_balanced
                loo_chapelle=100*mean(weights.*(output-svm.alphas.*span<0));
            else
                loo_chapelle=100*mean(output-svm.alphas.*span<0);
            end
        end
        function varargout=isoplot(svm,varargin)
            % Display the 0 isocontour of the SVM svm
            %
            % Syntax
            %   CODES.fit.svm.isoplot plot the meta-model
            %   CODES.fit.svm.isoplot(param,value) use set of parameters
            %   param and values value, refer to the <a
            %   href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/svm.html');web(file);">HTML</a>
            %   documentation for details
            %   h=CODES.fit.svm.isoplot(...) returns graphical handles
            %   
            % See also
            % plot
            input=inputParser;
            input.KeepUnmatched=true;
            input.addOptional('sv',true,@islogical);        % Plot support vectors
            input.addOptional('msvsty','r+',@isstr);        % -1 samples style
            input.addOptional('psvsty','b+',@isstr);        % +1 samples style
            input.addOptional('legend',true,@islogical);    % Add legend
            input.parse(varargin{:})
            in=input.Results;
            [handles,leg]=isoplot@CODES.fit.meta(svm,input.Unmatched,'legend',in.legend);
            if in.sv
                X_sv=svm.X(svm.SV,:);
                labels_sv=svm.labels(svm.SV,:);
                hold on
                switch svm.dim
                    case 1
                        minus_h=plot(X_sv(labels_sv==-1,:),zeros(sum(labels_sv==-1),1),in.msvsty);
                        plus_h=plot(X_sv(labels_sv==+1,:),zeros(sum(labels_sv==+1),1),in.psvsty);
                    case 2
                        minus_h=plot(X_sv(labels_sv==-1,1),X_sv(labels_sv==-1,2),in.msvsty);
                        plus_h=plot(X_sv(labels_sv==+1,1),X_sv(labels_sv==+1,2),in.psvsty);
                    case 3
                        minus_h=plot3(X_sv(labels_sv==-1,1),X_sv(labels_sv==-1,2),X_sv(labels_sv==-1,3),in.msvsty);
                        plus_h=plot3(X_sv(labels_sv==+1,1),X_sv(labels_sv==+1,2),X_sv(labels_sv==+1,3),in.psvsty);
                end
                if in.legend
                    leg=[leg {'-1 SV' '+1 SV'}];
                    legend(leg{:},'Location','southeast');
                end
            end
            if nargout~=0
                if in.sv
                    varargout{1}=[handles minus_h plus_h];
                else
                    varargout{1}=handles;
                end
            end
        end
    end
    methods(Access=protected,Hidden=true)
        function svm=pre_proc(svm)
            % Pre-process the data
            svm=pre_proc@CODES.fit.meta(svm);
            if svm.use_weight && svm.default_weight
                svm.w_plus=svm.wp;
                svm.w_minus=svm.wm;
            end
        end
        function svm=solve_primal(svm)
            % Solve the linear svm problem in the primal
            opt=optimset('algorithm','interior-point-convex','TolFun',1e-6,'TolX',1e-6,'TolCon',1e-6,'display','off');
            C_vec=zeros(svm.n,1);
            C_vec(svm.labels>0)=svm.w_plus*svm.C;
            C_vec(svm.labels<0)=svm.w_minus*svm.C;
            switch svm.L
                case 1
                    H=[[eye(svm.dim) zeros(svm.dim,svm.n+1)];zeros(svm.n+1,svm.dim+svm.n+1)];
                    F=[zeros(svm.dim+1,1);C_vec];
                case 2
                    H=[[eye(svm.dim) zeros(svm.dim,svm.n+1)];zeros(1,svm.dim+svm.n+1);[zeros(svm.n,svm.dim+1) diag(C_vec)]];
                    F=zeros(svm.dim+svm.n+1,1);
            end
            [solutions,~,~,~,lambdas]=quadprog(H,F,...
                [-bsxfun(@times,svm.labels,svm.X_sc) -svm.labels -eye(svm.n)],-ones(svm.n,1),[],[],...
                [-Inf*ones(svm.dim+1,1);zeros(svm.n,1)],[],[],opt);
            svm.beta=solutions(1:svm.dim);
            svm.bias=solutions(svm.dim+1);
            svm.xis=solutions(svm.dim+2:end);
            svm.alphas=lambdas.ineqlin;
            svm.alphas(svm.alphas<svm.zero_th)=0;
            svm.xis(svm.xis<svm.zero_th)=0;
        end
        function svm=solve_dual(svm)
            % Solve the non linear svm problem in the dual
            opt=optimset('algorithm','interior-point-convex','TolFun',1e-6,'TolX',1e-6,'TolCon',1e-6,'display','off');
            switch svm.L
                case 1
                    H=(svm.labels*svm.labels').*svm.K(svm.X_sc,svm.X_sc);
                    ub=svm.C*ones(svm.n,1);
                case 2
                    H=(svm.labels*svm.labels').*(svm.K(svm.X_sc*svm.X_sc)+1/svm.C*eye(svm.n));
                    ub=Inf*ones(svm.n,1);
            end
            F=-ones(svm.n,1);
            solutions=quadprog(H,F,...
                [],[],svm.labels',0,...
                zeros(svm.n,1),ub,[],opt);
            svm.alphas=solutions;
            svm.alphas(svm.alphas<svm.zero_th)=0;
            svm.bias=mean(svm.labels(svm.alphas>0,:)-svm.K(svm.X_sc(svm.alphas>0,:),svm.X_sc(svm.alphas>0,:))*(svm.labels(svm.alphas>0,:).*svm.alphas(svm.alphas>0,:)));
            svm.xis=1-svm.labels.*(svm.K(svm.X_sc,svm.X_sc(svm.alphas>0,:))*(svm.labels(svm.alphas>0,:).*svm.alphas(svm.alphas>0,:))+svm.bias);
            svm.xis(svm.xis<svm.zero_th)=0;
        end
        function svm=solve_libsvm(svm)
            % Solve the SVM problem using libsvm
            switch svm.kernel
                case 'gauss'
                    svm.libsvm_model=CODES.fit.libsvm.svmtrain(svm.labels,svm.X_sc,...
                        ['-q -c ' num2str(svm.C) ' -g ' num2str(svm.sigma2gamma(svm.theta)) ...
                        ' -w1 ',num2str(svm.w_plus),' -w-1 ',num2str(svm.w_minus)]);
                case 'lin'
                    svm.libsvm_model=CODES.fit.libsvm.svmtrain(svm.labels,svm.X_sc,...
                        ['-q -t 0 -c ' num2str(svm.C) ...
                        ' -w1 ',num2str(svm.w_plus),' -w-1 ',num2str(svm.w_minus)]);
            end
            svm.bias=-svm.libsvm_model.rho;
            svm.alphas=zeros(svm.n,1);
            svm.alphas(svm.libsvm_model.sv_indices)=svm.libsvm_model.sv_coef.*svm.labels(svm.libsvm_model.sv_indices,:);
            svm.xis=1-svm.labels.*(svm.K(svm.X_sc,svm.X_sc(svm.alphas>0,:))*(svm.labels(svm.alphas>0,:).*svm.alphas(svm.alphas>0,:))+svm.bias);
            svm.xis(svm.xis<svm.zero_th)=0;
        end
        function gamma=sigma2gamma(~,sigma)
            % Convert sigma to gamma (libsvm convention)
            gamma=1./(2*sigma.^2);
        end
        function varargout=ps_obj(svm,perf,theta,C)
            % Compute the performance of a given set of parameters theta
            % and C
            svm.theta=theta;svm.C=C;
            svm=svm.solve;
            varargout{1}=perf(svm);
            if nargout>1
                varargout{2}=svm.me(svm.X,svm.Y);
            end
        end
        function [err,ceq]=misc_err(svm,theta)
            % Compute the performance of a given set of parameters theta
            % and C
            svm.theta=theta;
            svm=svm.solve;
            err=svm.me(svm.X,svm.Y);
            ceq=[];
        end
    end
end
