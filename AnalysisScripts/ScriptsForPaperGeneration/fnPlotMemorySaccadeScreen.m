function fnPlotMemorySaccadeScreen(iDirection)
fFixationRadius = 90;
afTheta=linspace(0,2*pi,20);
% figure(hFig);
% clf;hold on;
plot(fFixationRadius*cos(afTheta),fFixationRadius*sin(afTheta),'r');
% plot targets
a2fTargetCenter = [140 140;
    140 -140
    -140 140
    -140 -140
    200 0
    -200 0
    0 200
    0 -200];

for k=1:8
    if exist('iDirection','var') && iDirection == k
        plot(a2fTargetCenter(k,1)+80*cos(afTheta),a2fTargetCenter(k,2)+80*sin(afTheta),'g','LineWidth',2);
    else
        plot(a2fTargetCenter(k,1)+80*cos(afTheta),a2fTargetCenter(k,2)+80*sin(afTheta),'b');
    end
    text(a2fTargetCenter(k,1),a2fTargetCenter(k,2),sprintf('%d',k));
    
end
axis([-400 400 -400 400]);