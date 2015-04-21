function [strctUnit, bOverride] = fnPlotExperiment(strctUnit)
%%
% Plexon time
bOverride = true;

if ~strcmp(strctUnit.m_strParadigm,'Passive Fixation')
    return;
end;
iSelectedStimulus = 12;

hFig = figure;
clf;
hold on;
title(sprintf('%s Exp %d, Ch %d, Unit %d',...
    strctUnit.m_strRecordedTimeDate,strctUnit.m_iRecordedSession,...
    strctUnit.m_iChannel,strctUnit.m_iUnitID));

fnDisplayAux(strctUnit, iSelectedStimulus);
aiStimuli = unique(strctUnit.m_aiStimulusIndex);
strOpt = '';
for k=1:length(aiStimuli)
    strOpt = [strOpt,'|',num2str(k)];
end
    
hMenu=uicontrol('style','popupmenu','string',strOpt(2:end),'callback',{@fnDisplayAux2,strctUnit});
return;

function fnDisplayAux2(hObject,b,strctUnit)
iSelectedStimulus = get(hObject,'value');
fnDisplayAux(strctUnit, iSelectedStimulus);
return;


function fnDisplayAux(strctUnit, iSelectedStimulus)
cla;
aiSelectedStim = find(strctUnit.m_aiStimulusIndex==iSelectedStimulus);
fTimeIntervalSec = 1.5;
for iRepIter=1:length(aiSelectedStim)
    fStartTimeSelectedStim = strctUnit.m_afStimulusONTimeAll(aiSelectedStim(iRepIter));
    fOffset = iRepIter-1;
    
    fStartTimeSec = fStartTimeSelectedStim-fTimeIntervalSec;
    fEndTimeSec = fStartTimeSelectedStim+fTimeIntervalSec;
    
    aiSpikeInd = find(strctUnit.m_afSpikeTimes >=fStartTimeSec & strctUnit.m_afSpikeTimes <= fEndTimeSec);
    aiStimulusInd = find(strctUnit.m_afStimulusONTimeAll >= fStartTimeSec & strctUnit.m_afStimulusONTimeAll <= fEndTimeSec);
    
    afTime = fStartTimeSec:1e-3:fEndTimeSec;
    afSpikesRelative = zeros(size(afTime));
    aiSpikesRelative = 1+round( (strctUnit.m_afSpikeTimes(aiSpikeInd)-fStartTimeSec)*1e3);
    afSpikesRelative(aiSpikesRelative) = 1;
    afSmoothingKernelMS = fspecial('gaussian',[1 200],40);
    afSmoothSpikes = conv(afSpikesRelative, afSmoothingKernelMS,'same');
    
    for k=1:length(aiSpikeInd)
        plot(ones(1,2)*strctUnit.m_afSpikeTimes(aiSpikeInd(k)) - fStartTimeSelectedStim,fOffset+[0.35 0.8],'b');
    end
    
    plot(afTime-fStartTimeSelectedStim,fOffset+0.3+10*afSmoothSpikes,'g','Linewidth',2);
    plot([0 0],fOffset+[0 1],'r');
    
    
    abValid = strctUnit.m_strctValidTrials.m_abValidTrials(aiStimulusInd);
    
    for k=1:length(aiStimulusInd)
        iStimulusPresented = strctUnit.m_aiStimulusIndex(aiStimulusInd(k));
        fOnset_sec = strctUnit.m_afStimulusONTimeAll(aiStimulusInd(k));
        fDurationON_ms = strctUnit.m_strctStimulusParams.m_afStimulusON_ALL_MS(aiStimulusInd(k));
        fDurationOFF_ms = strctUnit.m_strctStimulusParams.m_afStimulusOFF_ALL_MS(aiStimulusInd(k));
        
        rectangle('Position',[fOnset_sec-fStartTimeSelectedStim fOffset fDurationON_ms/1e3 0.3],'facecolor',[0.6 0.6 0.6]);
        rectangle('Position',[fOnset_sec+fDurationON_ms/1e3-fStartTimeSelectedStim fOffset fDurationOFF_ms/1e3 0.3],'facecolor',[0.3 0.3 0.3]);
        
        strCat = strctUnit.m_acCatNames{find(strctUnit.m_a2bStimulusCategory(iStimulusPresented,:),1,'first')};
        
        text(fOnset_sec+0.01-fStartTimeSelectedStim,fOffset+0.15, sprintf('%s(%d)',strCat,iStimulusPresented),'fontsize',8);
        if ~abValid(k)
            rectangle('Position',[fOnset_sec-fStartTimeSelectedStim fOffset (fDurationOFF_ms+fDurationON_ms)/1e3 0.05],'facecolor','r');
        end
    end
    
    
end

