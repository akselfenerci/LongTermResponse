function f=parabola(x)
    p=-1/(4*2)*x(:,3).^2+3.22;
    k=-10/(4*100)*x(:,3).^2+3.5;
    f=x(:,1).^2-4*p.*(x(:,2)-k);
end