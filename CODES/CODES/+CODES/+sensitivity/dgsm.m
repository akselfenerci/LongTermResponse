function res=dgsm(dY,varargin)
    % Compute derivative-based sensitivity measure (<a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/dgsm.html');web(file);">HTML</a>)
    %
    % Syntax
    %   res=CODES.sensitivity.dgsm(dY) compute Elementary Effects and/or
    %   Derivative-based Global Sensitivity Measures based on the vector of
    %   partial derivatives dY. dY should have sizes (n x nX x nY), where n
    %   is the number of samples, nX the number of input variables and nY
    %   the number of outputs.
    %   [...]=CODES.sensitivity.dgsm(...,param,value) uses a list of
    %   parameter and value, please refer to the <a
    %   href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/dgsm.html');web(file);">HTML</a>
    %   documentation
    %
    % Example
    %   f=@(x)1/8*prod(3*x.^2+1,2);
    %   X=rand(1e3,3);
    %   dY=CODES.common.grad_fd(f,X);
    %   res=CODES.sensitivity.dgsm(dY);
    %
    % See also
    % CODES.sensitivity.sobol CODES.sensitivity.corr
    %
    % Copyright 2013-2015 Computational Optimal Design of Engineering
    % Systems (CODES) laboratory
    input=inputParser;
    input.KeepUnmatched=false;
    input.PartialMatching=false;
    input.addRequired('dY',@isnumeric);
    input.addOptional('type','EE',@(x)...
        (iscell(x)&&any(size(x)==1))||...
        strcmpi(x,'EE')||...
        strcmpi(x,'DGSM1')||...
        strcmpi(x,'DGSM2'));                            % Correlation coefficient type
    input.addOptional('alpha',0.05,@isnumeric);         % Significance level
    input.addOptional('CI',false,@islogical);           % Compute Confidence Interval or not
    input.addOptional('CI_boot',false,@islogical);      % Compute Confidence Interval using bootstrap
    input.addOptional('nb_boot',200,@isnumeric);        % Number of bootstrap
    input.addOptional('boot_type','bca',@(x)...
        strcmp(x,'bca')||...
        strcmp(x,'norm')||...
        strcmp(x,'per')||...
        strcmp(x,'cper'));                              % Bootstrap CI type
    input.addOptional('pie_plot',false,@islogical);     % Pie plot
    input.addOptional('err_plot',false,@islogical);     % Err plot, triger CI
    input.addOptional('xlabel',{},@iscell);             % X label
    input.parse(dY,varargin{:})
    in=input.Results;
    % Checks
    [n,dx,~]=size(dY);
    if ~iscell(in.type)
        in.type={in.type};
    else
        for i=1:length(in.type)
            in.type{i}=upper(in.type{i});
            assert(strcmpi(in.type{i},'EE')||strcmpi(in.type{i},'DGSM1')||strcmpi(in.type{i},'DGSM2'),'''in.type'' must be either ''EE'', ''DGSM1'' , or ''DGSM2''');
        end
    end
    if any(strcmpi(input.UsingDefaults,'xlabel'))
        in.xlabel=cell(1,dx);
        for i=1:dx
            in.xlabel{i}=['$X_' num2str(i) '$'];
        end
    end
    if in.err_plot
        assert(in.CI||in.CI_boot,'For error plot, ''CI'' or ''CI_boot'' must be set to true');
    end
    % Compute coefficient
    for j=1:length(in.type)
        switch upper(in.type{j})
            case 'EE'
                res_raw.(in.type{j}).mu=permute(mean(dY),[3 2 1]);
                res_raw.(in.type{j}).std=permute(std(dY),[3 2 1]);
            case 'DGSM1'
                res_raw.(in.type{j}).mu=permute(mean(abs(dY)),[3 2 1]);
                res_raw.(in.type{j}).std=permute(std(abs(dY)),[3 2 1]);
            case 'DGSM2'
                res_raw.(in.type{j}).mu=permute(mean(dY.^2),[3 2 1]);
                res_raw.(in.type{j}).std=permute(std(dY.^2),[3 2 1]);
        end
    end
    % Compute Confidence Interval if requested
    if in.CI
        lq=in.alpha/2;
        uq=1-in.alpha/2;
        for j=1:length(in.type)
            res_raw.(in.type{j}).mu_CI=bsxfun(@minus,...
                permute(res_raw.(in.type{j}).mu,[3 2 1]),...
                bsxfun(@times,...
                    permute(res_raw.(in.type{j}).std,[3 2 1]),...
                    norminv([uq;lq]))/sqrt(n));
            res_raw.(in.type{j}).std_CI=sqrt((n-1)*bsxfun(@rdivide,...
                permute(res_raw.(in.type{j}).std,[3 2 1]).^2,...
                chi2inv([uq;lq],n-1)));
        end
    end
    % Compute bootstraped Confidence Interval if requested
    if in.CI_boot
        CIs=bootci(in.nb_boot,{@(x)for_boot(x,in),in.dY},'alpha',in.alpha,'type',in.boot_type);
        for j=1:length(in.type)
            res_raw.(in.type{j}).mu_CI_boot=permute(CIs(:,2*(j-1)+1,:,:),[1 3 4 2]);
            res_raw.(in.type{j}).std_CI_boot=permute(CIs(:,2*(j-1)+2,:,:),[1 3 4 2]);
        end
    end
    % Construct ouput
    for j=1:length(in.type)
        if ~in.CI
            res_raw.(in.type{j}).mu_CI=[];
            res_raw.(in.type{j}).std_CI=[];
        end
        if ~in.CI_boot
            res_raw.(in.type{j}).mu_CI_boot=[];
            res_raw.(in.type{j}).std_CI_boot=[];
        end
        res.(in.type{j})=CODES.build.dgsm_out(...
            res_raw.(in.type{j}).mu,...
            res_raw.(in.type{j}).std,...
            {res_raw.(in.type{j}).mu_CI,res_raw.(in.type{j}).std_CI},...
            {res_raw.(in.type{j}).mu_CI_boot,res_raw.(in.type{j}).std_CI_boot},...
            @()pie_plot(j,res_raw,in),...
            @()err_plot(j,res_raw,in,dx),...
            in.CI||in.CI_boot);
    end
    % Pie plot if asked for
    if in.pie_plot
        for i=1:length(in.type)
            pie_plot(i,res_raw,in)
        end
    end
    % Error plot if asked for
    if in.err_plot
        for i=1:length(in.type)
            err_plot(i,res_raw,in,dx)
        end
    end
    % Nested function
    function stat=for_boot(dY,in)
        stat=zeros(2*length(in.type),size(dY,2),size(dY,3));
        for jj=1:length(in.type)
            switch upper(in.type{jj})
                case 'EE'
                    stat(2*(jj-1)+1,:,:)=mean(dY);
                    stat(2*(jj-1)+2,:,:)=std(dY);
                case 'DGSM1'
                    stat(2*(jj-1)+1,:,:)=mean(abs(dY));
                    stat(2*(jj-1)+2,:,:)=std(abs(dY));
                case 'DGSM2'
                    stat(2*(jj-1)+1,:,:)=mean(dY.^2);
                    stat(2*(jj-1)+2,:,:)=std(dY.^2);
            end
        end
    end
    % Pie plot
    function pie_plot(i,res_raw,in)
        for jj=1:size(res_raw.(in.type{i}).mu,1)
            % Pie plot of the mean
            figure('Position',[200 200 500 500])
            pp=pie(2*(abs(res_raw.(in.type{i}).mu(jj,:))+eps)/sum(abs(res_raw.(in.type{i}).mu(jj,:))+eps),in.xlabel);
            set(pp(2:2:end),'interpreter','latex')
            title(['Mean of ' in.type{i}],'interpreter','latex')
            % Pie plot of the standard deviation
            figure('Position',[715 200 500 500])
            pp=pie(2*(abs(res_raw.(in.type{i}).std(jj,:))+eps)/sum(abs(res_raw.(in.type{i}).std(jj,:))+eps),in.xlabel);
            set(pp(2:2:end),'interpreter','latex')
            title(['Standard deviation of ' in.type{i} ' for $Y_' num2str(jj) '$'],'interpreter','latex')
        end
    end
    % Err plot
    function err_plot(i,res_raw,in,dx)
        % Error plot of the mean
        for k=1:size(res_raw.(in.type{i}).mu,1)
            figure('Position',[200 200 500 500])
            hold on
            legends=cell(1,in.CI+in.CI_boot);
            for jj=1:dx
                set(gca,'ColorOrderIndex',jj)
                p=plot(jj,res_raw.(in.type{i}).mu(k,jj),'x','HandleVisibility','off');
                if in.CI
                    plot(jj+[-0.25 0.25],res_raw.(in.type{i}).mu_CI(1,jj,k)*[1 1],'-','Color',get(p,'Color'),'HandleVisibility','off')
                    plot(jj+[-0.25 0.25],res_raw.(in.type{i}).mu_CI(2,jj,k)*[1 1],'-','Color',get(p,'Color'),'HandleVisibility','off')
                    plot(jj*[1 1],res_raw.(in.type{i}).mu_CI(:,jj,k)','-','Color',get(p,'Color'),'HandleVisibility','off')
                end
                if in.CI_boot
                    plot(jj+[-0.25 0.25],res_raw.(in.type{i}).mu_CI_boot(1,jj,k)*[1 1],'--','Color',get(p,'Color'),'HandleVisibility','off')
                    plot(jj+[-0.25 0.25],res_raw.(in.type{i}).mu_CI_boot(2,jj,k)*[1 1],'--','Color',get(p,'Color'),'HandleVisibility','off')
                    plot(jj*[1 1],res_raw.(in.type{i}).mu_CI_boot(:,jj,k)','--','Color',get(p,'Color'),'HandleVisibility','off')
                end
            end
            if in.CI
                plot([0 0],[0 0],'k-','Visible','off')
                legends{in.CI}='CI';
            end
            if in.CI_boot
                plot([0 0],[0 0],'k--','Visible','off')
                legends{in.CI+in.CI_boot}='CI boot';
            end
            leg=legend(legends,'location','best','location','best');
            set(leg,'interpreter','latex')
            set(gca,'xtick',1:dx,'xticklabel',in.xlabel,'ticklabelinterpreter','latex')
            title(['Mean of ' in.type{i} ' for $Y_' num2str(k) '$'],'interpreter','latex')
            % Error plot of the standard deviation
            figure('Position',[715 200 500 500])
            hold on
            for jj=1:dx
                set(gca,'ColorOrderIndex',jj)
                p=plot(jj,res_raw.(in.type{i}).std(k,jj),'x','HandleVisibility','off');
                if in.CI
                    plot(jj+[-0.25 0.25],res_raw.(in.type{i}).std_CI(1,jj,k)*[1 1],'-','Color',get(p,'Color'),'HandleVisibility','off')
                    plot(jj+[-0.25 0.25],res_raw.(in.type{i}).std_CI(2,jj,k)*[1 1],'-','Color',get(p,'Color'),'HandleVisibility','off')
                    plot(jj*[1 1],res_raw.(in.type{i}).std_CI(:,jj,k)','-','Color',get(p,'Color'),'HandleVisibility','off')
                end
                if in.CI_boot
                    plot(jj+[-0.25 0.25],res_raw.(in.type{i}).std_CI_boot(1,jj,k)*[1 1],'--','Color',get(p,'Color'),'HandleVisibility','off')
                    plot(jj+[-0.25 0.25],res_raw.(in.type{i}).std_CI_boot(2,jj,k)*[1 1],'--','Color',get(p,'Color'),'HandleVisibility','off')
                    plot(jj*[1 1],res_raw.(in.type{i}).std_CI_boot(:,jj,k)','--','Color',get(p,'Color'),'HandleVisibility','off')
                end
            end
            if in.CI
                plot([0 0],[0 0],'k-','Visible','off')
            end
            if in.CI_boot
                plot([0 0],[0 0],'k--','Visible','off')
            end
            leg=legend(legends,'location','best','location','best');
            set(leg,'interpreter','latex')
            set(gca,'xtick',1:dx,'xticklabel',in.xlabel,'ticklabelinterpreter','latex')
            title(['Standard deviation of ' in.type{i} ' for $Y_' num2str(k) '$'],'interpreter','latex')
        end
    end
end

