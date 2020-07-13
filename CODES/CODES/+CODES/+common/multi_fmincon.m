function varargout=multi_fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options,varargin)   
    % Find minimum of constrained nonlinear multivariable function using multiple starting points (<a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/multi_fmincon.html');web(file);">HTML</a>)
    %
    % Syntax
    %   opti=CODES.common.multi_fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options)
    %   uses Matlab fmincon definition where x0 is an (n x dim) matrix of
    %   |n| starting points. 
    %   opti=CODES.common.multi_fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options,parallel)
    %   evaluates using parfor instead of for.
    %   [opti,valid]=CODES.common.multi_fmincon(...) returns the
    %   optimum opti and all the feasible local optima valid.
    %   [opti,valid,local]=CODES.common.multi_fmincon(...) returns al local
    %   optima local.
    %   [opti,valid,local,fval]=CODES.common.multi_fmincon(...) returns all
    %   function values fval at local optima.
    %   [opti,valid,local,fval,outputs]=CODES.common.multi_fmincon(...)
    %   returns the structures of the n outputs.
    %
    % Copyright 2013-2015 Computational Optimal Design of Engineering
    % Systems (CODES) laboratory
    if nargin<11    % Default is to use parallel
        UseParallel=true;
    else
        UseParallel=varargin{1};
    end
    assert(islogical(UseParallel),'UseParallel should be a logical');
    local=zeros(size(x0));
    fval=zeros(size(x0,1),1);
    exitflag=zeros(size(x0,1),1);
    if UseParallel
        i=1;
        if isempty(A) && isempty(b) && isempty(Aeq) && isempty(beq) && isempty(lb) && isempty(ub) && isempty(nonlcon)
            [local(i,:),fval(i),exitflag(i),output]=fminunc(fun,x0(i,:),options);
        else
            [local(i,:),fval(i),exitflag(i),output]=fmincon(fun,x0(i,:),A,b,Aeq,beq,lb,ub,nonlcon,options);
        end
        parfor i=2:size(x0,1)
            if isempty(A) && isempty(b) && isempty(Aeq) && isempty(beq) && isempty(lb) && isempty(ub) && isempty(nonlcon)
                [local(i,:),fval(i),exitflag(i),output(i)]=fminunc(fun,x0(i,:),options);
            else
                [local(i,:),fval(i),exitflag(i),output(i)]=fmincon(fun,x0(i,:),A,b,Aeq,beq,lb,ub,nonlcon,options);
            end
        end
    else
        for i=1:size(x0,1)
            if i==1
                if isempty(A) && isempty(b) && isempty(Aeq) && isempty(beq) && isempty(lb) && isempty(ub) && isempty(nonlcon)
                    [local(i,:),fval(i),exitflag(i),output]=fminunc(fun,x0(i,:),options);
                else
                    [local(i,:),fval(i),exitflag(i),output]=fmincon(fun,x0(i,:),A,b,Aeq,beq,lb,ub,nonlcon,options);
                end
            else
                if isempty(A) && isempty(b) && isempty(Aeq) && isempty(beq) && isempty(lb) && isempty(ub) && isempty(nonlcon)
                    [local(i,:),fval(i),exitflag(i),output(i)]=fminunc(fun,x0(i,:),options);
                else
                    [local(i,:),fval(i),exitflag(i),output(i)]=fmincon(fun,x0(i,:),A,b,Aeq,beq,lb,ub,nonlcon,options);
                end
            end
        end
    end
    if isempty(A) && isempty(b) && isempty(Aeq) && isempty(beq) && isempty(lb) && isempty(ub) && isempty(nonlcon)
        valid_set=sortrows([local fval],size(x0,2)+1);
    else
        valid=exitflag>0;
        if ~any(valid)
            valid=exitflag>=0;
        end
        if ~any(valid)
            warning('No feasible point found')
            valid=exitflag>=-6;
        end
        valid_set=sortrows([local(valid,:) fval(valid)],size(x0,2)+1);
    end
    varargout{1}=valid_set(1,1:end-1);
    if nargout>1
        varargout{2}=valid_set(1,end);
    end
    if nargout>2
        varargout{3}=local;
    end
    if nargout>3
        varargout{4}=fval;
    end
    if nargout>4
        varargout{5}=output;
    end
end
