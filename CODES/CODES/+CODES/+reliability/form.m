function res=form(limit_state,dimension,varargin)
    % First-order reliability method (<a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/form.html');web(file);">HTML</a>)
    %
    % Syntax
    %   res=CODES.reliability.form(g,dim) compute an estimate of the
    %   probability of failure using FORM. The probability of failure is
    %   defined as the probability that the limit state function g is below
    %   or equal to zero. The dimension dim of the problem must be
    %   specified.
    %   [...]=CODES.reliability.form(...,param,value) uses a list of
    %   parameter and value, please refer to the <a
    %   href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/form.html');web(file);">HTML</a>
    %   documentation
    %
    % Example
    %   g=@CODES.test.lin;
    %   res=CODES.reliability.form(g,2);
    %
    % See also
    % CODES.reliability.sorm CODES.reliability.mc CODES.reliability.subset
    %
    % Copyright 2013-2015 Computational Optimal Design of Engineering
    % Systems (CODES) laboratory
    input=inputParser;
    input.KeepUnmatched=false;
    input.PartialMatching=false;
    input.addRequired('g',@(x)isa(x,'function_handle'));% Limit state
    input.addRequired('dim',@isnumeric);                % Dimension of the problem
    input.addOptional('solver','sqp',@(x)...
        strcmpi(x,'sqp')||...
        strcmpi(x,'hl-rf')||...
        strcmpi(x,'ihl-rf')||...
        strcmpi(x,'jhl-rf'));                           % Numerical solver
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
        @(x)isa(x,'function_handle'));                  % g as a function of x and z, used for dPf/dz
    input.addOptional('dgdz',[],...
        @(x)isa(x,'function_handle'));                  % dg/dz as a function of x and z, used for dPf/dz
    input.addOptional('z',[],@isnumeric);               % z value, used for dPf/dz
    input.addOptional('T',[],...
        @(x)isa(x,'function_handle'));                  % Transformation T as a function of x and theta, used for dPf/dtheta
    input.addOptional('dTdtheta',[],...
        @(x)isa(x,'function_handle'));                  % dT/dtheta as a function of x and theta, used for dPf/dtheta
    input.addOptional('theta',[],@isnumeric);           % theta value, used for dPf/dtheta
    input.parse(limit_state,dimension,varargin{:})
    in=input.Results;
    in.isdef=@(p)isdefault(input,p);
    % Check
    if ~in.isdef('gz') || ~in.isdef('dgdz')
        assert(~in.isdef('z'),...
            '''z'' value must be provided for dPf/dz')
        assert(in.isdef('gz') || in.isdef('dgdz'),...
            'Only one of ''gz'' and ''dgdz'' can be passed as argument')
    end
    if ~in.isdef('z')
        assert(size(in.z,1)==1,'''z'' should be a row vector')
        assert(~in.isdef('gz') || ~in.isdef('dgdz'),...
            ['At least one of ''gz'' and ''dgdz'' must be passed as'...
            'argument with ''z'' to compute dPf/dz'])
        compute_dPfdz=true;
    else
        compute_dPfdz=false;
    end
    if ~in.isdef('T') || ~in.isdef('dTdtheta')
        assert(~in.isdef('theta'),...
            '''theta'' value must be provided for dPf/dtheta')
        assert(in.isdef('T') || in.isdef('dTdtheta'),...
            'Only one of ''T'' and ''dTdtheta'' can be passed as argument')
    end
    if ~in.isdef('theta')
        assert(size(in.theta,1)==1,'''theta'' should be a row vector')
        assert(~in.isdef('T') || ~in.isdef('dTdtheta'),...
            ['At least one of ''T'' and ''dTdtheta'' must be passed as'...
            'argument with ''theta'' to compute dPf/dtheta'])
        compute_dPfdtheta=true;
    else
        compute_dPfdtheta=false;
    end
    % Switch on solver
    setappdata(0,'form_ls_count',0);
    switch in.solver
        case 'sqp'
            if in.LS_grad
                fmincon_opt=optimoptions('fmincon',...
                    'Algorithm','sqp','GradObj','on','Display',in.display,...
                    'GradConstr','on','MaxIter',in.iter_max,...
                    'TolCon',in.eps,'TolFun',in.eps,'TolX',in.eps);
                ukp1=fmincon(@obj,zeros(1,in.dim),...
                    [],[],[],[],[],[],@(u)nonlcon_g(u,in),fmincon_opt);
            else
                fmincon_opt=optimoptions('fmincon',...
                    'Algorithm','sqp','GradObj','on','Display',in.display,...
                    'MaxIter',in.iter_max,'TolCon',in.eps,...
                    'TolFun',in.eps,'TolX',in.eps);
                ukp1=fmincon(@obj,zeros(1,in.dim),...
                    [],[],[],[],[],[],@(u)nonlcon(u,in),fmincon_opt);
            end
        case 'hl-rf'
            ukp1=0*ones(1,in.dim);
            % Compute initial g value
            if in.LS_grad
                % If grad is provided, get gradient also
                [Gk,dGk]=g_count(ukp1,in);
            else
                % If not, just get function value
                Gk=g_count(ukp1,in);
            end
            setappdata(0,'g_ori',Gk)
            iter=0;
            while iter==0 ||...
                    (iter<in.iter_max && convergence(ukp1,uk,Gk)>in.eps) %#ok<NODEF>
                if ~in.LS_grad
                    % If gradient wasn't provided, compute finite
                    % difference
                    dGk=g_fd(ukp1,Gk,in);
                end
                % Store
                uk=ukp1;
                % Compute next step
                ukp1=alphak(uk,Gk,dGk);
                % Compute new g value
                if in.LS_grad
                    % If grad is provided, get gradient also
                    [Gk,dGk]=g_count(ukp1,in);
                else
                    % If not, just get function value
                    Gk=g_count(ukp1,in);
                end
                % Increment
                iter=iter+1;
                if strcmpi(in.display,'iter')
                    disp([sprintf('%3d',iter) ': ' num2str(convergence(ukp1,uk,Gk))])
                end
            end
            if iter==in.iter_max && ~strcmpi(in.display,'none')
                warning(['Maximum number of iterations (' num2str(iter,'%d') ') reached for hl-rf']);
            end
        case 'ihl-rf'
            ukp1=0*ones(1,in.dim);
            % Compute initial g value
            if in.LS_grad
                % If grad is provided, get gradient also
                [Gk,dGk]=g_count(ukp1,in);
            else
                % If not, just get function value
                Gk=g_count(ukp1,in);
            end
            setappdata(0,'g_ori',Gk)
            iter=0;
            while iter==0 ||...
                    (iter<in.iter_max && convergence(ukp1,uk,Gk)>in.eps) %#ok<NODEF>
                if ~in.LS_grad
                    % If gradient wasn't provided, compute finite
                    % difference
                    dGk=g_fd(ukp1,Gk,in);
                end
                % Compute descent direction
                dk=alphak(ukp1,Gk,dGk)-ukp1;
                % Store
                uk=ukp1;
                % Define search direction
                search_dir=@(s)uk+s*dk;
                % Define penality
                c=(2*norm(uk))/norm(dGk)+10;
                % Line search to maximize merit
                fminbnd_opt=optimset('Display','off','TolX',0.01);
                s_opt=fminbnd(@(s)merit(search_dir(s),c,in),0,2,fminbnd_opt);
                % Compute next step
                ukp1=search_dir(s_opt);
                % Compute new g value
                if in.LS_grad
                    % If grad is provided, get gradient also
                    [Gk,dGk]=g_count(ukp1,in);
                else
                    % If not, just get function value
                    Gk=g_count(ukp1,in);
                end
                % Increment
                iter=iter+1;
                if strcmpi(in.display,'iter')
                    disp([sprintf('%3d',iter) ': ' num2str(convergence(ukp1,uk,Gk))])
                end
            end
            if iter==in.iter_max && ~strcmpi(in.display,'none')
                warning(['Maximum number of iterations (' num2str(iter,'%d') ') reached for hl-rf']);
            end
        case 'jhl-rf'
            ukp1=0*ones(1,in.dim);
            if in.LS_grad
                % If grad is provided, get gradient also
                [Gk,dGk]=g_count(ukp1,in);
            else
                % If not, just get function value
                Gk=g_count(ukp1,in);
            end
            setappdata(0,'g_ori',Gk)
            iter=0;
            while iter==0 ||...
                    (iter<in.iter_max && convergence(ukp1,uk,Gk)>in.eps) %#ok<NODEF>
                if ~in.LS_grad
                    % If gradient wasn't provided, compute finite
                    % difference
                    dGk=g_fd(ukp1,Gk,in);
                end
                % Store
                if iter>0
                    ukm1=uk;
                    beta_km1=beta_k;
                end
                uk=ukp1;
                % Regular HL-RF
                beta_k=betak(uk,Gk,dGk);
                ukp1=alphak(uk,Gk,dGk);
                % Test for circuitous iterations
                if iter>1 && ...
                   ((ukm1*ukp1')/(norm(ukm1)*norm(ukp1))>...
                   (uk*ukp1')/(norm(uk)*norm(ukp1)))
                    beta_corr=(beta_k*Gkm1-beta_km1*Gk)/(Gkm1-Gk);
                    ukp1=beta_corr*(ukm1+uk)/(norm(ukm1+uk));
                end
                % Store
                Gkm1=Gk;
                % Compute new g value
                if in.LS_grad
                    % If grad is provided, get gradient also
                    [Gk,dGk]=g_count(ukp1,in);
                else
                    % If not, just get function value
                    Gk=g_count(ukp1,in);
                end
                % Increment
                iter=iter+1;
                if strcmpi(in.display,'iter')
                    disp([sprintf('%3d',iter) ': ' num2str(convergence(ukp1,uk,Gk))])
                end
            end
            if iter==in.iter_max && ~strcmpi(in.display,'none')
                warning(['Maximum number of iterations (' num2str(iter,'%d') ') reached for hl-rf']);
            end
    end
    beta=sign(getappdata(0,'g_ori'))*sqrt(ukp1*ukp1');
    res.Pf=normcdf(-beta);
    res.beta=beta;
    res.alpha=ukp1/beta;
    res.LS_count=getappdata(0,'form_ls_count');
    res.MPP=in.Tinv(ukp1);
    res.uMPP=ukp1;
    rmappdata(0,'g_ori')
    rmappdata(0,'form_ls_count');
    % Compute sensitivities if required
    if compute_dPfdz && ~isempty(in.z)
        if in.LS_grad
            if strcmpi(in.solver,'sqp')
                % We got nothing
                [~,dgdu]=g_count(ukp1,in);
            else
                % We already have everything
                dgdu=dGk;
            end
        else
            if strcmpi(in.solver,'sqp')
                % We got nothing
                Gk=g_count(ukp1,in);
                dgdu=g_fd(ukp1,Gk,in);
            else
                % We got g value
                dgdu=g_fd(ukp1,Gk,in);
            end
        end
        if ~in.isdef('dgdz')
            % We have dgdz
            dgdz=in.dgdz(res.MPP,in.z);
            assert(all(size(dgdz)==[1 size(in.z,2)]),...
                ['Dimension of ''dgdz'' should be [1 ' num2str(size(in.z,2)) ']'...
                ' and not [' num2str(size(dgdz,1)) ' ' num2str(size(dgdz,2)) ']'])
        else
            % We have gz, g as a function of x and z
            [dgdz,gz_val]=CODES.common.grad_fd(@(z)in.gz(res.MPP,z),...
                in.z,in.rel_diff,'type','forward');
            assert(all(size(gz_val)==[1 1]),...
                ['Dimension of ''gz'' should be [1 1]'...
                ' and not [' num2str(size(gz_val,1)) ' ' num2str(size(gz_val,2)) ']'])
        end
        res.dPfdz=-dgdz/norm(dgdu)*normpdf(-res.beta);
        res.dbetadz=dgdz/norm(dgdu);
    elseif compute_dPfdz
        % dPf/dz was requested, but z is empty
        res.dPfdz=[];
        res.dbetadz=[];
    end
    if compute_dPfdtheta && ~isempty(in.theta)
        if ~in.isdef('dTdtheta')
            % We have dTdtheta
            dTdtheta=in.dTdtheta(res.MPP,in.theta);
            assert(all(size(dTdtheta)==[1 in.dim]),...
                ['Dimension of ''dTdtheta'' should be [' num2str(in.dim) ' ' num2str(size(in.theta,2)) '] (Jacobian)'...
                ' and not [' num2str(size(dTdtheta,1)) ' ' num2str(size(dTdtheta,2)) ']'])
        else
            % We have T as a function of x and theta
            [dTdtheta,Tval]=CODES.common.grad_fd(@(theta)in.T(res.MPP,theta),...
                in.theta,in.rel_diff,'type','forward');
            assert(all(size(Tval)==[1 in.dim]),...
                ['Dimension of ''T'' should be [1 ' num2str(in.dim) ']'...
                ' and not [' num2str(size(Tval,1)) ' ' num2str(size(Tval,2)) ']'])
        end
        res.dPfdtheta=-res.alpha*dTdtheta*normpdf(-res.beta);
        res.dbetadtheta=res.alpha*dTdtheta;
    elseif compute_dPfdtheta
        % dPf/dtheta was requested, but theta is empty
        res.dPfdtheta=[];
        res.dbetadtheta=[];
    end
    % Nested function
    function decision=isdefault(input,param)
        % Test if a parameter is default
        decision=any(strcmp(input.UsingDefaults,param));
    end
    function [f,gf]=obj(u)
        % Objective function
        f=0.5*sum(u.^2,2);
        gf=u';
    end
    function [c,ceq]=nonlcon(u,in)
        % Non linear constraints for fmincon
        c=[];
        ceq=in.g(in.Tinv(u));
        if getappdata(0,'form_ls_count')==0
            setappdata(0,'g_ori',ceq)
        end
        setappdata(0,'form_ls_count',getappdata(0,'form_ls_count')+1);
    end
    function [c,ceq,Gc,Gceq]=nonlcon_g(u,in)
        % Non linear constraints for fmincon
        % With gradient
        c=[];Gc=[];
        [ceq,dy]=in.g(in.Tinv(u));
        dTinv=CODES.common.grad_fd(@in.Tinv,u,in.rel_diff);
        Gceq=dTinv'*dy';
        if getappdata(0,'form_ls_count')==0
            setappdata(0,'g_ori',ceq)
        end
        setappdata(0,'form_ls_count',getappdata(0,'form_ls_count')+1);
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
        setappdata(0,'form_ls_count',getappdata(0,'form_ls_count')+size(u,1));
    end
    function dG=g_fd(u,G,in)
        % Compute finite difference of g
        dG=CODES.common.grad_fd(@(u)g_count(u,in),u,...
            'type','forward','rel_diff',in.rel_diff,...
            'vectorial',in.vectorial,'fx',G);
    end
    function conv=convergence(uk1,uk,Gkp1)
        % Convergence measures
        conv=max([abs(norm(uk1-uk));abs(Gkp1)]);
    end
    function n=betak(u,G,dG)
        % Compute direction
        n=(G-dG*u')/(norm(dG));
    end
    function n=alphak(u,G,dG)
        % Compute direction
        n=(dG*u'-G)/(norm(dG)^2)*dG;
    end
    function f=merit(u,c,in)
        % Merit function for iHL-RF
        G=g_count(u,in);
        f=0.5*norm(u)+c*abs(G);
    end
end