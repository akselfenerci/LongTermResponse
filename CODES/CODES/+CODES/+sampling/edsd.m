function varargout=edsd(f,M,lb,ub,varargin)
    % Perform Explicit Design Space Decomposition (<a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/edsd.html');web(file);">HTML</a>)
    %
    % Syntax
    %   M_col=CODES.sampling.edsd(f,M,lb,ub) perform EDSD on f, using an
    %   initial meta-model M, within lb and ub and return the collection of
    %   meta-model M_col
    %   M_col=CODES.sampling.edsd(f,M,lb,ub,param,value) uses a list of
    %   parameter and value, please refer to the <a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/doc/html/edsd.html');web(file);">HTML</a> documentation
    %
    % Example
    %   DOE=CODES.sampling.cvt(20,2,'lb',[-5 -5],'ub',[5 5]);
    %   svm=CODES.fit.svm(DOE,DOE(:,1)-DOE(:,2));
    %   svm_col=CODES.sampling.edsd(@(x)(x(:,1)-x(:,2)),svm,[0 0],[1 1],'iter_max',5);
    %   figure('Position',[200 200 500 500])
    %   hold on
    %   for i=1:5
    %       svm_col{i}.isoplot('lb',[-5 -5],'ub',[5 5])
    %   end
    %   axis square
    %
    % See also
    % CODES.sampling.mm, CODES.sampling.anti_lock
    %
    % Copyright 2013-2015 Computational Optimal Design of Engineering
    % Systems (CODES) laboratory
    input=inputParser;
    input.KeepUnmatched=true;
    input.addRequired('f',@(x)isa(x,'function_handle'));
    input.addRequired('M',@(x)isa(x,'CODES.fit.meta'));
    input.addRequired('lb',@isnumeric);                 % Lower bound for side constraints
    input.addRequired('ub',@isnumeric);                 % Upper bound for side constraints
    input.addOptional('schedule',[2 1],@isnumeric);     % Schedule to alternate mm and al
    input.addOptional('iter_max',30,@isnumeric);        % Maximum of iterations
    input.addOptional('vectorized',true,@islogical);    % Is function f vectorized
    input.addOptional('f_parallel',false,@islogical);   % When f is not vectorized, should f be evaluated in parallel
    input.addOptional('extra_output',false,@islogical); % Is function f returning a second output that needs to be stored and returned
    input.addOptional('conv',true,@islogical);          % Use conv
    input.addOptional('plot_conv',false,@islogical);    % Plot conv
    input.addOptional('conv_coef','fit',...
        @(x)(strcmpi(x,'fit')||strcmpi(x,'direct')));   % Method to compute conv exponential coefficient
    input.addOptional('eps_1',4e-3,@isnumeric);         % Value conv tol
    input.addOptional('eps_2',5e-4,@isnumeric);         % Slope conv tol
    input.addOptional('x_conv',0,@isnumeric);           % Convergence points
    input.addOptional('display_edsd',true,@islogical);  % Display level
    input.addOptional('plotfcn',[],@(x)...
        isa(x,'function_handle')||...
        isempty(x)||iscell(x));                         % Plot functions
    input.parse(f,M,lb,ub,varargin{:})
    in=input.Results;
    % Initialize
    iter=1;
    kind=1;
    M_col=cell(in.iter_max+1,1);
    M_col{iter}=in.M;
    exit_flag=[];
    if ~isempty(in.plotfcn)
        if isa(in.plotfcn,'function_handle')
            nb_plotfcn=1;
            in.plotfcn={in.plotfcn};
        else
            assert(any(size(in.plotfcn)==1),'''plotfcn'' should be a row or column cell')
            nb_plotfcn=length(in.plotfcn);
        end
        fh=zeros(nb_plotfcn,1);
        for i=1:nb_plotfcn
            fh(i)=figure('Position',[200 200 500 500],'Name',['User defined plot function ' num2str(i)]);
            hold on
        end
    else
        nb_plotfcn=0;
    end
    % Convergence setup
    conv_stop=false;
    model=@(A,B,x)A*exp(B*x);
    slope=@(A,B,x)B*A*exp(B*x);
    delta=zeros(in.iter_max,1);
    % Check if convergence should be checked
    if in.conv && any(strcmp(input.UsingDefaults,'x_conv'))
        in.x_conv=in.M.unscale(lhsdesign(1e4,in.M.dim));
    end
    if in.plot_conv
        fc=figure('Position',[200 200 500 500],'Name','EDSD convergence');
    end
    % Iterate
    while iter<=in.iter_max && ~conv_stop
        if kind<=in.schedule(1)         % Decide on sample type based on schedule
            x_new=CODES.sampling.mm(M_col{iter},in.lb,in.ub,input.Unmatched);
        else
            x_new=CODES.sampling.anti_lock(M_col{iter},in.lb,in.ub,input.Unmatched);
        end
        kind=kind+1;
        if kind>sum(in.schedule)
            kind=1;
        end
        if in.vectorized                % Compute new samples
            if in.extra_output
                if iter==1
                    [f_new,extra_output_values]=in.f(x_new);
                else
                    tag=size(extra_output_values,1);
                    [f_new,extra_output_values(tag+1:tag+size(x_new,1),:)]=in.f(x_new);
                end
            else
                f_new=in.f(x_new);
            end
        else
            f_new=zeros(size(x_new,1),1);
            if in.extra_output
                if iter==1
                    [f_new(1,:),extra_output_values]=in.f(x_new(1,:));
                    tag=size(extra_output_values,1);
                    if in.f_parallel
                        extra_output_values_temp=cell(size(x_new,1)-1,size(extra_output_values,2));
                        parfor i=2:size(x_new,1)
                            [f_new(i,:),extra_output_values_temp(i-1,:)]=in.f(x_new(i,:));  %#ok<PFBNS>
                        end
                        extra_output_values(tag+1:(tag-1+size(x_new,1)),:)=extra_output_values_temp;
                    else
                        extra_output_values(tag+1:(tag-1+size(x_new,1)),:)={0};
                        for i=2:size(x_new,1)
                            [f_new(i,:),extra_output_values(tag-1+i,:)]=in.f(x_new(i,:));
                        end
                    end
                else
                    tag=size(extra_output_values,1);
                    if in.f_parallel
                        extra_output_values_temp=cell(size(x_new,1),size(extra_output_values,2));
                        parfor i=1:size(x_new,1)
                            [f_new(i,:),extra_output_values_temp(i,:)]=in.f(x_new(i,:));    %#ok<PFBNS>
                        end
                        extra_output_values(tag+1:(tag+size(x_new,1)),:)=extra_output_values_temp;
                    else
                        extra_output_values(tag+1:(tag+size(x_new,1)),:)={0};
                        for i=1:size(x_new,1)
                            [f_new(i,:),extra_output_values(tag+i,:)]=in.f(x_new(i,:));
                        end
                    end
                end
            else
                if in.f_parallel
                    parfor i=1:size(x_new,1)
                        f_new(i,:)=in.f(x_new(i,:));    %#ok<PFBNS>
                    end
                else
                    for i=1:size(x_new,1)
                        f_new(i,:)=in.f(x_new(i,:));
                    end
                end
            end
        end
        M_col{iter+1}=M_col{iter}.add(x_new,f_new);     % Add new sample
        if in.conv
            delta(iter)=M_col{iter+1}.class_change(M_col{iter},in.x_conv)/100;
            if iter>=3
                B_guess=1/(iter-1)*log(max(delta(iter),1e-8)/max(delta(1),1e-8));   % max is used to protec from log(0) or division by 0
                A_guess=delta(1)/exp(B_guess);
                switch in.conv_coef     % How to compute convergence coefficient
                    case 'fit'
                        myfit=fit((1:iter)',delta(1:iter),model,'StartPoint',[A_guess B_guess],'Lower',[-Inf -Inf],'Upper',[Inf 0]);
                        A_conv=myfit.A;
                        B_conv=myfit.B;
                    case 'direct'
                        A_conv=A_guess;
                        B_conv=B_guess;
                end
                if in.plot_conv
                    figure(fc)
                    clf
                    plot(1:iter,delta(1:iter),'b')
                    hold on
                    plot(linspace(1,iter,100),model(A_conv,B_conv,linspace(1,iter,100)),'r')
                    legend('True','Fitted')
                    xlabel('iterations')
                    ylabel('Class change')
                end
                if model(A_conv,B_conv,iter)<in.eps_1 && -in.eps_2<slope(A_conv,B_conv,iter)      % Check convergence
                    conv_stop=true;
                    exit_flag=1;
                end
            end
        end
        if in.display_edsd
            disp(['EDSD: iteration ' num2str(iter) ' out of ' num2str(in.iter_max) ' is done'])
        end
        if nb_plotfcn~=0
            for i=1:nb_plotfcn
                figure(fh(i))
                in.plotfcn{i}(M_col{iter+1},iter);
            end
            drawnow;
        end
        iter=iter+1;
    end
    if iter>in.iter_max
        exit_flag=2;
    end
    if in.display_edsd
        switch exit_flag
            case 1
                disp('EDSD: Stopped because convergence was reached')
            case 2
                disp('EDSD: Stopped because maximum number of iteration was reached')
        end
    end
    varargout{1}=M_col(2:iter);
    if nargout>1
        varargout{2}=extra_output_values;
    end
end
