function x_mm=mm(M,lb,ub,varargin)
    % Find a "max-min" sample (<a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/mm.html');web(file);">HTML</a>)
    %
    % Syntax
    %   x=CODES.sampling.mm(M,lb,ub) finds a "max-min" sample such that
    %   M.eval(x)=0 and lb<=x<=ub
    %   x=CODES.sampling.mm(M,lb,ub,param,value) uses a list of parameter and
    %   value, please refer to the <a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/mm.html');web(file);">HTML</a> documentation
    %
    % Example
    %   DOE=CODES.sampling.cvt(20,2,'lb',[-5 -5],'ub',[5 5]);
    %   svm=CODES.fit.svm(DOE,DOE(:,1)-DOE(:,2));
    %   x_mm=CODES.sampling.mm(svm,[-5 -5],[5 5]);
    %   figure('Position',[200 200 500 500])
    %   svm.isoplot('lb',[-5 -5],'ub',[5 5])
    %   plot(x_mm(1),x_mm(2),'ms')
    %
    % See also
    % CODES.sampling.anti_lock, CODES.sampling.edsd, CODES.sampling.gmm
    %
    % Copyright 2013-2015 Computational Optimal Design of Engineering
    % Systems (CODES) laboratory
    input=inputParser;
    input.KeepUnmatched=true;
    input.addRequired('M',@(x)isa(x,'CODES.fit.meta'));
    input.addRequired('lb',@isnumeric);                 % Lower bound for side constraints
    input.addRequired('ub',@isnumeric);                 % Upper bound for side constraints
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
    input.addOptional('X',[],@isnumeric);               % Samples from which to max-min (if default, use training set of M)
    input.parse(M,lb,ub,varargin{:})
    in=input.Results;
    % Checks
    if any(strcmp(input.UsingDefaults,'UseParallel'))
        in.UseParallel=in.M.UseParallel;
    end
    assert(in.nb>0,'''nb'' should be positive');
    % Scale the side constraints
    in.lb=in.M.scale(lb);
    in.ub=in.M.scale(ub);
    % Nested functions
    function [f,df]=obj(x,X_ex)
        % Objective function using p-norm for max-min problem
        p=40;
        C_ik=bsxfun(@minus,x,X_ex);
        B_k=sum(C_ik.^2,2);
        A=sum(B_k.^(-p/2),1);

        f=-A^(-1/p);
        df=-A^(-1/p-1)*sum(bsxfun(@times,B_k.^(-p/2-1),C_ik),1)';
    end
    function [c,ceq,Gc,Gceq]=g(x,in)
        % Constraint function for max-min with side constraints
        c=[];
        Gc=[];
        [ceq,grad]=in.M.eval(in.M.unscale(x));
        Gceq=diag(1./in.M.scalers)*grad';
    end
    % Use multistart SQP
    if strcmpi(in.MultiStart,'MATLAB')
        options=optimset('Display','off','GradObj','on','GradCons','on','DerivativeCheck','off','algorithm','sqp','TolFun',1e-4,'TolX',1e-4,'TolCon',1e-4);
    elseif strcmpi(in.MultiStart,'CODES')
        switch in.Display
            case {'off','final'}
                options=optimset('Display','off','GradObj','on','GradCons','on','DerivativeCheck','off','algorithm','sqp','TolFun',1e-4,'TolX',1e-4,'TolCon',1e-4);
            case 'iter'
                options=optimset('Display','final','GradObj','on','GradCons','on','DerivativeCheck','off','algorithm','sqp','TolFun',1e-4,'TolX',1e-4,'TolCon',1e-4);
        end
    end 
    % Define starting point
    cover=unifrnd(zeros(1e4,in.M.dim),ones(1e4,in.M.dim));
    abs_model_val=abs(in.M.eval(in.M.unscale(cover)));
    [~,temp]=sort(abs_model_val);
    indices=temp(1:in.intensity);
    start_set=cover(indices,:);
    % Solve max-min problem
    x_mm=zeros(in.nb,in.M.dim);
    for i=1:in.nb
        if i==1
            if isempty(in.X)
                X=in.M.X_sc;
            else
                X=in.M.scale(in.X);
            end
        else
            if isempty(in.X)
                X=[in.M.X_sc;x_mm(1:i-1,:)];
            else
                X=[in.M.scale(in.X);x_mm(1:i-1,:)];
            end
        end
        if ~strcmp(in.Display,'off')
            if in.nb==1
                CODES.common.disp_box('Searching for mm sample');
            else
                CODES.common.disp_box(['MM ' num2str(i) ' : searching for mm sample']);
            end
        end
        switch in.MultiStart
            case 'CODES'
                x_mm(i,:)=CODES.common.multi_fmincon(@(x)obj(x,X),start_set,...
                    [],[],[],[],in.lb,in.ub,@(x)g(x,in),options,in.UseParallel);
            case 'MATLAB'
                problem = createOptimProblem('fmincon',...
                    'objective',@(x)obj(x,X),...
                    'x0',start_set(1,:),'lb',in.lb,'ub',in.ub,...
                    'nonlcon',@(x)g(x,in),'options',options);
                nv=CODES.common.struct2nv(input.Unmatched);
                ms=MultiStart(nv{:},'UseParallel',in.UseParallel,'Display',in.Display);
                start_points=CustomStartPointSet(start_set);
                x_mm(i,:)=run(ms,problem,start_points);
        end
    end
    % Unscale max-min samples
    x_mm=in.M.unscale(x_mm);
end

