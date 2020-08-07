function S = spectrumISSC(w,H,T)
%spectrumISSC evaluates the ISSC spectrum at the frequencies w. This
%formulation uses the mean wave period T1 defined in terms of the moments
%by T1=2pi*m0/m1. For PM-specta T2=2pi*sqrt(m0/m2) is often used, these are
%related by T1=1.086T2. The peak period is given by T0=1.408T2(Faltinsen).
%
%Input:  S: The values of the spectrum at the frequencies in w.
%Output: w: The frequencies where the spectrum is evaluated.
%        H: The significant wave height (mean of the 1/3 highest waves).
%        T: The average wave period.

S = H^2*T*0.1107/(2*pi)*(w*T/(2*pi)).^(-5).*exp(-0.4427*(w*T/(2*pi)).^(-4));