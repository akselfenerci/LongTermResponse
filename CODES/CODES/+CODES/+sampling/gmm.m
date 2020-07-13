function x_gmm=gmm(M,logjpdf,rng,varargin)
    % Find a generalized "max-min" sample (<a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/gmm.html');web(file);">HTML</a>)
    %
    % Syntax
    %   x=CODES.sampling.gmm(M,logjpdf,rng) finds a generalized "max-min"
    %   sample such that M.eval(x)=0
    %   x=CODES.sampling.gmm(M,logjpdf,rng,param,value) uses a list of
    %   parameter and value, please refer to the <a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/gmm.html');web(file);">HTML</a> documentation
    %
    % Example
    %   DOE=CODES.sampling.cvt(20,2,'lb',[-5 -5],'ub',[5 5]);
    %   svm=CODES.fit.svm(DOE,DOE(:,1)-DOE(:,2));
    %   x_gmm=CODES.sampling.gmm(svm,@(x)log(normpdf(x)),@(N)normrnd(0,1,N,2));
    %   figure('Position',[200 200 500 500])
    %   svm.isoplot('lb',[-5 -5],'ub',[5 5])
    %   plot(x_gmm(1),x_gmm(2),'ms')
    %
    % See also
    % CODES.sampling.anti_lock, CODES.sampling.edsd, CODES.sampling.mm
    %
    % Copyright 2013-2015 Computational Optimal Design of Engineering
    % Systems (CODES) laboratory
    input=inputParser;
    input.addRequired('M',@(x)isa(x,'CODES.fit.meta'));
    input.addRequired('logjpdf',...
        @(x)isa(x,'function_handle'));                  % Log of the joint pdf
    input.addRequired('rng',...
        @(x)isa(x,'function_handle')||isnumeric(x));    % To get optimization starting points
    input.addOptional('dlogjpdf',[],...
        @(x)isa(x,'function_handle')||isempty(x));      % Gradient of the log of the joint pdf
    input.addOptional('nb',1,@isnumeric);               % Number of repeated max min samples
    input.addOptional('intensity',30,@isnumeric);       % Number of starting point
    input.addOptional('UseParallel',false,@islogical);  % Use parallel or not
    input.addOptional('MultiStart','CODES',@(x)...
        strcmpi(x,'CODES')||...
        strcmpi(x,'MATLAB'));                           % Determines wich MultiStart implementation should be used
    input.addOptional('Display','off',@(x)...
        strcmp(x,'off')||...
        strcmp(x,'iter')||...
        strcmp(x,'final'));                             % Display level
    input.addOptional('sign','both',...
        @(x)strcmpi(x,'both')||...
        strcmpi(x,'plus')||...
        strcmpi(x,'minus'));                            % Testing purposes
    input.parse(M,logjpdf,rng,varargin{:})
    in=input.Results;
    % Checks
    if any(strcmp(input.UsingDefaults,'UseParallel'))
        in.UseParallel=in.M.UseParallel;
    end
    assert(in.nb>0,'''nb'' should be positive');
    if isnumeric(in.rng)
        assert(size(in.rng,2)==in.M.dim,'Dimension of ''rng'' samples does not match')
        assert(size(in.rng,1)>=in.intensity,'Size of ''rng'' samples lower than ''intensity''')
    end
    % Nested function
    function f=obj(x,X_ex,in)
        % Objective function using p-norm for generalized max-min problem
        % (without gradient)
        p=40;
        C_ik=bsxfun(@minus,x,X_ex);
        B_k=sum(C_ik.^2,2);
        A=sum(B_k.^(-p/2),1);
        A1=A^(-1/p);
        logJPDF=in.logjpdf(in.M.unscale(x));

        f=-(1/in.M.dim)*logJPDF-log(A1);
    end
    function [f,df]=obj_grad(x,X_ex,in)
        % Objective function using p-norm for generalized max-min problem
        % (with gradient)
        p=40;
        C_ik=bsxfun(@minus,x,X_ex);
        B_k=sum(C_ik.^2,2);
        A=sum(B_k.^(-p/2),1);
        A1=A^(-1/p);
        dA1=A^(-1/p-1)*sum(bsxfun(@times,B_k.^(-p/2-1),C_ik),1)';
        logJPDF=in.logjpdf(in.M.unscale(x));
        dlogJPDF=in.dlogjpdf(in.M.unscale(x));

        f=-(1/in.M.dim)*logJPDF-log(A1);
        df=-(1/in.M.dim)*diag(1./in.M.scalers)*dlogJPDF'-dA1/A1;
    end
    function [c,ceq,Gc,Gceq]=g(x,in)
        % Constraint function for max-min with side constraints
        c=[];
        Gc=[];
        [ceq,grad]=in.M.eval(in.M.unscale(x));
        Gceq=diag(1./in.M.scalers)*grad';
    end
    % Use multistart SQP
    if any(strcmp(input.UsingDefaults,'dlogjpdf'))      % No gradient provided for the log joint pdf
        GradObj='off';
    else                                                % Gradient provided
        GradObj='on';
    end
    if strcmpi(in.MultiStart,'MATLAB')
        options=optimset('Display','off','GradObj',GradObj,'GradCons','on','DerivativeCheck','off','algorithm','sqp','TolFun',1e-4,'TolX',1e-4,'TolCon',1e-4);
    elseif strcmpi(in.MultiStart,'CODES')
        switch in.Display
            case {'off','final'}
                options=optimset('Display','off','GradObj',GradObj,'GradCons','on','DerivativeCheck','off','algorithm','sqp','TolFun',1e-4,'TolX',1e-4,'TolCon',1e-4);
            case 'iter'
                options=optimset('Display','final','GradObj',GradObj,'GradCons','on','DerivativeCheck','off','algorithm','sqp','TolFun',1e-4,'TolX',1e-4,'TolCon',1e-4);
        end
    end
    % Define starting point
    if isa(in.rng,'function_handle')                    % rng is a function to get samples
        cover=in.M.scale(in.rng(1e4));
    else                                                % rng is a set of samples
        cover=in.M.scale(in.rng);
    end
    abs_model_val=abs(in.M.eval(in.M.unscale(cover)));
    [~,temp]=sort(abs_model_val);
    indices=temp(1:in.intensity);
    start_set=cover(indices,:);
    % Solve max-min problem
    x_gmm=zeros(in.nb,in.M.dim);
    for i=1:in.nb
        switch in.sign
            case 'plus'
                ref_X=in.M.X_sc(in.M.Y>0,:);
            case 'minus'
                ref_X=in.M.X_sc(in.M.Y<=0,:);
            case 'both'
                ref_X=in.M.X_sc;
        end
        if i==1
            X=ref_X;
        else
            X=[ref_X;x_gmm(1:i-1,:)];
        end
        if ~strcmp(in.Display,'off')
            if in.nb==1
                CODES.common.disp_box('Searching for mm sample');
            else
                CODES.common.disp_box(['MM ' num2str(i) ' : searching for mm sample']);
            end
        end
        if any(strcmp(input.UsingDefaults,'dlogjpdf'))  % No gradient provided for the log joint pdf
            obj_used=@(x)obj(x,X,in);
        else                                            % Gradient provided
            obj_used=@(x)obj_grad(x,X,in);
        end
        switch in.MultiStart
            case 'CODES'
                x_gmm(i,:)=CODES.common.multi_fmincon(obj_used,start_set,...
                    [],[],[],[],[],[],@(x)g(x,in),options,in.UseParallel);
            case 'MATLAB'
                problem = createOptimProblem('fmincon',...
                    'objective',obj_used,'x0',start_set(1,:),...
                    'nonlcon',@(x)g(x,in),'options',options);
                nv=CODES.common.struct2nv(input.Unmatched);
                ms=MultiStart(nv{:},'UseParallel',in.UseParallel,'Display',in.Display);
                start_points=CustomStartPointSet(start_set);
                x_gmm(i,:)=run(ms,problem,start_points);
        end
    end
    % Unscale generalized max-min samples
    x_gmm=in.M.unscale(x_gmm);
end
