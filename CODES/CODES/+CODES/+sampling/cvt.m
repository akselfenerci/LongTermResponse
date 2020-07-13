function X=cvt(N,dim,varargin)
    % Generate CVT samples within a given region (<a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/cvt.html');web(file);">HTML</a>)
    %
    % Syntax
    %   x=CODES.sampling.cvt(N,dim) perform a CVT design of N point in dim
    %   dimension
    %   x=CODES.sampling.cvt(N,dim,param,value) use a list of parameters and
    %   values, please refer to the <a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/cvt.html');web(file);">HTML</a> documentation
    %
    % Example
    %   x=CODES.sampling.cvt(9,2);
    %   plot(x(:,1),x(:,2),'bo')
    %   axis([0 1 0 1])
    %   axis square
    %
    % Copyright 2013-2015 Computational Optimal Design of Engineering
    % Systems (CODES) laboratory
    input=inputParser;
    input.addRequired('N',@isnumeric);                  % Sample size
    input.addRequired('dim',@isnumeric);                % Dimensions
    input.addOptional('dummies',1e5,@isnumeric);        % Number of dummy points
    input.addOptional('max_iter',50,@isnumeric);        % Maximum number of iterations
    input.addOptional('delta',1e-4,@isnumeric);         % Stopping tolerance
    input.addOptional('lb',zeros(1,dim),@isnumeric);    % Lower bound
    input.addOptional('ub',ones(1,dim),@isnumeric);     % Upper bound
    input.addOptional('halton',true,@islogical);        % Use Halton sequence instead of random
    input.addOptional('kmeans',false,@islogical);       % Uses matlab kmeans
    input.addOptional('kmean_options',{},@iscell);      % A name-value cell options for kmeans function
    input.addOptional('display',true,@islogical);       % Display
    input.addOptional('force_new',false,@islogical);    % Force to make new CVT
    input.addOptional('force_save',false,@islogical);   % Force save
    input.addOptional('region',[],...
        @(x)isempty(x)||isa(x,'function_handle'));      % Function that defines a specific region (>=0)
    input.parse(N,dim,varargin{:})
    in=input.Results;
    % Check
    assert(dim==size(in.lb,2),'Wrong dimension for lb')
    assert(dim==size(in.ub,2),'Wrong dimension for ub')
    if ~all(size(in.dummies)==[1 1])
        assert(size(in.dummies,2)==in.dim,'Dimensions of ''dummies'' should match requested dimension')
    end
    if in.force_save && ~all(size(in.dummies)==[1 1])
        assert(all(in.dummies(:)>0) && all(in.dummies(:)<1),'For CVT to be saved, dummies should be between 0 and 1');
    end
    % Define an exponential decay to decide stop criterion
    model=@(A,B,C,x)A*exp(B*x)+C;
    rel_change=@(x,fit)(fit.A*fit.B*exp(fit.B*x))/(fit.A*exp(fit.B*x)+fit.C);
    % If squared design already exist, load it
    filename=fullfile(fileparts(which('CODES.sampling.cvt')),...
        'cvt_design',['cvt_d' num2str(dim) '_n' num2str(N) '.mat']);
    if any(strcmp(input.UsingDefaults,'region')) &&...
            any(strcmp(input.UsingDefaults,'dummies')) &&...
            exist(filename,'file') && ~in.force_new
        X=load(filename);
        X=unscale(X.X,in.lb,in.ub);
    else
        if in.kmeans
            [~,X]=kmeans(get_dummies(input,in,0),in.N);
        else
            shift=0;
            change=Inf*ones(in.max_iter,1);
            j=1;
            while j<=10 || (j<=in.max_iter && change(max(1,j-1))>in.delta && abs(rel_change(j,myfit))>in.delta) %#ok<NODEF>
                [x,shift]=get_dummies(input,in,shift);
                if j==1
                    X=x(1:in.N,:);
                end
                ind=closest(X,x);
                for i=1:in.N
                    X(i,:)=mean(x(ind==i,:));
                end
                if j~=1
                    change(j)=sum(sum((X-old_X).^2));
                end
                if j>=4
                    myfit=fit((2:j)',change(2:j),model,'StartPoint',[4 -1 min(change(2:j))],'Lower',[-Inf -Inf 0],'Upper',[Inf 0 max(change(2:j))]);
                end
                if in.display
                    if j>1
                        if j>=4
                            disp(['Sum of square change at iteration ' num2str(j-1) ': ' num2str(change(j),'%1.3e') '; Predicted relative change : ' num2str(abs(rel_change(j,myfit)),'%1.3e')])
                        else
                            disp(['Sum of square change at iteration ' num2str(j-1) ': ' num2str(change(j),'%1.3e')])
                        end
                    end
                end
                old_X=X;
                j=j+1;
            end
        end
        if in.force_save || (any(strcmp(input.UsingDefaults,'region')) && any(strcmp(input.UsingDefaults,'dummies')))
            save(filename,'X');
        end
        if  all(size(in.dummies)==[1 1])
            X=unscale(X,in.lb,in.ub);
        end
    end
    % Nested
    function [x,tried]=get_dummies(input,in,shift)
        if ~all(size(in.dummies)==[1 1])                % Use specified dummies
            assert(in.dim==size(in.dummies,2),'Dummies should have same dimension as the one requested')
            x=in.dummies;
            tried=0;
        else
            if any(strcmp(input.UsingDefaults,'region'))% If no region defined
                if in.halton
                    x=haltonset(in.dim,'Skip',shift);
                    x=x(1:in.dummies,:);
                else
                    x=rand(in.dummies,in.dim);
                end
                tried=in.dummies;
            else                                        % If a region is defined
                if in.halton
                    x_halton=haltonset(in.dim,'Skip',shift);
                    x=zeros(in.dummies,in.dim);
                    x_prop=x_halton(1:in.dummies,:);
                    y_prop=in.region(unscale(x_prop,in.lb,in.ub));
                    valid=y_prop>=0;
                    found=sum(valid);
                    tried=in.dummies;
                    x(1:found,:)=x_prop(valid,:);
                    while found<in.dummies
                        missing=in.dummies-found;
                        will_try=2*missing+100;
                        x_prop=x_halton((tried+1):(tried+1+will_try),:);
                        y_prop=in.region(unscale(x_prop,in.lb,in.ub));
                        valid=y_prop>=0;
                        nb_valid=sum(valid);
                        if nb_valid>missing
                            x_feasible=x_prop(valid,:);
                            x((found+1):end,:)=x_feasible(1:missing,:);
                            found=in.dummies;
                        else
                            x((found+1):(found+nb_valid),:)=x_prop(valid,:);
                            found=found+nb_valid;
                        end
                        tried=tried+will_try;
                    end
                else
                    x=zeros(in.dummies,in.dim);
                    x_prop=rand(in.dummies,in.dim);
                    y_prop=in.region(unscale(x_prop,in.lb,in.ub));
                    valid=y_prop>=0;
                    found=sum(valid);
                    tried=in.dummies;
                    x(1:found,:)=x_prop(valid,:);
                    while found<in.dummies
                        missing=in.dummies-found;
                        will_try=2*missing+100;
                        x_prop=rand(will_try,in.dim);
                        y_prop=in.region(unscale(x_prop,in.lb,in.ub));
                        valid=y_prop>=0;
                        nb_valid=sum(valid);
                        if nb_valid>missing
                            x_feasible=x_prop(valid,:);
                            x((found+1):end,:)=x_feasible(1:missing,:);
                            found=in.dummies;
                        else
                            x((found+1):(found+1+nb_valid))=x_prop(valid,:);
                            found=found+nb_valid;
                        end
                        tried=tried+will_try;
                    end
                end
            end
        end
    end
    function x=unscale(x,lb,ub)
        x=bsxfun(@plus,bsxfun(@times,x,ub-lb),lb);
    end
    function ind=closest(centers,dummies)
        dist=pdist2(centers,dummies);
        min_dist=min(dist);
        [row,col]=find(bsxfun(@eq,dist,min_dist));
        [~,pos,~]=unique(col);
        ind=row(pos);
    end
end

