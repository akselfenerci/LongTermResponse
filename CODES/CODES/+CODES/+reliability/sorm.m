function res=sorm(limit_state,dimension,varargin)
    % Second-order reliability method (<a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/sorm.html');web(file);">HTML</a>)
    %
    % Syntax
    %   res=CODES.reliability.sorm(g,dim) compute an estimate of the
    %   probability of failure using SORM. The probability of failure is
    %   defined as the probability that the limit state function g is below
    %   or equal to zero. The dimension dim of the problem must be
    %   specified.
    %   [...]=CODES.reliability.sorm(...,param,value) uses a list of
    %   parameter and value, please refer to the <a
    %   href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/sorm.html');web(file);">HTML</a>
    %   documentation
    %
    % Example
    %   g=@CODES.test.lin;
    %   res=CODES.reliability.form(g,2);
    %
    % See also
    % CODES.reliability.form CODES.reliability.iform CODES.reliability.mc CODES.reliability.subset
    %
    % Copyright 2013-2015 Computational Optimal Design of Engineering
    % Systems (CODES) laboratory
    input=inputParser;
    input.KeepUnmatched=false;
    input.PartialMatching=false;
    input.addRequired('g',@(x)isa(x,'function_handle'));% Limit state
    input.addRequired('dim',@isnumeric);                % Dimension of the problem
    input.addOptional('Tinv',@(x)x,...
        @(x)isa(x,'function_handle'));                  % Inverse transformation function
    input.addOptional('approx','Breitung',@(x)...
        strcmpi(x,'Breitung')||...
        strcmpi(x,'Tvedt')||...
        strcmpi(x,'Koyluoglu')||...
        strcmpi(x,'Cai')||...
        strcmpi(x,'Zhao')||...
        strcmpi(x,'Subset'));                           % Approximation type
    input.addOptional('rel_diff',1e-5,...
        @isnumeric);                                    % Finite difference perturbation
    input.addOptional('res_form',[],@isstruct);         % Results of a FORM analysis
    input.addOptional('H',[],@isnumeric);               % Hessian in U space at MPP
    input.addOptional('grad',[],@isnumeric);            % Grad in U space at MPP
    input.parse(limit_state,dimension,varargin{:})
    in=input.Results;
    setappdata(0,'sorm_ls_count',0);
    % Check
    if ~any(strcmpi(input.UsingDefaults,'H')) || ~any(strcmpi(input.UsingDefaults,'grad'))
        assert(~any(strcmpi(input.UsingDefaults,'H')) && ~any(strcmpi(input.UsingDefaults,'grad')),...
            'Either both or none of ''H'' and ''grad'' are provided');
    end
    % Find MPP using FORM
    if any(strcmpi(input.UsingDefaults,'res_form'))
        in.res_form=CODES.reliability.form(@(u)g_count(u,in),in.dim);
    end
    % Compute Hessian at the MPP if not provided
    if any(strcmpi(input.UsingDefaults,'H'))
        [in.H,in.grad]=CODES.common.hess_fd(@(u)g_count(u,in),...
            in.res_form.uMPP,'rel_diff',in.rel_diff);
    end
    % Compute main curvatures
    % Tvedt, L. (1990). Distribution of Quadratic Forms in Normal Space -
    % Application to Structural Reliability. Journal of Engineering
    % Mechanics, 116(6), 1183–1197.
    % doi:10.1061/(ASCE)0733-9399(1990)116:6(1183)
    nG=norm(in.grad);
    B=in.H/nG;
    alpha=in.grad/nG;
    R=eye(in.dim);
    R(end,:)=alpha;
    A=R*B*R';
    lambdas=eig(A(1:end-1,1:end-1));
    % Compute approximations
    % Zhao, Y.-G., & Ono, T. (1999). New Approximations for SORM: Part 1.
    % Journal of Engineering Mechanics, 125(1), 79–85.
    % doi:10.1061/(ASCE)0733-9399(1999)125:1(79)
    switch lower(in.approx)
        case 'breitung'
            res.Pf=in.res_form.Pf/sqrt(prod(1+in.res_form.beta*lambdas));
        case 'tvedt'
            A11=1/sqrt(prod(1+in.res_form.beta*lambdas));
            A12=in.res_form.beta*in.res_form.Pf-normpdf(-in.res_form.beta);
            A1=in.res_form.Pf*A11;
            A2=A12*(A11-1/sqrt(prod(1+(in.res_form.beta+1)*lambdas)));
            A3=(in.res_form.beta+1)*A12*...
               (A11-real(1/sqrt(prod(1+(in.res_form.beta+1i)*lambdas))));
           res.Pf=A1+A2+A3;
        case 'koyluoglu'
            if all(lambdas>0)
                res.Pf=in.res_form.Pf/sqrt(prod(...
                    1+lambdas*normpdf(in.res_form.beta)/in.res_form.Pf));
            elseif all(lambdas<0)
                res.Pf=1-(1-in.res_form.Pf)/sqrt(prod(...
                    1-lambdas*normpdf(in.res_form.beta)/(1-in.res_form.Pf)));
            else
                warning('''Koyluoglu'' approximation failed, not all curvature have same sign')
            end
        case 'cai'
            lambdas=0.5*lambdas;
            D1=sum(lambdas);
            L=lambdas'*lambdas;
            L=(1-eye(in.dim-1)).*L;
            D2=-0.5*in.res_form.beta*(3*sum(lambdas.^2)+sum(L(:)));
            L=lambdas'*(lambdas.^2);
            L=(1-eye(in.dim-1)).*L;
            L2=bsxfun(@times,lambdas'*lambdas,permute(lambdas,[1 3 2]));
            L2(1:((in.dim-1)*(in.dim-1)+in.dim):end)=0;
            D3=1/6*(in.res_form.beta^2-1)*...
                (15*sum(lambdas.^3)+9*sum(L(:))+sum(L2(:)));
            res.Pf=in.res_form.Pf-normpdf(in.res_form.beta)*(D1+D2+D3);
        case 'zhao'
            Ks=sum(diag(B))-alpha*B*alpha';
            R=(in.dim-1)/Ks;
            if Ks>=0
                p=-((in.dim-1)/2)*(1+(2*Ks)/(10*(1+2*in.res_form.beta)));
                res.Pf=in.res_form.Pf*...
                    (1+normpdf(in.res_form.beta)/(R*in.res_form.Pf))^p;
            else
                res.Pf=normcdf(-((1+(2.5*Ks)/(2*in.dim-5*R+25*(23-5*in.res_form.beta)/R^2))*in.res_form.beta+...
                    0.5*Ks*(1+Ks/40)));
            end
        case 'subset'
            res_subsim=CODES.reliability.subset(...
                @(u)g_quad(u,alpha,B,in),in.dim);
            res.Pf=res_subsim.Pf;
    end
    % Return results
    res.beta=-norminv(res.Pf); 
    res.LS_count=getappdata(0,'sorm_ls_count');
    if any(strcmpi(input.UsingDefaults,'res_form'))
        res.MPP=in.Tinv(in.res_form.MPP);
    else
        res.MPP=in.res_form.MPP;
    end
    res.H=in.H;
    res.G=in.grad;
    % Clean up
    rmappdata(0,'sorm_ls_count');
    % Nested function
    function varargout=g_count(u,in)
        if nargout==1
            varargout{1}=in.g(in.Tinv(u));
        elseif nargout==2
            [varargout{1},dy]=in.g(in.Tinv(u));
            dTinv=CODES.common.grad_fd(@in.Tinv,u,in.rel_diff);
            varargout{2}=dy*dTinv;
        end
        setappdata(0,'sorm_ls_count',getappdata(0,'sorm_ls_count')+size(u,1));
    end
    function y=g_quad(u,alpha,B,in)
        % Exact quadratic form
        us=bsxfun(@minus,u,in.res_form.uMPP);
%         y=in.res_form.beta-u*alpha'+...
%                 0.5*sum(bsxfun(@times,us*B,us),2);
        y=us*alpha'+0.5*sum(bsxfun(@times,us*B,us),2);
    end
end