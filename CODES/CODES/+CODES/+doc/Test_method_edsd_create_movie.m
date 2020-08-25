close all
clear
clc
rng(0)

%% A file not meant to be used as part of the help!
% Create movie for Test_method_al.html

f=@(x)x(:,2)-sin(10*x(:,1))/4-0.5;
x=CODES.sampling.cvt(10,2);
y=f(x);

svm=CODES.fit.svm(x,y,'UseParallel',true);
svm_col=CODES.sampling.edsd(f,svm,[0 0],[1 1],'iter_max',20);

[X,Y]=meshgrid(linspace(0,1,100));
Z=reshape(f([X(:) Y(:)]),100,100);

video=VideoWriter('html/Test_method_edsd_movie.mp4','MPEG-4');
video.FrameRate=2;
open(video);

for i=1:20
    figure('Position',[200 200 500 500],'color','w')
    contour(X,Y,Z,[0 0],'r')
    hold on
    svm_col{i}.isoplot('lb',[0 0],'ub',[1 1],'prev_leg',{'True LS'})
    if i<20
        plot(svm_col{i+1}.X(end,1),svm_col{i+1}.X(end,2),'ms')
    end
    axis square
    writeVideo(video,getframe(gcf));
    close(clf)
end
close(video);
