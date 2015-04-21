function fnAuxSaccadeArchPlot(strctTmp, a2cTrialNames, aiTrialTypeIter,iBaseFigure,fRange,bShowStick,iSkip)
figure(iBaseFigure+1);clf;

for iIter=1:length(aiTrialTypeIter)
    iTrialTypeIter = aiTrialTypeIter(iIter);
    iCorrectIndex = find(ismember(strctTmp.strctUnit.m_acUniqueOutcomes,'Correct'));
afGreen = [34,177,76]/255;
aiTrialTypeNoStim(iTrialTypeIter) = find(ismember(lower(strctTmp.strctUnit.m_acTrialNames), lower(a2cTrialNames{iTrialTypeIter,1})));
aiTrialTypeStim(iTrialTypeIter) = find(ismember(lower(strctTmp.strctUnit.m_acTrialNames), lower(a2cTrialNames{iTrialTypeIter,2})));

a2fRasterCue = double(strctTmp.strctUnit.m_a2cTrialStats{aiTrialTypeNoStim(iTrialTypeIter),iCorrectIndex}.m_strctRasterCue.m_a2bRaster);
a2fRasterStimCue = double(strctTmp.strctUnit.m_a2cTrialStats{aiTrialTypeStim(iTrialTypeIter),iCorrectIndex}.m_strctRasterCue.m_a2bRaster);
a2fRasterSac = double(strctTmp.strctUnit.m_a2cTrialStats{aiTrialTypeNoStim(iTrialTypeIter),iCorrectIndex}.m_strctRasterSaccade.m_a2bRaster);
a2fRasterStimSac = double(strctTmp.strctUnit.m_a2cTrialStats{aiTrialTypeStim(iTrialTypeIter),iCorrectIndex}.m_strctRasterSaccade.m_a2bRaster);
afKernel = fspecial('gaussian',[1 100],10);
afKernel=afKernel/sum(afKernel);

a2fRasterCueSmooth = conv2(a2fRasterCue(iSkip:end,:), afKernel, 'same');
a2fRasterStimCueSmooth = conv2(a2fRasterStimCue(iSkip:end,:), afKernel, 'same');
a2fRasterSacSmooth = conv2(a2fRasterSac(iSkip:end,:), afKernel, 'same');
a2fRasterStimSacSmooth = conv2(a2fRasterStimSac(iSkip:end,:), afKernel, 'same');

if length(aiTrialTypeIter) == 1
figure(iBaseFigure);clf;
subplot(2,2,1);imagesc(-1000:3000,1:size(a2fRasterCueSmooth,1),1e3*a2fRasterCueSmooth,1e3*[0 0.14]);set(gca,'xlim',[-100 1000]);set(gca,'xtick',[-100 0 200:200:1200]);
subplot(2,2,2);imagesc(-1000:3000,1:size(a2fRasterSacSmooth,1),1e3*a2fRasterSacSmooth,1e3*[0 0.14]);set(gca,'xlim',[-800 200]);
subplot(2,2,3);imagesc(-1000:3000,1:size(a2fRasterStimCueSmooth,1),1e3*a2fRasterStimCueSmooth,1e3*[0 0.14]);set(gca,'xlim',[-100 1000]);set(gca,'xtick',[-100 0 200:200:1200]);
subplot(2,2,4);imagesc(-1000:3000,1:size(a2fRasterStimSacSmooth,1),1e3*a2fRasterStimSacSmooth,1e3*[0 0.14]);set(gca,'xlim',[-800 200]);
end

if length(aiTrialTypeIter) > 1
    subplot(2,8,iIter);
else
        figure(iBaseFigure+1)
end
afRes = 1e3*mean(a2fRasterCueSmooth,1);
afResStim = 1e3*mean(a2fRasterStimCueSmooth,1);
hold on;
plot(-1000:3000,afRes,'k','LineWidth',2);
plot(-1000:3000,afResStim,'color',afGreen,'LineWidth',2);
axis([0 1300 0 fRange])
if length(aiTrialTypeIter) == 1
P=get(gcf,'position');P(3:4)=[270 170];set(gcf,'position',P);
end
set(gca,'xtick',[0:200:1200]);
if ~bShowStick
    set(gca,'xticklabel',[]);
end;
if length(aiTrialTypeIter) > 1
    subplot(2,8,iIter+8);
else
    figure(iBaseFigure+2);clf;
end
afResSac = 1e3*mean(a2fRasterSacSmooth,1);
afResStimSac = 1e3*mean(a2fRasterStimSacSmooth,1);
hold on;
plot(-1000:3000,afResSac,'k','LineWidth',2);
plot(-1000:3000,afResStimSac,'color',afGreen,'LineWidth',2);
axis([-800 300 0 fRange])
if length(aiTrialTypeIter) == 1
P=get(gcf,'position');P(3:4)=[270 170];set(gcf,'position',P);
end
set(gca,'xtick',[-800:200:200]);
if ~bShowStick
    set(gca,'xticklabel',[]);
end;
end