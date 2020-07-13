function varargout=lin(x,beta)
    % A linear function of random orientation, at beta from the origin
    % Dimensions: any
    % Vectorized
    if nargin<2
        beta=3;
    end
    n=size(x,2);
    u=1/sqrt(n)*ones(1,n);
    varargout{1}=-x*u'+beta;
    if nargout>1
        varargout{2}=repmat(-u,size(x,1),1);
    end
end

