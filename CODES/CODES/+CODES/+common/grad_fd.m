function varargout=grad_fd(f,x,varargin)
    % Gradient of f at x using finite difference (<a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/grad_fd.html');web(file);">HTML</a>)
    %
    % Syntax
    %   grad=CODES.common.grad_fd(f,x) compute finite difference on f at x
    %   [grad,fx]=CODES.common.grad_fd(...)
    %   [...]=CODES.common.grad_fd(...,param,value) uses a list of
    %   parameter and value, please refer to the <a
    %   href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/grad_fd.html');web(file);">HTML</a>
    %   documentation
    %
    % Example
    %   f=@(x)3*x;
    %   grad=CODES.common.grad_fd(f,2);
    %
    % Copyright 2013-2015 Computational Optimal Design of Engineering
    % Systems (CODES) laboratory
    %
    % See also
    % CODES.common.hess_fd
    input=inputParser;
    input.KeepUnmatched=false;
    input.PartialMatching=false;
    input.addRequired('f',@(x)isa(x,'function_handle'));% Function to apply finite difference to
    input.addRequired('x',@isnumeric);                  % Samples at wich to evaluate finite differences
    input.addOptional('rel_diff',1e-5,...
        @(x)x>0);                                       % Finite difference perturbation
    input.addOptional('type','central',@(x)...
        strcmpi(x,'central')||...
        strcmpi(x,'forward')||...
        strcmpi(x,'backward'));                         % Finite difference type
    input.addOptional('fx',[],@isnumeric);              % Function value at x
    input.addOptional('vectorial',false,@islogical);    % Is f vectorial
    input.parse(f,x,varargin{:})
    in=input.Results;
    n=size(in.x,1);
    dim=size(in.x,2);
    % Check
    if ~any(strcmpi(input.UsingDefaults,'fx'))
        assert(~strcmpi(in.type,'central'),...
            '''fx'' is not used for central finite difference')
        assert(size(in.fx,1)==n,...
            ['First size of ''fx'' should be ' num2str(n,'%d')])
        nY=size(in.fx,2);
    end
    %Initialize
    if ~strcmpi(in.type,'central')                      % If forward or backward
        if any(strcmpi(input.UsingDefaults,'fx'))       % Function values are not provided
            if in.vectorial
                in.fx=in.f(in.x);
                nY=size(in.fx,2);
            else
                t=in.f(in.x(1,:));
                nY=size(t,2);
                in.fx=zeros(n,nY);
                in.fx(1,:)=t;
                clear t;
                for i=2:n
                    in.fx(i,:)=in.f(in.x(i,:));
                end
            end
        end
        if strcmpi(in.type,'forward')
            in.rel_diff=in.rel_diff;
        else
            in.rel_diff=-in.rel_diff;
        end
        % Compute perturbations
        if in.vectorial
            b=eye(dim);
            c=bsxfun(@plus,in.rel_diff*b,permute(in.x,[3 2 1]));
            c=reshape(permute(c,[1 3 2]),dim*n,dim);
            pert=in.f(c);
            pert=reshape(pert,[dim n nY]);
            pert=permute(pert,[2 1 3]);
        else
            pert=zeros(n,dim,nY);
            for i=1:n
                for j=1:dim
                    b=zeros(1,dim);b(j)=1;
                    c=in.x(i,:)+in.rel_diff*b;
                    pert(i,j,:)=permute(in.f(c),[1 3 2]);
                end
            end
        end
        varargout{1}=bsxfun(@minus,pert,permute(in.fx,[1 3 2]))/in.rel_diff;
        if nargout==2
            varargout{2}=in.fx;
        end
    else
        assert(nargout<=1,'Only one output argument for ''type'' set to ''central''')
        if in.vectorial
            b=eye(dim);
            c=bsxfun(@plus,in.rel_diff*b/2,permute(in.x,[3 2 1]));
            c=reshape(permute(c,[1 3 2]),dim*n,dim);
            pert_plus=in.f(c);
            nY=size(pert_plus,2);
            pert_plus=reshape(pert_plus,[dim n nY]);
            pert_plus=permute(pert_plus,[2 1 3]);
            c=bsxfun(@plus,-in.rel_diff*b/2,permute(in.x,[3 2 1]));
            c=reshape(permute(c,[1 3 2]),dim*n,dim);
            pert_minus=in.f(c);
            pert_minus=reshape(pert_minus,[dim n nY]);
            pert_minus=permute(pert_minus,[2 1 3]);
        else
            % Find nY
            b=zeros(1,dim);b(1)=1;
            c=x(1,:)+in.rel_diff*b/2;
            t=f(c);
            nY=size(t,2);
            pert_plus=zeros(n,dim,nY);
            pert_minus=zeros(n,dim,nY);
            pert_plus(1,1,:)=permute(t,[1 3 2]);
            pert_minus(1,1,:)=f(x(1,:)-in.rel_diff*b/2);
            % Compute the rest
            for i=1:n
                for j=1:dim
                    if ~(i==1 && j==1)
                        b=zeros(1,dim);b(j)=1;
                        c=x(i,:)+in.rel_diff*b/2;
                        pert_plus(i,j,:)=permute(f(c),[1 3 2]);
                        c=x(i,:)-in.rel_diff*b/2;
                        pert_minus(i,j,:)=permute(f(c),[1 3 2]);
                    end
                end
            end
        end
        varargout{1}=(pert_plus-pert_minus)/in.rel_diff;
    end
    % If nY=1, we return array of grad, n x dim
    % However, if nY>1, we return Jacobians in form of nY x dim x n
    if nY>1
        varargout{1}=permute(varargout{1},[3 2 1]);
    end
end
