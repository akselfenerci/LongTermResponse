close all
clear
clc
rng(0)

%% A file not meant to be used as part of the help!
% Create movie for Test_method_mm.html

f=@CODES.test.inverse_2D;
x=CODES.sampling.cvt(30,2,'lb',[-5 -5],'ub',[5 5],'region',@(x)5-pdist2(x,[0 0]));
y=f(x);

logjpdf=@(x)sum(-0.5*x.^2-0.5*log(2*pi),2);     % equivalent to logjpdf=@(x)sum(log(normpdf(x)),2);
dlogjpdf=@(x)-x';
test_rng=@(N)normrnd(0,1,[N 2]);                % normal random sampler for optimization starting points

svm=CODES.fit.svm(x,y,'UseParallel',true);

[X,Y]=meshgrid(linspace(-5,5,100));
Z=reshape(f([X(:) Y(:)]),100,100);

video=VideoWriter('html/Test_method_gmm_movie.mp4','MPEG-4');
video.FrameRate=2;
open(video);

for i=1:20
    figure('Position',[200 200 500 500],'color','w')
    x_gmm=CODES.sampling.gmm(svm,logjpdf,test_rng,'dlogjpdf',dlogjpdf);
    contour(X,Y,Z,[0 0],'r')
    hold on
    svm.isoplot('lb',[-5 -5],'ub',[5 5],'prev_leg',{'True LS'})
    plot(x_gmm(:,1),x_gmm(:,2),'ms')
    axis square
    writeVideo(video,getframe(gcf));
    close(clf)
    svm=svm.add(x_gmm,f(x_gmm));
end
close(video);
