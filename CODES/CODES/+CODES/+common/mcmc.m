function [varargout]=mcmc(sites,N,PDFs_target,varargin)
    % Component Metropolis-Hastings (<a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/mcmc.html');web(file);">HTML</a>)
    %
    % Syntax
    %   x=CODES.common.mcmc(sites,N,PDFs_target) performs component
    %   Metropolis-Hastings. sites is a (nc x dim) matrix used to start nc
    %   Markov-chain. Each chain as N samples and x is the (N x dim x Nc)
    %   matrix of generated samples. PDFs_target is the target marginal
    %   PDFs. For a (n x dim) sample, PDFs_target(x) should return a (n x
    %   dim) matrix of marginal PDF values.
    %   [x,y]=CODES.common.mcmc(sites,N,PDFs_target) returns the (N x 1 x
    %   nc) array y of rejection function values (requires a rejection
    %   function).
    %   [x,y,dy]=CODES.common.mcmc(sites,N,PDFs_target) returns the (N x dim
    %   x Nc) array dy of rejection gradient (requires a rejection function
    %   and gradient option).
    %   [...]=CODES.sampling.mcmc(...,param,value) uses a list of parameter and
    %   value, please refer to the <a href="matlab:a=fileparts(which('CODES.install'));file=strcat(a,'/+doc/html/mcmc.html');web(file);">HTML</a> documentation
    %
    % Example
    %    pdf=@(x)exppdf(x,1);
    %    rejection=@(x)2-x;
    %    x_mcmc=CODES.common.mcmc(3,2000,pdf,'rejection',rejection);
    %    CODES.common.hist_fd(x_mcmc,@(x)exppdf(x,1)/(1-expcdf(2,1)))
    %
    % Copyright 2013-2015 Computational Optimal Design of Engineering
    % Systems (CODES) laboratory
    input=inputParser;
    input.addRequired('sites',@isnumeric);                      % Initial points for different chains
    input.addRequired('N',@isnumeric);                          % Number of Points per sites
    input.addRequired('PDFs_target',...
        @(x)isa(x,'function_handle'));                          % Target marginal PDFs to draw MCMC samples from
    input.addOptional('prop_rand',@(x)normrnd(x,ones(size(x))),...
        @(x)isa(x,'function_handle'));                          % Proposal sampler to create new samples
    input.addOptional('burnin',0,@isnumeric);                   % Burnin amount
    input.addOptional('rejection',@(x)(-ones(size(x,1),1)),...
        @(x)isa(x,'function_handle'));                          % Rejection function (Reject if val>0) (default: keep all)
    input.addOptional('gradient',false,@islogical);             % Are gradient provided
    input.addOptional('initial_values',[],@isnumeric);          % Values of the rejection function for initial points
    input.addOptional('initial_gradients',[],@isnumeric);       % Values of the rejection function gradient for initial points
    input.parse(sites,N,PDFs_target,varargin{:});
    in=input.Results;
    
    % Prepare outputs
    assert(all(in.rejection(in.sites)<=0),'Initial sites should satisfy the ''rejection'' function')
    if ~isempty(in.initial_gradients)
        assert(~isempty(in.initial_values),'Initial values must be provided when initial gradients are provided');
    end
        
    [Nc,dim]=size(in.sites);                % Number of Markov Chain and Dimension
    N_Nc=in.N;                              % Number of samples per chain
    MCMC_samples=zeros(Nc,dim,N_Nc);        % New points
    rejection_calls=0;
    if ~any(strcmp(input.UsingDefaults,'rejection'))    % If rejection provided
        reject_values=zeros(Nc,1,N_Nc);                 % New rejection values
        reject_gradients=zeros(Nc,dim,N_Nc);            % New rejection gradients
        if isempty(in.initial_values)                   % If no initial value, compute them
            if ~in.gradient
                old_values=in.rejection(in.sites);
            else
                [old_values,old_gradients]=in.rejection(in.sites);
            end
            rejection_calls=rejection_calls+size(in.sites,1);
        else
            old_values=in.initial_values;
            if in.gradient
                old_gradients=in.initial_gradients;
            end
        end
    end
    for i=1:(in.burnin+N_Nc)
        perturbed_points=in.prop_rand(in.sites);                                    % Find proposal marginal propositions
        ratio=in.PDFs_target(perturbed_points)./in.PDFs_target(in.sites);           % Compute ratio of PDFs
        decision=rand(size(perturbed_points));                                      % Get uniform
        perturbed_points(ratio<decision)=in.sites(ratio<decision);                  % Select which component to reject
        % Check if Perturbed_Points have to be rejected (if asked for)
        if ~any(strcmp(input.UsingDefaults,'rejection'))
            to_compute=zeros(Nc,1);
            to_compute(~all(ratio<decision,2))=1;                                       % Compute only the new points
            values=zeros(Nc,1);
            values(to_compute==0)=old_values(to_compute==0);                            % Use already known values
            if ~in.gradient
                values(to_compute==1)=in.rejection(perturbed_points(to_compute==1,:));  % Compute the others
            else
                gradients=zeros(Nc,dim);
                gradients(to_compute==0,:)=old_gradients(to_compute==0,:);              % Use already known values
                [values(to_compute==1),gradients(to_compute==1,:)]=...
                    in.rejection(perturbed_points(to_compute==1,:));                    % Compute the others
            end
            rejection_calls=rejection_calls+sum(to_compute==1);
            perturbed_points(values>0,:)=in.sites(values>0,:);                          % Reject samples that have rejected values > 0
            if in.gradient
                gradients(values>0,:)=old_gradients(values>0,:);                        % Match gradients
                old_gradients=gradients;                                                % Update
            end
            values(values>0)=old_values(values>0);                                      % Match values
            old_values=values;                                                          % Update
        end
        % If burnin done, store points
        if i>in.burnin
            j=i-in.burnin;
            MCMC_samples(:,:,j)=perturbed_points;
            if ~any(strcmp(input.UsingDefaults,'rejection'))
                reject_values(:,1,j)=values;
                if in.gradient
                    reject_gradients(:,:,j)=gradients;
                end
            end
        end
        % Update
        in.sites=perturbed_points;
    end
    MCMC_samples=permute(MCMC_samples,[3 2 1]);             % Ouput X as (N_Nc x dim x Nc)
    varargout{1}=MCMC_samples;
    if nargout>1
        reject_values=permute(reject_values,[3 2 1]);       % Ouput Y as (N_Nc x 1 x Nc)
        varargout{2}=reject_values;
    end
    if nargout>2
        varargout{3}=rejection_calls;
    end
    if nargout>3
        varargout{4}=permute(reject_gradients,[3 2 1]);     % Ouput dY as (N_Nc x dim x Nc)
    end
end
