function res=iform(limit_state,dimension,beta,varargin)
    % Inverse first-order reliability method (<a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/iform.html');web(file);">HTML</a>)
    %
    % Syntax
    %   res=CODES.reliability.iform(g,dim,beta) search for the Minimum
    %   Performance Target Point (MPTP) at a given beta. The dimension dim
    %   of the problem must be specified.
    %   [...]=CODES.reliability.iform(...,param,value) uses a list of
    %   parameter and value, please refer to the <a
    %   href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/iform.html');web(file);">HTML</a>
    %   documentation
    %
    % Example
    %   g=@CODES.test.lin;
    %   res=CODES.reliability.iform(g,2,2.5);
    %
    % See also
    % CODES.reliability.iform CODES.reliability.sorm CODES.reliability.mc
    % CODES.reliability.subset
    %
    % Copyright 2013-2015 Computational Optimal Design of Engineering
    % Systems (CODES) laboratory
    input=inputParser;
    input.KeepUnmatched=false;
    input.PartialMatching=false;
    input.addRequired('g',@(x)isa(x,'function_handle'));% Limit state
    input.addRequired('dim',@isnumeric);                % Dimension of the problem
    input.addRequired('beta',@isnumeric);               % Target reliability index
    input.addOptional('solver','sqp',@(x)...
        strcmpi(x,'hmv')||...
        strcmpi(x,'amv')||...
        strcmpi(x,'cmv')||...
        strcmpi(x,'sqp'));                              % Numerical solver
    input.addOptional('Tinv',@(x)x,...
        @(x)isa(x,'function_handle'));                  % Inverse transformation function
    input.addOptional('LS_grad',false,...
        @islogical);                                    % Gradient of LS available
    input.addOptional('rel_diff',1e-5,...
        @isnumeric);                                    % Finite difference perturbation
    input.addOptional('eps',1e-4,...
        @isnumeric);                                    % Convergenge tolerence for hl-rf
    input.addOptional('iter_max',100,...
        @isnumeric);                                    % Maximum number of iteration for hl-rf
    input.addOptional('vectorial',false,@islogical);    % Is f vectorial
    input.addOptional('display','none',@(x)...
        strcmpi(x,'none')||...
        strcmpi(x,'iter')||...
        strcmpi(x,'final'));                            % Level of display
    input.addOptional('gz',[],...
        @(x)isa(x,'function_handle'));                  % g as a function of x and z, used for dPPM/dz
    input.addOptional('dgdz',[],...
        @(x)isa(x,'function_handle'));                  % dg/dz as a function of x and z, used for dPPM/dz
    input.addOptional('z',[],@isnumeric);               % z value, used for dPPM/dz
    input.addOptional('T',[],...
        @(x)isa(x,'function_handle'));                  % Transformation T as a function of x and theta, used for dPPM/dtheta
    input.addOptional('dTdx',[],...
        @(x)isa(x,'function_handle'));                  % dT/dx as a function of x and theta, used for dPPM/dtheta
    input.addOptional('Tinvtheta',[],...
        @(x)isa(x,'function_handle'));                  % Inverse transformation Tinv as a function of u and theta, used for dPPM/dtheta
    input.addOptional('dTinvdtheta',[],...
        @(x)isa(x,'function_handle'));                  % dTinv/dtheta as a function of u and theta, used for dPPM/dtheta
    input.addOptional('theta',[],@isnumeric);           % theta value, used for dPPM/dtheta
    input.parse(limit_state,dimension,beta,varargin{:})
    in=input.Results;
    in.isdef=@(p)isdefault(input,p);
    % Checks
    if ~in.isdef('gz') || ~in.isdef('dgdz')
        assert(~in.isdef('z'),...
            '''z'' value must be provided for dPPM/dz')
        assert(in.isdef('gz') || in.isdef('dgdz'),...
            'Only one of ''gz'' and ''dgdz'' can be passed as argument')
    end
    if ~in.isdef('z')
        assert(size(in.z,1)==1,'''z'' should be a row vector')
        assert(~in.isdef('gz') || ~in.isdef('dgdz'),...
            ['At least one of ''gz'' and ''dgdz'' must be passed as'...
            'argument with ''z'' to compute dPPM/dz'])
        compute_dPPMdz=true;
    else
        compute_dPPMdz=false;
    end
    if ~in.isdef('T') || ~in.isdef('dTdx')
        assert(~in.isdef('theta'),...
            '''theta'' value must be provided for dPPM/dtheta')
        assert(in.isdef('T') || in.isdef('dTdx'),...
            'Only one of ''T'' and ''dTdx'' can be passed as argument')
    end
    if ~in.isdef('Tinv') || ~in.isdef('dTinvdtheta')
        assert(in.isdef('Tinv') || in.isdef('dTinvdtheta'),...
            'Only one of ''Tinv'' and ''dTinvdtheta'' can be passed as argument')
    end
    if ~in.isdef('theta')
        assert(size(in.theta,1)==1,'''theta'' should be a row vector')
        assert((~in.isdef('T') || ~in.isdef('dTdx')) && ...
            (~in.isdef('Tinv') || ~in.isdef('dTinvdtheta')),...
            ['At least one of ''T'' and ''dTdx'' and '...
            'one of ''T'' and ''dTdtheta'' must be passed as'...
            'argument with ''theta'' to compute dPPM/dtheta'])
        compute_dPPMdtheta=true;
    else
        compute_dPPMdtheta=false;
    end
    % Switch on solver
    setappdata(0,'iform_ls_count',0);
    switch upper(in.solver)
        case 'SQP'
            if in.LS_grad
                fmincon_opt=optimoptions('fmincon',...
                    'Algorithm','sqp','GradConstr','on','Display',in.display,...
                    'GradObj','on','MaxIter',in.iter_max,...
                    'TolCon',in.eps,'TolFun',in.eps,'TolX',in.eps);
                [ukp1,Gkp1]=fmincon(@(u)obj_g(u,in),zeros(1,in.dim),...
                    [],[],[],[],[],[],@(u)nonlcon(u,in),fmincon_opt);
            else
                fmincon_opt=optimoptions('fmincon',...
                    'Algorithm','sqp','GradConstr','on','Display',in.display,...
                    'MaxIter',in.iter_max,'TolCon',in.eps,...
                    'TolFun',in.eps,'TolX',in.eps);
                [ukp1,Gkp1]=fmincon(@(u)obj(u,in),zeros(1,in.dim),...
                    [],[],[],[],[],[],@(u)nonlcon(u,in),fmincon_opt);
            end
        case 'AMV'
            ukp1=zeros(1,in.dim);
            if in.LS_grad
                % If grad is provided, get gradient also
                [Gkp1,dGkp1]=g_count(ukp1,in);
            else
                % If not, just get function value
                Gkp1=g_count(ukp1,in);
            end
            iter=0;
            while iter==0 ||...
                 (iter<in.iter_max && convergence(ukp1,uk,Gkp1,Gk)>in.eps) %#ok<NODEF>
                if ~in.LS_grad
                    % If gradient wasn't provided, compute finite
                    % difference
                    dGkp1=g_fd(ukp1,Gkp1,in);
                end
                % Get unit descent
                nkp1=alpha(dGkp1);
                % Store
                uk=ukp1;Gk=Gkp1;
                nk=nkp1;
                % Compute next step
                ukp1=amv(nk,in);
                % Compute new g value
                if in.LS_grad
                    % If grad is provided, get gradient also
                    [Gkp1,dGkp1]=g_count(ukp1,in);
                else
                    % If not, just get function value
                    Gkp1=g_count(ukp1,in);
                end
                % Increment
                iter=iter+1;
                if strcmpi(in.display,'iter')
                    disp([sprintf('%3d',iter) ': ' num2str(convergence(ukp1,uk,Gkp1,Gk))])
                end
            end
            if iter==in.iter_max && ~strcmpi(in.display,'none')
                warning(['Maximum number of iterations (' num2str(iter,'%d') ') reached for AMV']);
            end
        case 'CMV'
            % First initial point
            ukm1=zeros(1,in.dim);
            if in.LS_grad
                % If grad is provided, get gradient also
                [~,dGkm1]=g_count(ukm1,in);
            else
                % If not, just get function value
                Gkm1=g_count(ukm1,in);
                dGkm1=g_fd(ukm1,Gkm1,in);
            end
            nkm1=alpha(dGkm1);
            % Second initial point
            uk=amv(nkm1,in);
            if in.LS_grad
                % If grad is provided, get gradient also
                [Gk,dGk]=g_count(uk,in);
            else
                % If not, just get function value
                Gk=g_count(uk,in);
                dGk=g_fd(uk,Gk,in);
            end
            nk=alpha(dGk);
            % Third initial point
            ukp1=amv(nk,in);
            if in.LS_grad
                % If grad is provided, get gradient also
                [Gkp1,dGkp1]=g_count(uk,in);
            else
                % If not, just get function value
                Gkp1=g_count(ukp1,in);
            end
            iter=0;
            while iter<in.iter_max && convergence(ukp1,uk,Gkp1,Gk)>in.eps
                if ~in.LS_grad
                    % If gradient wasn't provided, compute finite
                    % difference
                    dGkp1=g_fd(ukp1,Gkp1,in);
                end
                % Get new unit descent
                nkp1=alpha(dGkp1);
                % Store
                uk=ukp1;Gk=Gkp1;
                nkm2=nkm1;nkm1=nk;nk=nkp1;
                % Compute next step
                ukp1=cmv(nkm2,nkm1,nk,in);
                % Compute new g value
                if in.LS_grad
                    % If grad is provided, get gradient also
                    [Gkp1,dGkp1]=g_count(ukp1,in);
                else
                    % If not, just get function value
                    Gkp1=g_count(ukp1,in);
                end
                % Increment
                iter=iter+1;
                if strcmpi(in.display,'iter')
                    disp([sprintf('%3d',iter) ': ' num2str(convergence(ukp1,uk,Gkp1,Gk))])
                end
            end
            if iter==in.iter_max && ~strcmpi(in.display,'none')
                warning(['Maximum number of iterations (' num2str(iter,'%d') ') reached for CMV']);
            end
        case 'HMV'
            % First initial point
            ukm1=zeros(1,in.dim);
            if in.LS_grad
                % If grad is provided, get gradient also
                [~,dGkm1]=g_count(ukm1,in);
            else
                % If not, just get function value
                Gkm1=g_count(ukm1,in);
                dGkm1=g_fd(ukm1,Gkm1,in);
            end
            nkm1=alpha(dGkm1);
            % Second initial point
            uk=amv(nkm1,in);
            if in.LS_grad
                % If grad is provided, get gradient also
                [Gk,dGk]=g_count(uk,in);
            else
                % If not, just get function value
                Gk=g_count(uk,in);
                dGk=g_fd(uk,Gk,in);
            end
            nk=alpha(dGk);
            % Third initial point
            ukp1=amv(nk,in);
            if in.LS_grad
                % If grad is provided, get gradient also
                [Gkp1,dGkp1]=g_count(uk,in);
            else
                % If not, just get function value
                Gkp1=g_count(ukp1,in);
            end
            iter=0;
            while iter<in.iter_max && convergence(ukp1,uk,Gkp1,Gk)>in.eps
                if ~in.LS_grad
                    % If gradient wasn't provided, compute finite
                    % difference
                    dGkp1=g_fd(ukp1,Gkp1,in);
                end
                % Get new unit descent
                nkp1=alpha(dGkp1);
                % Is there oscillations
                decision=(nkp1-nk)*(nk-nkm1)';
                % Store
                uk=ukp1;Gk=Gkp1;
                nkm2=nkm1;nkm1=nk;nk=nkp1;
                % Compute next step
                if decision>0               % Convex, use AMV
                    ukp1=amv(nk,in);
                else                        % Concave, use CMV
                    ukp1=cmv(nkm2,nkm1,nk,in);
                end
                % Compute new g value
                if in.LS_grad
                    % If grad is provided, get gradient also
                    [Gkp1,dGkp1]=g_count(ukp1,in);
                else
                    % If not, just get function value
                    Gkp1=g_count(ukp1,in);
                end
                % Increment
                iter=iter+1;
                if strcmpi(in.display,'iter')
                    disp([sprintf('%3d',iter) ': ' num2str(convergence(ukp1,uk,Gkp1,Gk))])
                end
            end
            if iter==in.iter_max && ~strcmpi(in.display,'none')
                warning(['Maximum number of iterations (' num2str(iter,'%d') ') reached for HMV']);
            end
    end
    res.Pf=normcdf(-beta);
    res.beta=beta;
    res.LS_count=getappdata(0,'iform_ls_count');
    res.MPTP=in.Tinv(ukp1);
    res.uMPTP=ukp1;
    res.PPM=Gkp1;
    rmappdata(0,'iform_ls_count');
    % Compute sensitivities if required
    if compute_dPPMdz && ~isempty(in.z)
        if ~in.isdef('dgdz')
            % We have dgdz
            dgdz=in.dgdz(res.MPP,in.z);
            assert(all(size(dgdz)==[1 size(in.z,2)]),...
                ['Dimension of ''dgdz'' should be [1 ' num2str(size(in.z,2)) ']'...
                ' and not [' num2str(size(dgdz,1)) ' ' num2str(size(dgdz,2)) ']'])
        else
            % We have gz, g as a function of x and z
            [dgdz,gz_val]=CODES.common.grad_fd(@(z)in.gz(res.MPTP,z),...
                in.z,in.rel_diff,'type','forward');
            assert(all(size(gz_val)==[1 1]),...
                ['Dimension of ''gz'' should be [1 1]'...
                ' and not [' num2str(size(gz_val,1)) ' ' num2str(size(gz_val,2)) ']'])
        end
        res.dPPMdz=dgdz;
    elseif compute_dPPMdz
        % dPPM/dz was requested, but z is empty
        res.dPPMdz=[];
    end
    if compute_dPPMdtheta && ~isempty(in.theta)
        if in.LS_grad
            if strcmpi(in.solver,'sqp')
                % We got nothing
                [~,dgdu]=g_count(ukp1,in);
            else
                % We already have everything
                dgdu=dGkp1;
            end
        else
            if strcmpi(in.solver,'sqp')
                % We got nothing
                Gkp1=g_count(ukp1,in);
                dgdu=g_fd(ukp1,Gkp1,in);
            else
                % We got g value
                dgdu=g_fd(ukp1,Gkp1,in);
            end
        end
        if ~in.isdef('dTinvdtheta')
            % We have dTinvdtheta  as a function of u and theta
            dTinvdtheta=in.dTinvdtheta(res.uMPTP,in.theta);
            assert(all(size(dTinvdtheta)==[1 in.dim]),...
                ['Dimension of ''dTinvdtheta'' should be [' num2str(in.dim) ' ' num2str(size(in.theta,2)) '] (Jacobian)'...
                ' and not [' num2str(size(dTinvdtheta,1)) ' ' num2str(size(dTinvdtheta,2)) ']'])
        else
            % We have Tinvtheta as a function of u and theta
            [dTinvdtheta,Tinvval]=CODES.common.grad_fd(@(theta)in.Tinvtheta(res.uMPTP,theta),...
                in.theta,in.rel_diff,'type','forward');
            assert(all(size(Tinvval)==[1 in.dim]),...
                ['Dimension of ''T'' should be [1 ' num2str(in.dim) ']'...
                ' and not [' num2str(size(Tinvval,1)) ' ' num2str(size(Tinvval,2)) ']'])
        end
        if ~in.isdef('dTdx')
            % We have dTdx as a function of x and theta
            dTdx=in.dTdx(res.MPTP,in.theta);
            assert(all(size(dTdx)==[1 in.dim]),...
                ['Dimension of ''dTdtheta'' should be [' num2str(in.dim) ' ' num2str(size(in.theta,2)) '] (Jacobian)'...
                ' and not [' num2str(size(dTdx,1)) ' ' num2str(size(dTdx,2)) ']'])
        else
            % We have T as a function of x and theta
            [dTdx,Tval]=CODES.common.grad_fd(@(x)in.T(x,in.theta),...
                res.MPTP,in.rel_diff,'type','forward');
            assert(all(size(Tval)==[1 in.dim]),...
                ['Dimension of ''T'' should be [1 ' num2str(in.dim) ']'...
                ' and not [' num2str(size(Tval,1)) ' ' num2str(size(Tval,2)) ']'])
        end
        res.dPPMdtheta=dTinvdtheta'*dTdx*dgdu';
    elseif compute_dPPMdtheta
        % dPf/dtheta was requested, but theta is empty
        res.dPPMdtheta=[];
    end
    % Nested function
    function decision=isdefault(input,param)
        % Test if a parameter is default
        decision=any(strcmp(input.UsingDefaults,param));
    end
    function f=obj(u,in)
        % Objective function
        f=in.g(in.Tinv(u));
        setappdata(0,'iform_ls_count',getappdata(0,'iform_ls_count')+1);
    end
    function [f,gf]=obj_g(u,in)
        % Objective function
        % With gradient
        [f,dy]=in.g(in.Tinv(u));
        dTinv=CODES.common.grad_fd(@in.Tinv,u,in.rel_diff);
        gf=dTinv'*dy';
        setappdata(0,'iform_ls_count',getappdata(0,'iform_ls_count')+1);
    end
    function [c,ceq,Gc,Gceq]=nonlcon(u,in)
        % Non linear constraints for fmincon
        ceq=[];Gceq=[];
        c=0.5*sum(u.^2,2)-0.5*in.beta^2;
        Gc=u';
    end
    function varargout=g_count(u,in)
        % Compute the function and keep count
        if nargout==1
            varargout{1}=in.g(in.Tinv(u));
        elseif nargout==2
            [varargout{1},dy]=in.g(in.Tinv(u));
            dTinv=CODES.common.grad_fd(@in.Tinv,u,in.rel_diff);
            varargout{2}=dy*dTinv;
        end
        setappdata(0,'iform_ls_count',getappdata(0,'iform_ls_count')+size(u,1));
    end
    function dG=g_fd(u,G,in)
        % Compute finite difference of g
        dG=CODES.common.grad_fd(@(u)g_count(u,in),u,...
            'type','forward','rel_diff',in.rel_diff,...
            'vectorial',in.vectorial,'fx',G);
    end
    function n=alpha(dG)
        % Compute unit descent direction
        n=-dG/norm(dG);
    end
    function varargout=amv(n,in)
        % Compute Advanced Mean Value
        varargout{1}=in.beta*n;
        if nargout>1
            varargout{2}=n;
        end
    end
    function varargout=cmv(nm2,nm1,n,in)
        % Compute Conjugate Mean Value
        varargout{1}=in.beta*(nm2+nm1+n)/norm(nm2+nm1+n);
        if nargout>1
            varargout{2}=n;
        end
    end
    function conv=convergence(uk1,uk,Gk1,Gk)
        % Convergence measures
        conv=max([abs(norm(uk1)-norm(uk));...
                  abs((Gk1-Gk)/Gk1);...
                  abs(Gk1-Gk)]);
    end
end