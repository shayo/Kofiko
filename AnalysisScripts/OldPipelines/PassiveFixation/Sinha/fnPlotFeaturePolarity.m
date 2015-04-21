function fnPlotFeaturePolarity(a2iSigRatio,aiSinhaRatio,abASmallerB)
hold on;
ahHandles(1) = bar(a2iSigRatio(:,1),'facecolor',[79,129,189]/255);
ahHandles(2) = bar(-a2iSigRatio(:,2),'facecolor',[192,80,77]/255);
% ylabel('Number of units');
% xlabel('Pair Index');



%strctCBCL_Pred = load('D:\Code\Doris\Stimuli_Generating_Code\Sinha\CBCLInvarianceRatios.mat');
strctMonkeyPred = load('D:\Code\Doris\Stimuli_Generating_Code\Sinha\MonkeyInvarianceRatios.mat');
strctShayPred = load('D:\Code\Doris\Stimuli_Generating_Code\Sinha\ShayInvarianceRatios.mat');

fMax = max(abs(a2iSigRatio(:)));
plot([0 55],[fMax+5 fMax+5],'k--');
plot([0 55],[-fMax-5 -fMax-5],'k--');

 % Draw Predictions from monkey
 fMarkerSizeW = 0.5;
 fMarkerSizeH = 4;
%  afR = linspace(0.8,0.8,12);
%  afColors1 = [zeros(12,1),afR',afR'];
%  afColors2 = [ afR',zeros(12,1),afR' ];
%   afColors3 = [0 0 1];

 
 afColors1=1.2*[155,187,89]/255;
  afColors2=1.2*[128,100,162]/255;
  afColors3=1.2*[75,172,198]/255;
 
for k=1:12
    iPairIndex = strctMonkeyPred.aiInvarianceRatios(k);
    if strctMonkeyPred.aiSelectivityIndex(iPairIndex) > 0
        ahHandles(3) = fnPlotFilledTriangle(0,iPairIndex,fMax+10,fMarkerSizeW,fMarkerSizeH, afColors1);
    else
        ahHandles(3) = fnPlotFilledTriangle(1,iPairIndex,-fMax-10,fMarkerSizeW,fMarkerSizeH,afColors1);
    end
      set(ahHandles(3),'edgecolor','none');
    
    iPairIndex = strctShayPred.aiInvarianceRatios(k);
    if strctShayPred.aiSelectivityIndex(iPairIndex) > 0
        ahHandles(4) = fnPlotFilledTriangle(0,iPairIndex,fMax+15,fMarkerSizeW,fMarkerSizeH, afColors2);
    else
        ahHandles(4) = fnPlotFilledTriangle(1,iPairIndex,-fMax-15,fMarkerSizeW,fMarkerSizeH, afColors2);
    end
        set(ahHandles(4),'edgecolor','none');
  
    iPairIndex = aiSinhaRatio(k);
    if ~abASmallerB(k)
        ahHandles(5) = fnPlotFilledTriangle(0,iPairIndex,fMax+20,fMarkerSizeW,fMarkerSizeH, afColors3);

    else
        ahHandles(5) = fnPlotFilledTriangle(1,iPairIndex,-fMax-20,fMarkerSizeW,fMarkerSizeH, afColors3);

    end
       set(ahHandles(5),'edgecolor','none');
     
end

legend(ahHandles,{'Part A < Part B','Part A > Part B','Pred Monkey','Pred Human','Pred Sinha'},'Location','NorthEastOutside');
axis([0 56 -fMax-25 fMax+25])
% set(gca,'yticklabel',num2str(abs(str2num(get(gca,'ytickLabel')))));
box on
% set(gcf,'position',[   486   700   858   331]);
% set(gca,'position',[0.1300    0.1100    0.5839    0.8150]);

%%
% set(gcf,'position',[275   703   612   299]);
% 
% set(gca,'Position',[ 0.1300    0.1100    0.5070    0.8150]);
