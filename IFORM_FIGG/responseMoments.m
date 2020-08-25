function [m0, m2] = responseMomentsBenchmark(Hs,Tz,wn)

dw = 0.01;
w = dw:dw:4;

Sr = spectrumISSC(w,Hs,1.086*Tz)./((1-(w/wn).^2).^2+(2*0.05*w/wn).^2);
Sr(end) = Sr(end)/2; %For the trapezoidal rule

m0 = dw*sum(Sr);
m2 = dw*sum((w.^2).*Sr);

end