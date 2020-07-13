function varargout=hess_fd(f,x,varargin)
    % Hessian of f at x using finite difference (<a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/hess_fd.html');web(file);">HTML</a>)
    %
    % Syntax
    %   H=CODES.common.hess_fd(f,x) compute hessian matrix H using finite
    %   difference on f at x
    %   [H,grad]=CODES.common.hess_fd(...) returns the central finite
    %   difference of the gradient grad
    %   [H,grad,fx]=CODES.common.hess_fd(...) returns the function
    %   values of f at x fx
    %   [...]=CODES.common.hess_fd(...,param,value) uses a list of
    %   parameter and value, please refer to the <a
    %   href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/hess_fd.html');web(file);">HTML</a>
    %   documentation
    %
    % Example
    %   f=@(x)3*x(:,1).^2+x(:,2).^3+x(:,1)*x(:,2);
    %   H=CODES.common.hess_fd(f,[3 2.1]);
    %
    % Copyright 2013-2015 Computational Optimal Design of Engineering
    % Systems (CODES) laboratory
    %
    % See also
    % CODES.common.grad_fd
    input=inputParser;
    input.KeepUnmatched=false;
    input.PartialMatching=false;
    input.addRequired('f',@(x)isa(x,'function_handle'));% Function to apply finite difference to
    input.addRequired('x',@isnumeric);                  % Samples at wich to evaluate finite differences
    input.addOptional('rel_diff',1e-5,...
        @(x)x>0);                                       % Finite difference perturbation
    input.addOptional('fx',[],@isnumeric);              % Function value at x
    input.parse(f,x,varargin{:})
    in=input.Results;
    dim=size(in.x,2);
    % Check
    assert(size(in.x,1)==1,'Hessian can be computed only at one point at a time')
    if ~any(strcmpi(input.UsingDefaults,'fx'))
        assert(size(in.fx,1)==1,...
            'First size of ''fx'' should be 1')
    end
    % Initialize
    if any(strcmpi(input.UsingDefaults,'fx'))       % Function value is not provided
        in.fx=in.f(in.x);
    end
    pert_diag=zeros(dim,2);
    varargout{1}=zeros(dim,dim);
    % Compute the diagonal perturbations
    for i=1:dim
        b=zeros(1,dim);b(i)=1;
        pert_diag(i,:)=[in.f(in.x+in.rel_diff*b/2) in.f(in.x-in.rel_diff*b/2)];
        varargout{1}(i,i)=4*(sum(pert_diag(i,:))-2*in.fx)/in.rel_diff^2;
    end
    % Compute the off diagonal term
    for i=1:dim
        for j=(i+1):dim
            pert_off=zeros(1,4);
            b=zeros(1,dim);
            b(i)=1;b(j)=1;
            pert_off(1,1)=in.f(in.x+in.rel_diff*b/2);
            b=zeros(1,dim);
            b(i)=1;b(j)=-1;
            pert_off(1,2)=in.f(in.x+in.rel_diff*b/2);
            b=zeros(1,dim);
            b(i)=-1;b(j)=1;
            pert_off(1,3)=in.f(in.x+in.rel_diff*b/2);
            b=zeros(1,dim);
            b(i)=-1;b(j)=-1;
            pert_off(1,4)=in.f(in.x+in.rel_diff*b/2);
            varargout{1}(i,j)=(pert_off(1,1)-pert_off(1,2)-pert_off(1,3)+pert_off(1,4))/in.rel_diff^2;
            varargout{1}(j,i)=varargout{1}(i,j);
        end
    end
    % Return gradient if asked for
    if nargout>1
        varargout{2}=(pert_diag(:,1)-pert_diag(:,2))'/in.rel_diff;
    end
    % Return function value if asked for
    if nargout>2
        varargout{3}=in.fx;
    end
end
