function res=mc(limit_state,dim,varargin)
    % Monte-Carlo (<a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/mc.html');web(file);">HTML</a>)
    %
    % Syntax
    %   res=CODES.reliability.mc(g,dim) compute a Crude Monte-Carlo
    %   estimate of the probability that $g(\mathbf{X})\leq 0$. The |dim|
    %   random variables $\mathbf{X}$ are independent standard gaussian.
    %   res=CODES.reliability.mc(g,x_mc) uses the user-defined Monte-Carlo
    %   sample x_mc.
    %   [...]=CODES.reliability.mc(...,param,value) uses a list of
    %   parameter and value, please refer to the <a
    %   href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/mc.html');web(file);">HTML</a>
    %   documentation
    %
    % Example
    %   g=@CODES.test.lin;
    %   res=CODES.reliability.mc(g,2);
    %
    % See also
    % CODES.reliability.form CODES.reliability.iform CODES.reliability.sorm CODES.reliability.subset
    %
    % Copyright 2013-2015 Computational Optimal Design of Engineering
    % Systems (CODES) laboratory
    input=inputParser;
    input.addRequired('LS',@(x)isa(x,'function_handle'));   % Limit State
    input.addRequired('dim',@(x)isnumeric(x));              % Dim
    input.addOptional('sampler',[],...
        @(x)isa(x,'function_handle'));                      % Function that produces samples
    input.addOptional('Tinv',[],...
        @(x)isa(x,'function_handle'));                      % Inverse transform function
    input.addOptional('n',1e6,@isnumeric);                  % Initial number of samples
    input.addOptional('CoV',inf,@isnumeric);                % Required CV to achieve (%)
    input.addOptional('memory',1e6,@isnumeric);             % Maximum simultaneaous simulation
    input.addOptional('alpha',0.05,@isnumeric);             % Confidence interval significance level
    input.addOptional('limit',1e9,@isnumeric);              % Maximum allowed simulation
    input.addOptional('vectorial',false,@islogical);        % Is the limit_state vectorial
    input.addOptional('verbose',false,@islogical);
    input.addOptional('store',false,@islogical);            % Specify if points used should be stored
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
    input.parse(limit_state,dim,varargin{:});
    in=input.Results;
    in.isdef=@(p)isdefault(input,p);
    % Check
    setappdata(0,'mc_ls_count',0);
    assert(in.isdef('sampler') || in.isdef('Tinv'),'Only one of ''Tinv'' and ''sampler'' can be passed as argument')
    if any(size(in.dim)~=1)     % dim is the monte carlo samples
        assert(in.isdef('sampler') && in.isdef('Tinv') &&...
            in.isdef('n') && in.isdef('CoV') && in.isdef('limit'),...
            'If Monte-Carlo samples are provided, ''Tinv'', ''sampler'', ''n'', ''CoV'' and ''limit'' must be default')
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
    LS=@(x)eval(x,in,compute_dPfdz);
    nb_fail=0;
    if compute_dPfdtheta
        dPfdtheta=zeros(1,size(in.theta,2));
    end
    % Compute samples
    if any(size(in.dim)~=1)     % dim is the monte carlo samples
        if in.store
            X=zeros(size(in.dim));
        end
        if in.store || compute_dPfdz
            Y=zeros(in.n,1);
            if compute_dPfdz
                dY=zeros(size(in.dim,1),in.nz);
            end
        end
        done=0;
        to_do=size(dim,1);
        while done<to_do
            nb_to_compute=min(to_do-done,in.memory);
            samples=dim((done+1):(done+nb_to_compute),:);
            if compute_dPfdz
                [values,dY((done+1):(done+nb_to_compute),:)]=LS(samples);
            else
                values=LS(samples);
            end
            if compute_dPfdtheta && ~in.isdef('lnPDF')
                % Use lnPDF
                temp=zeros(sum(values<=0),size(in.theta,2));
                k=1;
                for i=1:nb_to_compute
                    if values(i)<=0
                        temp(k,:)=CODES.common.grad_fd(...
                            @(theta)in.lnPDF(samples(i,:),theta),in.theta,...
                            'vectorial',false);
                        k=k+1;
                    end
                end
                dPfdtheta=bsxfun(@plus,dPfdtheta,sum(temp,1));
            elseif compute_dPfdtheta
                % use dlnPDF
                dPfdtheta=sum(in.dlnPDF(samples(values<=0,:)),1);
            end
            if in.store
                X((done+1):(done+nb_to_compute),:)=samples;
            end
            if in.store || compute_dPfdz
                Y((done+1):(done+nb_to_compute),1)=values;
            end
            nb_fail=nb_fail+sum(values<=0);
            done=done+nb_to_compute;
        end
        Pf=nb_fail/done;
    else                        % dim is just the dimension
        if in.store
            X=zeros(in.n,in.dim);
        end
        if in.store || compute_dPfdz
            Y=zeros(in.n,1);
            if compute_dPfdz
                dY=zeros(in.n,in.nz);
            end
        end
        if in.isdef('sampler')
            in.sampler=@(N)normrnd(0,1,N,in.dim);
        end
        if ~in.isdef('Tinv')
            in.sampler=@(N)in.Tinv(normrnd(0,1,N,in.dim));
        end
        done=0;
        to_do=in.n;
        while done<to_do
            nb_to_compute=min(to_do-done,in.memory);
            samples=in.sampler(nb_to_compute);
            if compute_dPfdz
                [values,dY((done+1):(done+nb_to_compute),:)]=LS(samples);
            else
                values=LS(samples);
            end
            if compute_dPfdtheta && ~in.isdef('lnPDF')
                % Use lnPDF
                temp=zeros(sum(values<=0),size(in.theta,2));
                k=1;
                for i=1:nb_to_compute
                    if values(i)<=0
                        temp(k,:)=CODES.common.grad_fd(...
                            @(theta)in.lnPDF(samples(i,:),theta),in.theta,...
                            'vectorial',false);
                        k=k+1;
                    end
                end
                dPfdtheta=bsxfun(@plus,dPfdtheta,sum(temp,1));
            elseif compute_dPfdtheta
                % use dlnPDF
                dPfdtheta=sum(in.dlnPDF(samples(values<=0,:)),1);
            end
            if in.store
                X((done+1):(done+nb_to_compute),:)=samples;
            end
            if in.store || compute_dPfdz
                Y((done+1):(done+nb_to_compute),1)=values;
            end
            nb_fail=nb_fail+sum(values<=0);
            done=done+nb_to_compute;
            Pf=nb_fail/done;
            if ~isinf(variation(Pf,done)) && 100*variation(Pf,done)>in.CoV
                to_do=max(in.n,min(floor(points(Pf,in.CoV/100)),in.limit));
            end
            if in.verbose
                disp(['Estimated Pf : ' num2str(Pf) ' (' num2str(100*variation(Pf,done)) '%), using ' num2str(done) ' MC samples']);
            end
        end
    end
    res.Pf=Pf;
    res.beta=-norminv(Pf);
    res.LS_count=getappdata(0,'mc_ls_count');
    res.CoV=100*variation(Pf,done);
    res.CI_Pf=res.Pf-sqrt((res.Pf-res.Pf^2)/done)*norminv([1-in.alpha/2 in.alpha/2]);
    res.CI_beta=fliplr(-norminv(res.CI_Pf));
    if compute_dPfdtheta
        res.dPfdtheta=dPfdtheta/done;
        res.dbetadtheta=-res.dPfdtheta/normpdf(-res.beta);
    end
    if compute_dPfdz
        Y_rank=sort(abs(Y));
        N_r=floor(in.frac*nb_fail);
        sigma=Y_rank(min(N_r,done));
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
        res.dPfdz=mean(-bsxfun(@times,dY,filter(Y)),1);
        res.dbetadz=-res.dPfdz/normpdf(-res.beta);
    end
    if in.store
        res.X=X;
        res.Y=Y;
        if compute_dPfdz
            res.dY=dY;
        end
    end
    % Nested function
    function decision=isdefault(input,param)
        % Test if a parameter is default
        decision=any(strcmp(input.UsingDefaults,param));
    end
    function CV=variation(Pf,N)
        CV=sqrt(1-Pf)/sqrt(N*Pf);
    end
    function N=points(Pf,CV)
        N=(sqrt(1-Pf)/(sqrt(Pf)*CV))^2;
    end
    function varargout=eval(x,in,compute_dPfdz)
        setappdata(0,'mc_ls_count',getappdata(0,'mc_ls_count')+size(x,1))
        if in.vectorial
            if compute_dPfdz
                [varargout{1},varargout{2}]=in.LS(x);
            else
                varargout{1}=in.LS(x);
            end
        else
            varargout{1}=zeros(size(x,1),1);
            if compute_dPfdz
                varargout{2}=zeros(size(x,1),in.nz);
                for ii=1:size(x,1)
                    [varargout{1}(ii),varargout{2}(ii,:)]=in.LS(x(ii,:));
                end
            else
                for ii=1:size(x,1)
                    varargout{1}(ii)=in.LS(x(ii,:));
                end
            end
        end
    end
end