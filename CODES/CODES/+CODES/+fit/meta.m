classdef meta
    % A general meta-modeling class (<a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/meta.html');web(file);">HTML</a>)
    % This class is not meant to be instantiated but rather serves for
    % inheritance purposes
    % <html>Copyright &copy; 2015 Computational Optimal Design of Engineering System Laboratory. University of Arizona.</html>\n%%\n
    properties(Access=public)
        X                   % Training samples
        Y                   % Training values
        labels              % Training labels
        X_sc                % Scaled training samples
        dim                 % Problem dimension
        n                   % Number of training samples
        scalers             % Scaling value for gradients
    end
    properties(Access=public,Hidden=true)
        UseParallel         % Define if parallel set up should be used
    end
    properties(Access=protected,Hidden=true)
        scale_method        % Scale method: 'square' or 'circle'
        mean_x              % Mean of X
        std_x               % Standard deviation of X
        lb_x                % Lower bound on X
        ub_x                % Upper bound on X
        wp                  % Standard +1 weight
        wm                  % Standard -1 weight
    end
    methods
        function dim=get.dim(meta)
            % Get # of dimensions
            dim=size(meta.X,2);
        end
        function n=get.n(meta)
            % Get # of training samples
            n=size(meta.X,1);
        end
    end
    methods(Access=public)
        function meta=meta(x,y,varargin)
            % Constructor of meta
            % Not meant to be instanciated, use for inheritance purposes
            % only
            input=inputParser;
            input.KeepUnmatched=true;
            input.PartialMatching=false;
            input.addRequired('X',@isnumeric);              % Input samples
            input.addRequired('Y',@isnumeric);              % Input function values
            input.addOptional('scale','square',...
                @(x)strcmpi(x,'square')||...
                strcmpi(x,'circle')||...
                strcmpi(x,'none'));                         % Scaling of the input
            input.addOptional('UseParallel',false,...
                @islogical);                                % Use parallel
            input.parse(x,y,varargin{:})
            in=input.Results;
            % Checks
            unmatched_params=fieldnames(input.Unmatched);
            for i=1:length(unmatched_params)
                warning(['Options ''' unmatched_params{i} ''' was not recognized']);
            end
            assert(size(in.X,1)==size(in.Y,1),...
                '# of samples should match # of responses');
            % Store
            meta.X=in.X;
            meta.Y=in.Y;
            meta.labels=meta.class(in.Y);
            meta.scale_method=in.scale;
            meta.UseParallel=in.UseParallel;
        end
        function solve(~)
            % Place holder
            % A function to JUST solve the problem with specified options
        end
        function train(~)
            % Place holder
            % A function to train the meta, usually scaling, kernel
            % parameter selections folowed by solve
        end
        function eval(meta,x)
            % Place holder
            % A function to evaluate new samples, once trained
            assert(size(x,2)==meta.dim,['Dimension of x should be ' num2str(meta.dim) ' instead of ' num2str(size(x,2)) '.'])
        end
        function [lb,ub,mean_dist]=point_dist(meta)
            dist=pdist(meta.X_sc);
            lb=min(dist);
            ub=max(dist);
            mean_dist=mean(dist);
        end
        function lab=class(~,y)
            % Classify function values y around 0
            %
            % Syntax
            %   lab=CODES.fit.meta.class(y) compute labels lab for function
            %   values y 
            %
            % See also
            % eval_class
            lab=y;
            lab(y<=0)=-1;
            lab(y>0)=+1;
        end
        function varargout=eval_class(meta,x)
            % Evaluate class of new samples x
            %
            % Syntax
            %   lab=CODES.fit.meta.eval_class(x) compute the labels lab of
            %   the input samples x
            %   [lab,y_hat]=CODES.fit.meta.eval_class(x) also returns
            %   predicted function values y_hat
            %
            % See also
            % class
            y_hat=meta.eval(x);
            lab=meta.class(y_hat);
            varargout{1}=lab;
            if nargout>1
                varargout{2}=y_hat;
            end
        end
        function x_sc=scale(meta,x)
            % Perform scaling of x
            %
            % Syntax
            %   x_sc=CODES.fit.meta.scale(x_unsc) scale x_unsc
            %
            % See also
            % unscale
            assert(size(x,2)==meta.dim,['size(x,2) should be equal to '...
                num2str(meta.dim) ' and not ' num2str(size(x,2))])
            switch meta.scale_method
                case 'square'
                    x_sc=bsxfun(@rdivide,bsxfun(@minus,x,meta.lb_x),...
                                         meta.ub_x-meta.lb_x);
                case 'circle'
                    x_sc=bsxfun(@rdivide,bsxfun(@minus,x,meta.mean_x),...
                                         meta.std_x);
                case 'none'
                    x_sc=x;
            end
        end
        function x=unscale(meta,x_sc)
            % Perform unscaling of x
            %
            % Syntax
            %   x_unsc=CODES.fit.meta.unscale(x_sc) unscale x_sc
            %
            % See also
            % scale
            assert(size(x_sc,2)==meta.dim,['size(x_sc,2) should be equal to '...
                num2str(meta.dim) ' and not ' num2str(size(x_sc,2))])
            switch meta.scale_method
                case 'square'
                    x=bsxfun(@plus,...
                        bsxfun(@times,x_sc,meta.ub_x-meta.lb_x),meta.lb_x);
                case 'circle'
                    x=bsxfun(@plus,...
                        bsxfun(@times,x_sc,meta.std_x),meta.mean_x);
                case 'none'
                    x=x_sc;
            end
        end
        function meta=add(meta,x,y)
            % Retrain meta after adding a new sample (x,y)
            %
            % Syntax
            %   meta=CODES.fit.meta.add(x,y) add a new sample x with
            %   function value y
            meta.X=[meta.X;x];
            meta.Y=[meta.Y;y];
            meta.labels=[meta.labels;meta.class(y)];
            meta=meta.train;
        end
        function stat=mse(meta,x,y)
            % Compute the Mean Square Error (MSE) for (x,y)
            %
            % Syntax
            %   stat=CODES.fit.meta.mse(x,y) compute the MSE for the
            %   samples (x,y)
            %
            % See also
            % rmse rmae r2 me
            stat=mean((y-meta.eval(x)).^2);
        end
        function stat=rmse(meta,x,y)
            % Compute the Root Mean Square Error (RMSE) for (x,y)
            %
            % Syntax
            %   stat=CODES.fit.meta.rmse(x,y) compute the RMSE for the
            %   samples (x,y)
            %
            % See also
            % mse rmae r2 me
            stat=sqrt(meta.mse(x,y));
        end
        function stat=nmse(meta,x,y)
            % Compute the Normalized Mean Square Error (NMSE) (%) for (x,y)
            %
            % Syntax
            %   stat=CODES.fit.meta.nmse(x,y) compute the NMSE for the
            %   samples (x,y)
            %
            % See also
            % mse rmse rmae r2 me
            stat=100*sum((y-meta.eval(x)).^2)/sum((y-mean(y)).^2);
        end
        function stat=rmae(meta,x,y)
            % Compute the Relative Maximum Absolute Error (RMAE) for (x,y)
            %
            % Syntax
            %   stat=CODES.fit.meta.rmae(x,y) compute the RMAE for the
            %   samples (x,y)
            %
            % See also
            % mse rmse r2 me
            stat=max(abs(y-meta.eval(x)))/std(y);
        end
        function varargout=r2(meta,x,y)
            % Compute the coefficient of determination (R squared) for (x,y)
            %
            % Syntax
            %   stat=CODES.fit.meta.r2(x,y) compute the R squared for the
            %   samples (x,y)
            %   [stat,TSS]=CODES.fit.meta.r2(...) returns the Total Sum of
            %   Squares TSS
            %   [stat,TSS,RSS]=CODES.fit.meta.r2(...) returns the Residual
            %   Sum of Squares RSS
            %
            % See also
            % mse rmse rmae me
            y_hat=meta.eval(x);
            TSS=sum((y_hat-mean(y)).^2);
            RSS=sum((y-y_hat).^2);
            varargout{1}=1-RSS/TSS;
            if nargout>1
                varargout{2}=TSS;
            end
            if nargout>2
                varargout{3}=RSS;
            end
        end
        function stat=me(meta,x,y,use_balanced)
            % Compute the Misclassification Error (ME) for (x,y) (%)
            %
            % Syntax
            %   stat=CODES.fit.meta.me(x,y) compute the ME for (x,y)
            %   stat=CODES.fit.meta.me(x,y,use_balanced) returns
            %   Balanced Misclassification Error (BME) if use_balanced is
            %   set to true
            %
            % See also
            % mse rmse rmae r2
            if nargin<4
                use_balanced=false;
            end
            if ~use_balanced
                stat=100*(mean(meta.class(y)~=meta.eval_class(x)));
            else
                labs=meta.class(y);
                weights=meta.wm*ones(size(y,1),1);
                weights(labs==+1,:)=meta.wp;
                stat=100*(mean(weights.*(labs~=meta.eval_class(x))));
            end
        end
        function varargout=auc(meta,x,y,ROC)
            % Returns the Area Under the Curve (AUC) for (x,y) (%)
            %
            % Syntax
            %   stat=CODES.fit.meta.auc(x,y) return the AUC for the samples
            %   (x,y)
            %   stat=CODES.fit.meta.auc(x,y,ROC) plot the ROC curves if ROC
            %   is set to true
            %   [stat,FP,TP]=CODES.fit.meta.auc(...) returns the false
            %   positive rate FP and the true positive rate TP
            %   
            % See also
            % me mse rmse loo cv
            if nargin<4
                ROC=false;
            end
            % Test
            lab_test=meta.class(y);
            assert(any(lab_test==+1) && any(lab_test==-1),...
                'Needs labels from both class to compute AUC');
            % Predict testing values
            n_t=size(x,1);
            y_hat=meta.eval(x);
            % Compute AUC
            [~,ind]=sort(y_hat,'descend');
            labranked=meta.class(y(ind));
            FPs=cumsum(labranked==-1)/sum(labranked==-1);   % 1-specifity
            TPs=cumsum(labranked==1)/sum(labranked==1);     % Senditivity
            varargout{1}=100*sum((FPs(2:n_t,1)-FPs(1:n_t-1,1)).*...
                (TPs(2:n_t,1)+TPs(1:n_t-1,1))/2);
            % Plot ROC if required
            if ROC
                % Plot the ROC cruve with AUC and the corresponding partial AUC.
                figure('Position',[200 200 500 500])
                plot(FPs,TPs);
                xlabel('False Positive Rate');
                ylabel('True Positive Rate');
                title(['ROC curve of (AUC = ' num2str(auc_value) ')']);
                axis square
            end
            % Outputs
            if nargout>1
                varargout{2}=FPs;
            end
            if nargout>2
                varargout{3}=TPs;
            end
        end
        function loo_error=loo(meta,varargin)
            % Returns the Leave One Out (LOO) error (%)
            %
            % Syntax
            %   stat=CODES.fit.svm.loo return the loo error stat
            %   stat=CODES.fit.svm.loo(param,value) use set of parameters
            %   param and values value, refer to the <a
            %   href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/doc/html/meta_method.html');web(file);">HTML</a>
            %   
            % See also
            % cv me mse
            input=inputParser;
            input.addOptional('use_balanced',false,...
                @islogical);                                % Use balanced metric or not (for ME only)
            input.addOptional('metric','me',...
                @(x)strcmpi(x,'me')||...                    % Misclassification Error
                strcmpi(x,'mse'));                          % Mean Square Error
            input.parse(varargin{:})
            in=input.Results;
            options=statset('UseParallel',meta.UseParallel);
            switch lower(in.metric)
                case 'me'
                    loo_error=mean(crossval(...
                        @(x_train,y_train,x_test,y_test)...
                        meta.cv_error(x_train,y_train,x_test,y_test,in.use_balanced),...
                        meta.X,meta.Y,'leaveout',1,'options',options));
                case 'mse'
                    loo_error=mean(crossval(...
                        @(x_train,y_train,x_test,y_test)...
                        meta.cv_mse(x_train,y_train,x_test,y_test),...
                        meta.X,meta.Y,'leaveout',1,'options',options));
            end
        end
        function cv_error=cv(meta,varargin)
            % Returns the Cross Validation (CV) error over 10 folds (%)
            %
            % Syntax
            %   stat=CODES.fit.svm.cv return the cv error stat
            %   stat=CODES.fit.svm.cv(use_balanced) returns the balanced cv
            %   error if use_balanced is set to true
            %   
            % See also
            % loo auc me mse
            input=inputParser;
            input.addOptional('use_balanced',false,...
                @islogical);                                % Use balanced metric or not (only for ME)
            input.addOptional('metric','me',...
                @(x)strcmpi(x,'me')||...                    % Misclassification Error
                strcmpi(x,'mse')||...                       % Mean Square Error
                strcmpi(x,'auc'));                          % Area Under the Curve
            input.parse(varargin{:})
            in=input.Results;
            options=statset('UseParallel',meta.UseParallel);
            switch lower(in.metric)
                case 'auc'
                    folds=min(sum(meta.labels==+1),sum(meta.labels==-1));
                    if folds<10
                        warning(['10 fold cross validation cannot be run, ' num2str(folds) ' folds used instead (min of n+ and n-)']);
                    else
                        folds=10;
                    end
                    cv_error=mean(crossval(...
                        @(x_train,y_train,x_test,y_test)...
                        meta.cv_auc(x_train,y_train,x_test,y_test),...
                        meta.X,meta.Y,'options',options,'stratify',meta.labels,'kfold',folds));
                case 'me'
                    cv_error=mean(crossval(...
                        @(x_train,y_train,x_test,y_test)...
                        meta.cv_error(x_train,y_train,x_test,y_test,in.use_balanced),...
                        meta.X,meta.Y,'options',options));
                case 'mse'
                    cv_error=mean(crossval(...
                        @(x_train,y_train,x_test,y_test)...
                        meta.cv_error(x_train,y_train,x_test,y_test),...
                        meta.X,meta.Y,'options',options));
            end
        end
        function stat=class_change(meta,meta_old,x)
            % Compute the change of class between two meta-models over a
            % sample x (%)
            %
            % Syntax
            %   stat=CODES.fit.meta.class_change(meta_old,x) compute the
            %   change of class of the samples x from meta-model meta_old
            %   to meta-model meta
            stat=meta.me(x,meta_old.eval(x));
        end
        function varargout=plot(meta,varargin)
            % Display the meta-model meta
            %
            % Syntax
            %   CODES.fit.meta.plot plot the meta-model meta
            %   CODES.fit.meta.plot(param,value) use set of parameters
            %   param and values value, refer to the <a
            %   href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/doc/html/meta.html');web(file);">HTML</a>
            %   documentation for details
            %   h=CODES.fit.meta.plot(...) returns graphical handles
            %   
            % See also
            % isoplot
            input=inputParser;
            input.addOptional('new_fig',false,@islogical);  % Create a new figure
            input.addOptional('lb',meta.lb_x,@isnumeric);   % Lower bound of plot
            input.addOptional('ub',meta.ub_x,@isnumeric);   % Upper bound of plot
            input.addOptional('samples',true,@islogical);   % Plot samples
            input.addOptional('lsty','k-',@(x)...
                ischar(x)||all(size(x)==[1 3]));            % Line style (1D)
            input.addOptional('psty','ko',@(x)...
                ischar(x)||all(size(x)==[1 3]));            % Samples style
            input.addOptional('prev_leg',{},@iscell);       % Previous legend entry
            input.addOptional('legend',true,@islogical);    % Add legend
            input.parse(varargin{:})
            in=input.Results;
            % Checks
            assert(meta.dim<3,'Can only plot up to ''dim''=2');
            % Plot
            if in.new_fig
                figure('Position',[200 200 500 500])
            end
            switch meta.dim
                case 1
                    x_l=linspace(in.lb,in.ub,100)';
                    meta_h=plot(x_l,meta.eval(x_l),in.lsty);
                    if in.samples
                        hold on
                        samples_h=plot(meta.X,meta.Y,in.psty);
                    end
                case 2
                    [X_g,Y_g]=meshgrid(linspace(in.lb(1),in.ub(1),100),...
                                       linspace(in.lb(2),in.ub(2),100));
                    meta_h=mesh(X_g,Y_g,reshape(meta.eval([X_g(:) Y_g(:)]),size(X_g)));
                    if in.samples
                        hold on
                        samples_h=plot3(meta.X(:,1),meta.X(:,2),meta.Y,in.psty);
                    end
            end
            if in.legend
                meta_name=strsplit(builtin('class',meta),'.');
                leg=[in.prev_leg meta_name(end)];
                if in.samples
                    leg=[leg {'samples'}];
                end
                legend(leg{:},'Location','best');
            end
            if nargout~=0
                if in.samples
                    varargout{1}=[meta_h samples_h];
                else
                    varargout{1}=meta_h;
                end
            end
            if nargout>1
                if in.legend
                    varargout{2}=leg;
                else
                    varargout{2}=[];
                end
            end
        end
        function varargout=isoplot(meta,varargin)
            % Display the 0 isocontour of the meta-model meta
            %
            % Syntax
            %   CODES.fit.meta.isoplot plot the 0 isocontour of the
            %   meta-model |meta|
            %   CODES.fit.meta.isoplot(param,value) use set of parameters
            %   param and values value, refer to the <a
            %   href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/doc/html/meta.html');web(file);">HTML</a>
            %   documentation for details
            %   h=CODES.fit.meta.isoplot(...) returns graphical handles
            %   
            % See also
            % plot
            input=inputParser;
            input.addOptional('new_fig',false,@islogical);  % Create a new figure
            input.addOptional('th',0,@isnumeric);           % Threshold value
            input.addOptional('lb',meta.lb_x,@isnumeric);   % Input samples
            input.addOptional('ub',meta.ub_x,@isnumeric);   % Input function values
            input.addOptional('samples',true,@islogical);   % Plot samples
            input.addOptional('mlsty','r-',@(x)...
                ischar(x)||all(size(x)==[1 3]));            % Line style for -1 domain (1D)
            input.addOptional('plsty','b-',@(x)...
                ischar(x)||all(size(x)==[1 3]));            % Line style for +1 domain (1D)
            input.addOptional('bcol','k',@(x)...
                ischar(x)||all(size(x)==[1 3]));            % Boundary color
            input.addOptional('mpsty','ro',@(x)...
                ischar(x)||all(size(x)==[1 3]));            % -1 samples style
            input.addOptional('ppsty','bo',@(x)...
                ischar(x)||all(size(x)==[1 3]));            % +1 samples style
            input.addOptional('use_light',true,@islogical); % Use light (3D)
            input.addOptional('prev_leg',{},@iscell);       % Previous legend entry
            input.addOptional('legend',true,@islogical);    % Samples style
            input.addOptional('resolution',100,@isnumeric); % Samples style
            input.parse(varargin{:})
            in=input.Results;
            % Checks
            assert(meta.dim<=3,'Can only plot up to ''dim''=3');
            % Plot
            if in.new_fig
                figure('Position',[200 200 500 500])
            end
            switch meta.dim
                case 1
                    got_bound=false;
                    x_l=linspace(in.lb,in.ub,in.resolution);
                    y_l=meta.eval(x_l');
                    for i=1:99
                        hold on
                        previous=y_l(i)<=in.th;
                        next=y_l(i+1)<=in.th;
                        if previous==next
                            if previous
                                plot([x_l(i) x_l(i+1)],[0 0],in.mlsty,'HandleVisibility','off');
                            else
                                plot([x_l(i) x_l(i+1)],[0 0],in.plsty,'HandleVisibility','off');
                            end
                        else
                            if got_bound
                                bound_h=plot([(x_l(i)+x_l(i+1))/2 (x_l(i)+x_l(i+1))/2],[-1 1],'--','HandleVisibility','off','Color',in.bcol);
                            else
                                bound_h=plot([(x_l(i)+x_l(i+1))/2 (x_l(i)+x_l(i+1))/2],[-1 1],'--','Color',in.bcol);
                                got_bound=true;
                            end
                        end
                    end
                    if in.samples
                        minus_h=plot(meta.X(meta.Y<=in.th,:),zeros(sum(meta.Y<=in.th),1),in.mpsty);
                        plus_h=plot(meta.X(meta.Y>in.th,:),zeros(sum(meta.Y>in.th),1),in.ppsty);
                    end
                case 2
                    [X_g,Y_g]=meshgrid(linspace(in.lb(1),in.ub(1),in.resolution),...
                                       linspace(in.lb(2),in.ub(2),in.resolution));
                    [~,bound_h]=contour(X_g,Y_g,reshape(meta.eval([X_g(:) Y_g(:)]),size(X_g)),[in.th in.th],'LineColor',in.bcol);
                    if in.samples
                        hold on
                        minus_h=plot(meta.X(meta.Y<=in.th,1),meta.X(meta.Y<=in.th,2),in.mpsty);
                        plus_h=plot(meta.X(meta.Y>in.th,1),meta.X(meta.Y>in.th,2),in.ppsty);
                    end
                case 3
                    [X_g,Y_g,Z_g]=meshgrid(linspace(in.lb(1),in.ub(1),in.resolution),...
                                           linspace(in.lb(2),in.ub(2),in.resolution),...
                                           linspace(in.lb(3),in.ub(3),in.resolution));
                    bound_h=patch(isosurface(X_g,Y_g,Z_g,reshape(meta.eval([X_g(:) Y_g(:) Z_g(:)]),size(X_g)),in.th));
                    if strcmpi(class(bound_h),'matlab.graphics.primitive.Patch')
                        bound_h.FaceColor=in.bcol;
                        bound_h.EdgeColor='none';
                    else
                        set(bound_h,'FaceColor',in.bcol);
                        set(bound_h,'EdgeColor','none');
                    end
                    view(3)
                    if in.use_light
                        camlight
                        lighting gouraud
                    end
                    if in.samples
                        hold on
                        minus_h=plot3(meta.X(meta.Y<=in.th,1),meta.X(meta.Y<=in.th,2),meta.X(meta.Y<=in.th,3),in.mpsty);
                        plus_h=plot3(meta.X(meta.Y>in.th,1),meta.X(meta.Y>in.th,2),meta.X(meta.Y>in.th,3),in.ppsty);
                    end
            end
            if in.legend
                meta_name=strsplit(builtin('class',meta),'.');
                leg=[in.prev_leg meta_name(end)];
                if in.samples
                    leg=[leg {'-1 samples' '+1 samples'}];
                end
                legend(leg{:},'Location','best');
            else
                leg=[];
            end
            if nargout==1
                if in.samples
                    varargout{1}=[bound_h minus_h plus_h];
                else
                    varargout{1}=bound_h;
                end
            elseif nargout==2
                if in.samples
                    varargout{1}=[bound_h minus_h plus_h];
                else
                    varargout{1}=bound_h;
                end
                if in.legend
                    varargout{2}=leg;
                else
                    varargout{2}=[];
                end
            end
        end
    end
    methods(Access=protected,Hidden=true)
        function meta=pre_proc(meta)
            % Pre-process the data
            meta.wp=meta.n/(2*sum(meta.labels==+1));
            meta.wm=meta.n/(2*sum(meta.labels==-1));
            meta.mean_x=mean(meta.X);
            meta.std_x=std(meta.X);
            meta.lb_x=min(meta.X);
            meta.ub_x=max(meta.X);
            meta.X_sc=meta.scale(meta.X);
            switch meta.scale_method
                case 'square'
                    meta.scalers=1./(meta.ub_x-meta.lb_x);
                case 'circle'
                    meta.scalers=1./(meta.std_x);
                case 'none'
                    meta.scalers=ones(1,meta.dim);
            end
        end
        function err=cv_error(meta,x_train,y_train,x_test,y_test,use_balanced)
            % Compute cross validated prediction error (for 1 fold)
            % If use_balanced, compute cross validated balanced prediction
            % error
            if nargin<6
                use_balanced=false;
            end
            meta.X=x_train;meta.Y=y_train;
            meta.X_sc=meta.scale(meta.X);
            meta.labels=meta.class(meta.Y);
            if isprop(meta,'Y_sc')
                meta.Y_sc=meta.unscale_y(meta.Y);
            end
            meta=meta.solve;
            err=meta.me(x_test,y_test,use_balanced);
        end
        function err=cv_mse(meta,x_train,y_train,x_test,y_test)
            % Compute cross validated mse (for 1 fold)
            % If use_balanced, compute cross validated balanced prediction
            % error
            meta.X=x_train;meta.Y=y_train;
            meta.X_sc=meta.scale(meta.X);
            meta.labels=meta.class(meta.Y);
            if isprop(meta,'Y_sc')
                meta.Y_sc=meta.unscale_y(meta.Y);
            end
            meta=meta.solve;
            err=meta.mse(x_test,y_test);
        end
        function err=cv_auc(meta,x_train,y_train,x_test,y_test)
            % Compute cross validated mse (for 1 fold)
            % If use_balanced, compute cross validated balanced prediction
            % error
            meta.X=x_train;meta.Y=y_train;
            meta.X_sc=meta.scale(meta.X);
            meta.labels=meta.class(meta.Y);
            if isprop(meta,'Y_sc')
                meta.Y_sc=meta.unscale_y(meta.Y);
            end
            meta=meta.solve;
            err=meta.auc(x_test,y_test);
        end
    end
end
