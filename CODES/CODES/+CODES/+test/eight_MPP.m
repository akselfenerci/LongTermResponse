function y=eight_MPP(x)
    % A complex 3D limit state with 8 MPP at equal distance from the origin
    y=x(:,1);
    A=-(x(:,3)-sign(x(:,1)).*3./x(:,1)-sign(x(:,2)).*3./x(:,2));
    B=(x(:,3)+sign(x(:,1)).*3./x(:,1)+sign(x(:,2)).*3./x(:,2));
    y(x(:,3)>0)=A(x(:,3)>0);
    y(x(:,3)<=0)=B(x(:,3)<=0);
end

