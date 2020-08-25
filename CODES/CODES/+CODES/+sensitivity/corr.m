function res=corr(X,Y,varargin)
    % Compute correlation coefficient (<a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/corr_main.html');web(file);">HTML</a>)
    %
    % Syntax
    %   res=CODES.sensitivity.corr(X,Y) compute selected correlation
    %   coefficient rho between X and Y
    %   [...]=CODES.sensitivity.sobol(...,param,value) uses a list of
    %   parameter and value, please refer to the <a
    %   href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/corr_main.html');web(file);">HTML</a>
    %   documentation
    %
    % Example
    %   f=@(x)1/8*prod(3*x.^2+1,2);
    %   X=rand(1e3,3);
    %   Y=f(X);
    %   res=CODES.sensitivity.corr(X,Y);
    %
    % See also
    % CODES.sensitivity.dgsm CODES.sensitivity.sobol
    %
    % Copyright 2013-2015 Computational Optimal Design of Engineering
    % Systems (CODES) laboratory
    input=inputParser;
    input.KeepUnmatched=false;
    input.PartialMatching=false;
    input.addRequired('X',@isnumeric);
    input.addRequired('Y',@isnumeric);
    input.addOptional('type','pearson',@(x)...
        (iscell(x)&&any(size(x)==1))||...
        strcmpi(x,'pearson')||...
        strcmpi(x,'spearman')||...
        strcmpi(x,'kendall'));                          % Correlation coefficient type
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
    input.addOptional('err_plot',false,@islogical);     % Err plot
    input.addOptional('xlabel',{},@iscell);             % X label
    input.parse(X,Y,varargin{:})
    in=input.Results;
    % Checks
    [n,dx]=size(in.X);
    assert(size(in.X,1)==size(in.Y,1),'X and Y must have same numbers of realizations');
    if any(strcmpi(input.UsingDefaults,'xlabel'))
        in.xlabel=cell(1,dx);
        for i=1:dx
            in.xlabel{i}=['$X_' num2str(i) '$'];
        end
    end
    if ~iscell(in.type)
        in.type={in.type};
    else
        for i=1:length(in.type)
            in.type{i}=lower(in.type{i});
            assert(strcmpi(in.type{i},'pearson')||strcmpi(in.type{i},'spearman')||strcmpi(in.type{i},'kendall'),'''in.type'' must be either ''pearson'', ''spearman'' , or ''kendall''');
        end
    end
    if in.err_plot
        assert(in.CI||in.CI_boot,'For error plot, ''CI'' or ''CI_boot'' must be set to true');
    end
    % Compute coefficient
    for i=1:length(in.type)
        switch in.type{i}
            case 'pearson'
                res_raw.(in.type{i}).rho=corr(in.X,in.Y,'type','Pearson')';
            case 'spearman'
                res_raw.(in.type{i}).rho=corr(in.X,in.Y,'type','Spearman')';
            case 'kendall'
                res_raw.(in.type{i}).tau=corr(in.X,in.Y,'type','Kendall')';
        end
    end
    % Compute Confidence Intervals
    if in.CI
        lq=in.alpha/2;
        uq=1-in.alpha/2;
        for i=1:length(in.type)
            switch in.type{i}
                case 'pearson'
                    se=1/sqrt(n-3);
                    res_raw.(in.type{i}).rho_CI=[...
                        tanh(atanh(permute(res_raw.(in.type{i}).rho,[3 2 1]))+norminv(lq)*se);...
                        tanh(atanh(permute(res_raw.(in.type{i}).rho,[3 2 1]))+norminv(uq)*se)];
                case 'spearman'
                    se=sqrt(1.06/(n-3));
                    res_raw.(in.type{i}).rho_CI=[...
                        tanh(atanh(permute(res_raw.(in.type{i}).rho,[3 2 1]))+norminv(lq)*se);...
                        tanh(atanh(permute(res_raw.(in.type{i}).rho,[3 2 1]))+norminv(uq)*se)];
                case 'kendall'
                    se=sqrt((2*(2*n+5))/(9*n*(n-1)));
                    res_raw.(in.type{i}).tau_CI=[...
                        permute(res_raw.(in.type{i}).tau,[3 2 1])+norminv(lq)*se;...
                        permute(res_raw.(in.type{i}).tau,[3 2 1])+norminv(uq)*se];
            end
        end
    end
    % Compute bootstraped Confidence Interval if requested
    if in.CI_boot
        CIs=bootci(in.nb_boot,{@(x)for_boot(x,in),[in.X in.Y]},'alpha',in.alpha,'type',in.boot_type);
        if length(in.type)==1 && size(in.Y,2)==1
            CIs=permute(CIs,[1 3 2 4]);
        end
        for j=1:length(in.type)
            switch in.type{j}
                case 'pearson'
                    res_raw.(in.type{j}).rho_CI_boot=permute(CIs(:,j,:,:),[1 3 4 2]);
                case 'spearman'
                    res_raw.(in.type{j}).rho_CI_boot=permute(CIs(:,j,:,:),[1 3 4 2]);
                case 'kendall'
                    res_raw.(in.type{j}).tau_CI_boot=permute(CIs(:,j,:,:),[1 3 4 2]);
            end
        end
    end
    % Construct ouput
    for j=1:length(in.type)
        switch in.type{j}
            case 'pearson'
                if ~in.CI
                    res_raw.(in.type{j}).rho_CI=[];
                end
                if ~in.CI_boot
                    res_raw.(in.type{j}).rho_CI_boot=[];
                end
                res.(in.type{j})=CODES.build.corr_out(1,...
                    res_raw.(in.type{j}).rho,...
                    res_raw.(in.type{j}).rho_CI,...
                    res_raw.(in.type{j}).rho_CI_boot,...
                    @()pie_plot(j,res_raw,in),...
                    @()err_plot(j,res_raw,in,dx),...
                    in.CI||in.CI_boot);
            case 'spearman'
                if ~in.CI
                    res_raw.(in.type{j}).rho_CI=[];
                end
                if ~in.CI_boot
                    res_raw.(in.type{j}).rho_CI_boot=[];
                end
                res.(in.type{j})=CODES.build.corr_out(1,...
                    res_raw.(in.type{j}).rho,...
                    res_raw.(in.type{j}).rho_CI,...
                    res_raw.(in.type{j}).rho_CI_boot,...
                    @()pie_plot(j,res_raw,in),...
                    @()err_plot(j,res_raw,in,dx),...
                    in.CI||in.CI_boot);
            case 'kendall'
                if ~in.CI
                    res_raw.(in.type{j}).tau_CI=[];
                end
                if ~in.CI_boot
                    res_raw.(in.type{j}).tau_CI_boot=[];
                end
                res.(in.type{j})=CODES.build.corr_out(2,...
                    res_raw.(in.type{j}).tau,...
                    res_raw.(in.type{j}).tau_CI,...
                    res_raw.(in.type{j}).tau_CI_boot,...
                    @()pie_plot(j,res_raw,in),...
                    @()err_plot(j,res_raw,in,dx),...
                    in.CI||in.CI_boot);
        end
    end
    % Pie plot if requested
    if in.pie_plot
        for i=1:length(in.type)
            pie_plot(i,res_raw,in);
        end
    end
    % Error plot
    if in.err_plot
        for i=1:length(in.type)
            err_plot(i,res_raw,in,dx);
        end
    end
    % Nested function
    function stat=for_boot(X,in)
        Xb=X(:,1:end-size(in.Y,2));
        Yb=X(:,(end-size(in.Y,2)+1):end);
        stat=zeros(length(in.type),size(Xb,2),size(Yb,2));
        for jj=1:length(in.type)
            stat(jj,:,:)=permute(corr(Xb,Yb,'type',in.type{jj}),[3 1 2]);
        end
    end
    % Pie plot
    function pie_plot(i,res_raw,in)
        for jj=1:size(in.Y,2)
            % Pie plot of the mean
            figure('Position',[200 200 500 500])
            if strcmpi(in.type{i},'kendall')
                pp=pie(2*(abs(res_raw.(in.type{i}).tau(jj,:))+eps)/sum(abs(res_raw.(in.type{i}).tau(jj,:))+eps),in.xlabel);
            else
                pp=pie(2*(abs(res_raw.(in.type{i}).rho(jj,:))+eps)/sum(abs(res_raw.(in.type{i}).rho(jj,:))+eps),in.xlabel);
            end
            set(pp(2:2:end),'interpreter','latex')
            title([upper(in.type{i}(1)) in.type{i}(2:end) ' correlation coefficients for $Y_' num2str(jj) '$'],'interpreter','latex')
        end
    end
    % Err Plot
    function err_plot(i,res_raw,in,dx)
        for k=1:size(in.Y,2)
            % Error plot of the mean
            figure('Position',[200 200 500 500])
            hold on
            legends=cell(1,in.CI+in.CI_boot);
            for jj=1:dx
                set(gca,'ColorOrderIndex',jj)
                if strcmpi(in.type{i},'kendall')
                    p=plot(jj,res_raw.(in.type{i}).tau(k,jj),'x','HandleVisibility','off');
                    if in.CI
                        plot(jj+[-0.25 0.25],res_raw.(in.type{i}).tau_CI(1,jj,k)*[1 1],'-','Color',get(p,'Color'),'HandleVisibility','off')
                        plot(jj+[-0.25 0.25],res_raw.(in.type{i}).tau_CI(2,jj,k)*[1 1],'-','Color',get(p,'Color'),'HandleVisibility','off')
                        plot(jj*[1 1],res_raw.(in.type{i}).tau_CI(:,jj,k)','-','Color',get(p,'Color'),'HandleVisibility','off')
                    end
                    if in.CI_boot
                        plot(jj+[-0.25 0.25],res_raw.(in.type{i}).tau_CI_boot(1,jj,k)*[1 1],'--','Color',get(p,'Color'),'HandleVisibility','off')
                        plot(jj+[-0.25 0.25],res_raw.(in.type{i}).tau_CI_boot(2,jj,k)*[1 1],'--','Color',get(p,'Color'),'HandleVisibility','off')
                        plot(jj*[1 1],res_raw.(in.type{i}).tau_CI_boot(:,jj,k)','--','Color',get(p,'Color'),'HandleVisibility','off')
                    end
                else
                    p=plot(jj,res_raw.(in.type{i}).rho(k,jj),'x','HandleVisibility','off');
                    if in.CI
                        plot(jj+[-0.25 0.25],res_raw.(in.type{i}).rho_CI(1,jj,k)*[1 1],'-','Color',get(p,'Color'),'HandleVisibility','off')
                        plot(jj+[-0.25 0.25],res_raw.(in.type{i}).rho_CI(2,jj,k)*[1 1],'-','Color',get(p,'Color'),'HandleVisibility','off')
                        plot(jj*[1 1],res_raw.(in.type{i}).rho_CI(:,jj,k)','-','Color',get(p,'Color'),'HandleVisibility','off')
                    end
                    if in.CI_boot
                        plot(jj+[-0.25 0.25],res_raw.(in.type{i}).rho_CI_boot(1,jj,k)*[1 1],'--','Color',get(p,'Color'),'HandleVisibility','off')
                        plot(jj+[-0.25 0.25],res_raw.(in.type{i}).rho_CI_boot(2,jj,k)*[1 1],'--','Color',get(p,'Color'),'HandleVisibility','off')
                        plot(jj*[1 1],res_raw.(in.type{i}).rho_CI_boot(:,jj,k)','--','Color',get(p,'Color'),'HandleVisibility','off')
                    end
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
            plot([0.5 dx+0.5],[0 0],'k-','HandleVisibility','off','LineWidth',0.1)
            plot([0.5 dx+0.5],[0.5 0.5],'k--','HandleVisibility','off','LineWidth',0.1)
            plot([0.5 dx+0.5],[-0.5 -0.5],'k--','HandleVisibility','off','LineWidth',0.1)
            plot([0.5 dx+0.5],[0.25 0.25],'k-.','HandleVisibility','off','LineWidth',0.1)
            plot([0.5 dx+0.5],[-0.25 -0.25],'k-.','HandleVisibility','off','LineWidth',0.1)
            plot([0.5 dx+0.5],[0.75 0.75],'k-.','HandleVisibility','off','LineWidth',0.1)
            plot([0.5 dx+0.5],[-0.75 -0.75],'k-.','HandleVisibility','off','LineWidth',0.1)
            leg=legend(legends,'location','best','location','best');
            set(leg,'interpreter','latex')
            set(gca,'xtick',1:dx,'xticklabel',in.xlabel,'ticklabelinterpreter','latex','ylim',[-1 1])
            title([upper(in.type{i}(1)) in.type{i}(2:end) ' correlation coefficients for $Y_' num2str(k) '$'],'interpreter','latex')
        end
    end
end
