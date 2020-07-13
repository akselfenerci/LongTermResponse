function y=four_branch(x,l)
    % A 2D function with 4 limit state
    if nargin<2
        l=6;
    end
    y=min([7-0.2*(x(:,1)-x(:,2)).^2+(x(:,1)+x(:,2))/sqrt(2),...
           7-0.2*(x(:,1)-x(:,2)).^2-(x(:,1)+x(:,2))/sqrt(2),...
           10-(x(:,1)-x(:,2))-l/sqrt(2),...
           10-(x(:,2)-x(:,1))-l/sqrt(2)],[],2)+0.5;
end

