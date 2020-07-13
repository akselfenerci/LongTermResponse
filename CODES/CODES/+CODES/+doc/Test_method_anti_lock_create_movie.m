close all
clear
clc
rng(0)

%% A file not meant to be used as part of the help!
% Create movie for Test_method_al.html

f=@(x)x(:,2)-sin(10*x(:,1))/4-0.5;
x=CODES.sampling.cvt(30,2);
y=f(x);

svm=CODES.fit.svm(x,y,'UseParallel',true);

[X,Y]=meshgrid(linspace(0,1,100));
Z=reshape(f([X(:) Y(:)]),100,100);

video=VideoWriter('html/Test_method_anti_lock_movie.mp4','MPEG-4');
video.FrameRate=2;
open(video);

for i=1:20
    figure('Position',[200 200 500 500],'color','w')
    [x_al,adds]=CODES.sampling.anti_lock(svm,[0 0],[1 1]);
    contour(X,Y,Z,[0 0],'r')
    hold on
    svm.isoplot('lb',[0 0],'ub',[1 1],'prev_leg',{'True LS'})
    plot(adds{1}(1),adds{1}(2),'go')        % Plot center x_c
    plot(adds{2}(:,1),adds{2}(:,2),'c--')   % Plot region boundary ||x-x_c||-R<=0
    plot(x_al(:,1),x_al(:,2),'ms')
    axis square
    writeVideo(video,getframe(gcf));
    close(clf)
    svm=svm.add(x_al,f(x_al));
end
close(video);