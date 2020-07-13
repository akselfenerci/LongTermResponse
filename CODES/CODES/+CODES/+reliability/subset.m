function res=subset(limit_state,dim,varargin)
    % Perform a Subset Simulation
    % Reference : *Au & Beck "Estimation of small failure probabilities in
    % high dimensions by subset simulation" 2001

    % Initialize
    input=inputParser;
    input.addRequired('LS',@(x)isa(x,'function_handle'));   % Limit State
    input.addRequired('dim',@(x)isnumeric(x));              % Dim
    input.addOptional('PDFs_target',[],...
        @(x)isa(x,'function_handle'));                      % Target marginal PDFs to draw MCMC samples from
    input.addOptional('sampler',[],...
        @(x)isempty(x)||isa(x,'function_handle'));          % Function that produces samples (For the first subset)
    input.addOptional('prop_rand',@(x)normrnd(x,ones(size(x))),...
        @(x)isa(x,'function_handle'));                      % Proposal sampler to create new samples
    input.addOptional('CoV',1,@isnumeric);                  % CoV for first subset
    input.addOptional('N',[],@isnumeric);                   % Fixed Number of point
    input.addOptional('CoV_bound',false,@islogical);        % Compute real CoV interval or not
    input.addOptional('step_Pf',0.1,@isnumeric);            % Define sub Pfs
    input.addOptional('verbose',false,@islogical);
    input.addOptional('burnin',0,@isnumeric);               % Burnin for MCMC
    input.addOptional('store',false,@islogical);            % Specify if points used should be stored
    input.addOptional('Pf_limit',1e-8,@isnumeric);          % Pf at wich to stop if reached
    input.addOptional('vectorial',false,@islogical);        % Is the limit_state vectorial
    input.addOptional('lnPDF',[],...
        @(x)isa(x,'function_handle'));                      % Log of joint PDF as a function of (x,theta) for dPfdtheta
    input.addOptional('dlnPDF',[],...
        @(x)isa(x,'function_handle'));                      % Derivative of log of joint PDF with respect to theta as a function of (x,theta)for dPfdtheta
    input.addOptional('theta',[],@isnumeric);               % Theta value for dPfdtheta
    input.addOptional('nz',[],@isnumeric);                  % # of z variables for dPfdz
    input.addOptional('frac',0.5,@isnumeric);               % alpha fraction for dPfdz
    input.addOptional('dirac','gauss',@(x)...
        strcmpi(x,'gauss')||...
        strcmpi(x,'tgauss')||...
        strcmpi(x,'poisson')||...
        strcmpi(x,'sinc')||...
        strcmpi(x,'bump'));                                 % Dirac approximation function
    input.addOptional('recall','off',...
        @(x)(strcmpi(x,'on')||strcmpi(x,'off')));           % Specify if options should be stored, for recall puposes for example
    input.parse(limit_state,dim,varargin{:});
    in=input.Results;
    in.isdef=@(p)isdefault(input,p);
    % Check
    if ~any(strcmpi(input.UsingDefaults,'PDFs_target')) ||...
            ~any(strcmpi(input.UsingDefaults,'sampler'))
        assert(~any(strcmpi(input.UsingDefaults,'PDFs_target'))&&...
            ~any(strcmpi(input.UsingDefaults,'sampler')),...
            'Either both ''PDFs_target'' and ''sampler'' are provided, or none')
    end
    if ~in.isdef('lnPDF') || ~in.isdef('dlnPDF')
        assert(in.isdef('lnPDF') || in.isdef('dlnPDF'),...
            'Only one of ''lnPDF'' and ''dlnPDF'' can be passed as argument')
    end
    if ~in.isdef('lnPDF')
        assert(~in.isdef('theta'),...
            '''theta'' value must be provided for dPf/dtheta')
    end
    if ~in.isdef('theta')
        assert(size(in.theta,1)==1,'''theta'' should be a row vector')
        assert(~in.isdef('lnPDF'),...
            ['''lnPDF''must be passed as'...
            'argument with ''theta'' to compute dPf/dtheta'])
        compute_dPfdtheta=true;
    elseif ~in.isdef('dlnPDF')
        compute_dPfdtheta=true;
    else
        compute_dPfdtheta=false;
    end
    compute_dPfdz=~in.isdef('nz');
    % Initialize
    if any(strcmpi(input.UsingDefaults,'PDFs_target'))
        in.PDFs_target=@(x)normpdf(x);
        in.sampler=@(N)normrnd(0,1,N,in.dim);
    end
    setappdata(0,'subset_ls_count',0);
    LS=@(x,th)eval(x,in,th,compute_dPfdz);
    if ~any(strcmp(input.UsingDefaults,'N'))                % If provided, define number of points per step
        step_N=in.N;
    else                                                    % Number of point to achieve given CoV for first step instead
        step_N=floor(points(in.step_Pf,in.CoV/100));
    end
    max_step=ceil(log10(in.Pf_limit)/log10(in.step_Pf));    % Maximum number of step based of Pf limit
    Nc=floor(step_N*in.step_Pf);                            % Number or Markov Chain
    N_Nc=floor(1/in.step_Pf);                               % Number of samples per Markov Chain
    % Display if asked for
    if in.verbose
        disp(['Points per step : ' num2str(step_N)])
        disp(['Maximum Step : ' num2str(max_step)])
        disp(['Chains : ' num2str(Nc)])
        disp(['Points per chains : ' num2str(N_Nc)])
    end
    % Prepare storage if requested
    if in.store
        X=cell(max_step,1);
    end
    if in.store || compute_dPfdz
        Y=cell(max_step,1);
        if compute_dPfdz
            dY=cell(max_step,1);
        end
    end
    thresholds=zeros(max_step,1);
    Pfs=zeros(max_step,1);
    % Compute initial set of points
    X_step=in.sampler(step_N);
    steps=1;
    if compute_dPfdz
        [Y_step,dY_step]=LS(X_step,0);
    else
        Y_step=LS(X_step,0);
    end
    function_calls=step_N;
    [~,ind]=sort(Y_step);
    if in.store
        X{steps}=X_step;
    end
    if in.store || compute_dPfdz
        Y{steps}=Y_step;
        if compute_dPfdz
            dY{steps}=dY_step;
        end
    end
    thresholds(steps)=max(0,mean(Y_step(ind(Nc:(Nc+1)))));
    if compute_dPfdtheta && ~in.isdef('lnPDF')
        % Use lnPDF
        dPfdtheta=zeros(max_step,size(in.theta,2));
        temp=zeros(sum(Y_step<=thresholds(steps)),size(in.theta,2));
        k=1;
        for i=1:size(Y_step,1)
            if Y_step(i)<=thresholds(steps)
                temp(k,:)=CODES.common.grad_fd(...
                    @(theta)in.lnPDF(X_step(i,:),theta),in.theta,...
                    'vectorial',false);
                k=k+1;
            end
        end
        dPfdtheta(steps,:)=sum(temp,1)/size(Y_step,1);
    elseif compute_dPfdtheta
        % use dlnPDF
        temp=sum(in.dlnPDF(X_step(Y_step<=thresholds(steps),:)),1)/size(Y_step,1);
        dPfdtheta=zeros(max_step,size(temp,2));
        dPfdtheta(steps,:)=temp;
    end
    Pfs(steps)=mean(Y_step<=thresholds(steps));
    % Display if asked for
    if in.verbose
        disp(['Step : ' num2str(steps)])
        disp(['Threshold : ' num2str(thresholds(steps))])
        disp(['Current Pf : ' num2str(prod(Pfs(1:steps)))])
        disp(['Current # of function calls : ' num2str(function_calls)])
    end
    % Compute CoV of initial step (if asked for)
    if in.CoV_bound
        CoV=zeros(max_step,1);
        CoV(steps)=variation(Pfs(steps),step_N);
    end
    % Proceed until reaching Threshold 0
    while thresholds(steps)>0 && steps<max_step
        % Compute a new set of point (using modified MH as proposed by Au & Beck (2001)
        if ~compute_dPfdz
            [X_step,Y_step,rejection_calls]=CODES.common.mcmc(X_step(ind(1:Nc),:),...
                N_Nc,in.PDFs_target,...
                'initial_values',Y_step(ind(1:Nc),:)-thresholds(steps),...
                'rejection',@(x)LS(x,thresholds(steps)),...
                'prop_rand',in.prop_rand,'burnin',in.burnin);
        else
            [X_step,Y_step,rejection_calls,dY_step]=CODES.common.mcmc(X_step(ind(1:Nc),:),...
                N_Nc,in.PDFs_target,...
                'initial_values',Y_step(ind(1:Nc),:)-thresholds(steps),...
                'initial_gradients',dY_step(ind(1:Nc),:),...
                'rejection',@(x)LS(x,thresholds(steps)),'gradient',true,...
                'prop_rand',in.prop_rand,'burnin',in.burnin);
            dY_step=flat(dY_step);
        end
        X_step=flat(X_step);
        Y_step=reshape(Y_step,size(Y_step,1)*size(Y_step,3),1)+thresholds(steps);   % Recover function values
        function_calls=function_calls+rejection_calls;
        [~,ind]=sort(Y_step);
        steps=steps+1;
        % Store if requested
        if in.store
            X{steps}=X_step;
        end
        if in.store || compute_dPfdz
            Y{steps}=Y_step;
            if compute_dPfdz
                dY{steps}=dY_step;
            end
        end
        thresholds(steps)=max(0,mean(Y_step(ind(Nc:(Nc+1)))));
        Pfs(steps)=mean(Y_step<=thresholds(steps));
        if compute_dPfdtheta && ~in.isdef('lnPDF')
            % Use lnPDF
            temp=zeros(sum(Y_step<=thresholds(steps)),size(in.theta,2));
            k=1;
            for i=1:size(Y_step,1)
                if Y_step(i)<=thresholds(steps)
                    temp(k,:)=CODES.common.grad_fd(...
                        @(theta)in.lnPDF(X_step(i,:),theta),in.theta,...
                        'vectorial',false);
                    k=k+1;
                end
            end
            dPfdtheta(steps,:)=sum(temp,1)/size(Y_step,1)-...
                sum(Y_step<=thresholds(steps))*sum(bsxfun(@rdivide,dPfdtheta(1:(steps-1),:),Pfs(1:(steps-1))),1)/size(Y_step,1);
        elseif compute_dPfdtheta
            % use dlnPDF
            dPfdtheta(steps,:)=sum(in.dlnPDF(X_step(Y_step<=thresholds(steps),:)),1)/size(Y_step,1)-...
                sum(Y_step<=thresholds(steps))*sum(bsxfun(@rdivide,dPfdtheta(1:(steps-1),:),Pfs(1:(steps-1))),1)/size(Y_step,1);
        end
        % Display if asked for
        if in.verbose
            disp(['Step : ' num2str(steps)])
            disp(['Threshold : ' num2str(thresholds(steps))])
            disp(['Current Pf : ' num2str(prod(Pfs(1:steps)))])
            disp(['Current # of function calls : ' num2str(function_calls)])
        end
        % Compute CoV of current Step (delta_i)
        if in.CoV_bound
            Indicator=reshape(Y_step<=thresholds(steps),Nc,N_Nc);          % Indicators : nb_Chain x nb_Samples_per_Chain
            CoV(steps)=variation(Pfs(steps),Nc*N_Nc)*sqrt(1+gamma_i(Indicator,Nc,N_Nc,Pfs(steps)));
        end
    end
    % Compute Final Pf
    res.Pf=prod(Pfs(1:steps));
    res.beta=-norminv(res.Pf);
    res.steps=steps;
    res.LS_count=getappdata(0,'subset_ls_count');
    if compute_dPfdtheta
        res.dPfdtheta=res.Pf*sum(bsxfun(@rdivide,dPfdtheta(1:steps,:),Pfs(1:steps)),1);
        res.dbetadtheta=-res.dPfdtheta/normpdf(-res.beta);
    end
    if compute_dPfdz
        dPfi=zeros(steps,in.nz);
        for i=1:steps
            dPfi(i,:)=dPfidz(Y{i},thresholds(i),dY{i},Pfs(1:i),i,dPfi(1:(i-1),:),in);
        end
        res.dPfdz=res.Pf*sum(bsxfun(@rdivide,dPfi,Pfs(1:steps)),1);
        res.dbetadz=-res.dPfdz/normpdf(-res.beta);
    end
    % Compute Final CoV
    if in.CoV_bound
        ub=0;
        for i=1:steps
            for j=1:steps
                ub=ub+CoV(i)*CoV(j);
            end
        end
        res.CoV=100*[sqrt(sum(CoV(1:steps).^2)) sqrt(ub)];                  % Bounds on Coefficient of variation of Pf (%)
    end
    if in.store
        res.X=X(1:steps);
        res.Y=Y(1:steps);
        res.thresholds=thresholds(1:steps);
        res.Pfs=Pfs(1:steps);
        if compute_dPfdz
            res.dY=dY;
        end
    end
    if strcmpi(in.recall,'on')
        res.options=in;
    end
    rmappdata(0,'subset_ls_count')
    % Nested functions
    function decision=isdefault(input,param)
        % Test if a parameter is default
        decision=any(strcmp(input.UsingDefaults,param));
    end
    function varargout=eval(x,in,offset,compute_dPfdz)
        setappdata(0,'subset_ls_count',getappdata(0,'subset_ls_count')+size(x,1))
        if in.vectorial
            if compute_dPfdz
                [varargout{1},varargout{2}]=in.LS(x);
                varargout{1}=varargout{1}-offset;
            else
                varargout{1}=in.LS(x)-offset;
            end
        else
            varargout{1}=zeros(size(x,1),1);
            if compute_dPfdz
                varargout{2}=zeros(size(x,1),in.nz);
                for ii=1:size(x,1)
                    [varargout{1}(ii),varargout{2}(:,ii)]=in.LS(x(ii,:));
                    varargout{1}(ii)=varargout{1}(ii)-offset;
                end
            else
                for ii=1:size(x,1)
                    varargout{1}(ii)=in.LS(x(ii,:))-offset;
                end
            end
        end
    end
    function CV=variation(Pf,N)
        CV=sqrt(1-Pf)/sqrt(N*Pf);
    end
    function N=points(Pf,CV)
        N=(sqrt(1-Pf)/(sqrt(Pf)*CV))^2;
    end
    function X=flat(X_c)
        X=zeros(size(X_c,1)*size(X_c,3),size(X_c,2));
        for ii=1:size(X_c,3)
            X(((ii-1)*size(X_c,1)+1):(ii*size(X_c,1)),:)=X_c(:,:,ii);
        end
    end
    function R=R_ik(k,I,Nc,N_Nc,Pfi)
        N=Nc*N_Nc;
        R=0;
        for chain=1:Nc                  % For all Chain
            for sample=1:(N_Nc-k)       % For the samples
                R=R+I(chain,sample)*I(chain,sample+k);
            end
        end
        R=(1/(N-k*Nc))*R-Pfi^2;
    end
    function Rho=Rho_ik(k,I,Nc,N_Nc,Pfi)
        Rho=R_ik(k,I,Nc,N_Nc,Pfi)/R_ik(0,I,Nc,N_Nc,Pfi);
    end
    function gamma=gamma_i(I,Nc,N_Nc,Pfi)
        N=Nc*N_Nc;
        gamma=0;
        for kk=1:(N_Nc-1)
            gamma=gamma+(1-(kk*Nc/N))*Rho_ik(kk,I,Nc,N_Nc,Pfi);
        end
        gamma=2*gamma;
    end
    function dpdz=dPfidz(Y,th,dY,Pfi,i,dPfi,in)
        Y=Y-th;
        Y_rank=sort(abs(Y));
        N_r=floor(in.frac*sum(Y<=0));
        sigma=Y_rank(min(N_r,size(Y,1)));
        switch lower(in.dirac)
            case 'gauss'
                filter=@(y)normpdf(y/sigma)/sigma;
            case 'tgauss'
                filter=@(y)normpdf(y/sigma)/...
                    (sigma*(normcdf(1)-normcdf(-1))).*...
                    all([y<=sigma y>=-sigma],2);
            case 'sinc'
                filter=@(y)sin(y/sigma)./(y*pi);
            case 'bump'
                core=@(y)exp(-1./(1-y.^2));
                A=integral(core,-1,1);
                filter=@(y)core(y/sigma)/(A*sigma).*...
                    all([y<=sigma y>=-sigma],2);
            case 'poisson'
                filter=@(y)sigma./(pi*(sigma^2+y.^2));
        end
        dpdz=mean(-bsxfun(@times,dY,filter(Y)),1);
        if i>1
            dpdz=dpdz-Pfi(i)*sum(...
                bsxfun(@rdivide,dPfi(1:(i-1),:),Pfi(1:(i-1))),1);
        end
    end
end

