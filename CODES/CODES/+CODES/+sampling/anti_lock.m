function varargout=anti_lock(M,lb,ub,varargin)
    % Generate an anti-locking sample (<a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/anti_lock.html');web(file);">HTML</a>)
    %
    % Syntax
    %   x=CODES.sampling.anti_lock(M,lb,ub) finds an anti-locking sample 
    %   |x_al| on model |M| with lower bound |lb| and upper bound |ub|
    %   x=CODES.sampling.anti_lock(...,param,value) uses a list of
    %   parameter and value, please refer to the <a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/anti_lock.html');web(file);">HTML</a> documentation
    %   [x,adds]=CODES.sampling.anti_lock(...) only if nb=1 and M.dim=2, add
    %   returns a 1 x 2 cell, made of center and points to plot region
    %   boundary (_c.f._, <a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/anti_lock.html');web(file);">HTML</a>
    %   for more details)
    %
    % Example
    %   DOE=CODES.sampling.cvt(20,2,'lb',[-5 -5],'ub',[5 5]);
    %   svm=CODES.fit.svm(DOE,DOE(:,1)-DOE(:,2));
    %   x_al=CODES.sampling.anti_lock(svm,[-5 -5],[5 5]);
    %   figure('Position',[200 200 500 500])
    %   svm.isoplot('lb',[-5 -5],'ub',[5 5])
    %   plot(x_al(1),x_al(2),'ms')
    %
    % See also
    % CODES.sampling.mm, CODES.sampling.edsd
    %
    % Copyright 2013-2015 Computational Optimal Design of Engineering
    % Systems (CODES) laboratory
    input=inputParser;
    input.KeepUnmatched=true;
    input.addRequired('M',@(x)isa(x,'CODES.fit.meta'));
    input.addRequired('lb',@isnumeric);                 % Lower bound for side constraints
    input.addRequired('ub',@isnumeric);                 % Upper bound for side constraints
    input.addOptional('nb',1,@isnumeric);               % Number of repeated anti-locking samples
    input.addOptional('intensity',30,@isnumeric);       % Number of starting point
    input.addOptional('UseParallel',false,@islogical);  % Use parallel or not
    input.addOptional('MultiStart','CODES',@(x)...
        strcmpi(x,'CODES')||...
        strcmpi(x,'MATLAB'));                           % Determines wich MultiStart implementation should be used
    input.addOptional('Display','off',@(x)...
        strcmp(x,'off')||...
        strcmp(x,'iter')||...
        strcmp(x,'final'));                             % Display level
    input.addOptional('X',[],@isnumeric);               % Samples from which to anti-lock (if default, use training set of M)
    input.addOptional('Y',[],@isnumeric);               % Sample values from which to anti-lock (if default, use training set of M)
    input.parse(M,lb,ub,varargin{:})
    in=input.Results;
    % Checks
    if any(strcmp(input.UsingDefaults,'UseParallel'))
        in.UseParallel=in.M.UseParallel;
    end
    if ~any(strcmp(input.UsingDefaults,'X')) || ~any(strcmp(input.UsingDefaults,'Y'))
        assert(~any(strcmp(input.UsingDefaults,'X')) && ~any(strcmp(input.UsingDefaults,'Y')),...
            'Both ''X'' and ''Y'' must be provided, or none of them');
    end
    assert(in.nb>0,'''nb'' should be positive');
    % Scale the side constraints
    in.lb=in.M.scale(lb);
    in.ub=in.M.scale(ub);
    % Nested functions
    function [f,df]=obj_primary(x,X,Y)
        % Objective function using p-norm for center
        X_plus=X(Y>0,:);
        X_minus=X(Y<0,:);
        p=40;
        
        C_ik=bsxfun(@minus,x,X_plus);
        B_k=sum(C_ik.^2,2);
        A=sum(B_k.^(-p/2),1);
        fp=A^(-1/p);
        dfp=A^(-1/p-1)*sum(bsxfun(@times,B_k.^(-p/2-1),C_ik),1)';
        
        C_ik=bsxfun(@minus,x,X_minus);
        B_k=sum(C_ik.^2,2);
        A=sum(B_k.^(-p/2),1);
        fm=A^(-1/p);
        dfm=A^(-1/p-1)*sum(bsxfun(@times,B_k.^(-p/2-1),C_ik),1)';
        
        f=-(fp-fm)^2;
        df=-2*(dfp-dfm)*(fp-fm);
    end
    function [c,ceq,Gc,Gceq]=g_primary(x,in)
        % Constraint function for center
        c=[];
        Gc=[];
        [ceq,grad]=in.M.eval(in.M.unscale(x));
        Gceq=diag(1./in.M.scalers)*grad';
    end
    function [f,df]=obj_secondary(x,in,closest)
        % Objective function to find anti locking
        [val,grad]=in.M.eval(in.M.unscale(x));
        f=closest*val;
        df=closest*diag(1./in.M.scalers)*grad';
    end
    function [c,ceq,Gc,Gceq]=g_secondary(x,x_c,R2)
        % Constraint function to find anti locking sample
        a=(x-x_c);
        c=sum(a.^2)-R2;
        Gc=2*a';
        ceq=[];
        Gceq=[];
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
    options_nd=optimset('Display',in.Display,'GradObj','on','GradCons','on','DerivativeCheck','off','algorithm','sqp','TolFun',1e-4,'TolX',1e-4,'TolCon',1e-4);
    % Define starting point
    cover=unifrnd(zeros(1e4,in.M.dim),ones(1e4,in.M.dim));
    abs_model_val=abs(in.M.eval(in.M.unscale(cover)));
    [~,temp]=sort(abs_model_val);
    indices=temp(1:in.intensity);
    start_set=cover(indices,:);
    % Solve primary problem (unbalance)
    x_al=zeros(in.nb,in.M.dim);
    closest=zeros(in.nb,1);
    for i=1:in.nb
        if i==1
            if sum(in.Y<0)==0 || sum(in.Y>0)==0
                X=in.M.X_sc;
                Y=in.M.class(in.M.Y);
            else
                X=in.M.scale(in.X);
                Y=in.M.class(in.Y);
            end
        else
            if sum(in.Y<0)==0 || sum(in.Y>0)==0
                X=[in.M.X_sc;x_al(1:i-1,:)];
                Y=[in.M.class(in.M.Y);-closest(1:i-1)]; % Assume past anti locking were from opposite class
            else
                X=[in.M.scale(in.X);x_al(1:i-1,:)];
                Y=[in.M.class(in.Y);-closest(1:i-1)];   % Assume past anti locking were from opposite class
            end
        end
        if ~strcmp(in.Display,'off')
            if in.nb==1
                CODES.common.disp_box('Searching for center x_c');
            else
                CODES.common.disp_box(['AL ' num2str(i) ' : searching for center x_c']);
            end
        end
        switch in.MultiStart
            case 'CODES'
                x_c=CODES.common.multi_fmincon(@(x)obj_primary(x,X,Y),start_set,...
                    [],[],[],[],in.lb,in.ub,@(x)g_primary(x,in),options,in.UseParallel);
            case 'MATLAB'
                problem = createOptimProblem('fmincon',...
                    'objective',@(x)obj_primary(x,X,Y),...
                    'x0',start_set(1,:),'lb',in.lb,'ub',in.ub,...
                    'nonlcon',@(x)g_primary(x,in),'options',options_nd);
                nv=CODES.common.struct2nv(input.Unmatched);
                ms=MultiStart(nv{:},'UseParallel',in.UseParallel,'Display',in.Display);
                start_points=CustomStartPointSet(start_set);
                x_c=run(ms,problem,start_points);
        end
        % Find distance to closest plus and minus
        d_plus=min(pdist2(x_c,X(Y>0,:)));
        d_minus=min(pdist2(x_c,X(Y<0,:)));
        R2=(0.25*abs(d_plus-d_minus))^2;
        if d_plus<d_minus, closest(i)=+1; else closest(i)=-1; end
        % Find anti locking sample
        if ~strcmp(in.Display,'off')
            if in.nb==1
                CODES.common.disp_box('Searching for al sample');
            else
                CODES.common.disp_box(['AL ' num2str(i) ' : searching for al sample']);
            end
            
        end
        x_al(i,:)=fmincon(@(x)obj_secondary(x,in,closest(i)),x_c,...
            [],[],[],[],in.lb,in.ub,...
            @(x)g_secondary(x,x_c,R2),options);
    end
    % Unscale anti-locking samples
    varargout{1}=in.M.unscale(x_al);
    % If asked for, return center and points of constraint boundary (only
    % if nb=1 and M.dim=2)
    if nargout>1
        if in.nb==1
            [X_b,Y_b]=pol2cart(linspace(0,2*pi,100),sqrt(R2));
            varargout{2}={in.M.unscale(x_c);...
                in.M.unscale(bsxfun(@plus,x_c,[X_b' Y_b']))};
        else
            warning('Center and boundary points can only be returned when ''nb'' is set to 1');
            varargout{2}=[];
        end
    end
end

