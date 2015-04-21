% Current source density analysis
strUnitFile = 'E:\Data\Doris\Electrophys\Houdini\ML_AL_Project\130718\Processed\SingleUnitDataEntries\Houdini_2013-07-18_12-00-13_Exp_NaN_Ch_010_Unit_028_Passive_Fixation_New_FOB.mat'
load(strUnitFile)

% Read out stimuli and presentation time...
% prepare sample times.
iNumCh = 12;
afTime = [-100:400] / 1e3;
N = length(strctUnit.m_afStimulusONTime);
a2fSampleTimes = zeros(N, length(afTime));
for k=1:N
    a2fSampleTimes(k,:) = strctUnit.m_afStimulusONTime(k) + afTime;
end

a3fLFP = zeros(N, length(afTime), iNumCh);
for k=1:iNumCh
    fprintf('Loading LFP from Channel %d\n',k);
    strctTmp = fnReadDumpAnalogFile(sprintf('E:\\Data\\Doris\\Electrophys\\Houdini\\ML_AL_Project\\130718\\RAW\\130718_115530_Houdini-LFP%02d.raw',k),'Resample',a2fSampleTimes(:));
    a2fLFP = reshape(strctTmp.m_afData,size(a2fSampleTimes));
    a3fLFP(:,:,k) = a2fLFP;
end

% Create Only two conditiosn: faces / non-faces
aiFaceInd = find(ismember(strctUnit.m_aiStimulusIndexValid,1:16));
aiNonFaceInd = find(~ismember(strctUnit.m_aiStimulusIndexValid,1:16));

a2fLFP_Faces = 1e3*flipud(squeeze(mean(a3fLFP(aiFaceInd,:,:),1))');
a2fLFP_NonFaces = 1e3*flipud(squeeze(mean(a3fLFP(aiNonFaceInd,:,:),1))');

figure(11);clf;
set(gcf,'color',[1 1 1]);
subplot(1,2,1);
imagesc(1e3*afTime,1:size(a2fLFP_Faces,1),a2fLFP_Faces,[-200 200])
set(gca,'ytick',1:12);
%title('Response to face stimuli');
%colorbar('location','northoutside');
set(gca,'xtick',[-100:100:400])
subplot(1,2,2);
imagesc(1e3*afTime,1:size(a2fLFP_NonFaces,1),a2fLFP_NonFaces,[-200 200])
set(gca,'ytick',1:12);
%title('Response to non-face stimuli');
set(gca,'xtick',[-100:100:400])
colorbar('location','eastoutside');

figure(13);clf;
set(gcf,'color',[1 1 1]);
set(gca,'ytick',1:12);
imagesc(1e3*afTime,1:size(a2fLFP_NonFaces,1),a2fLFP_Faces-a2fLFP_NonFaces)
set(gca,'ytick',1:12);
set(gca,'xtick',[-100:100:400])
colorbar

a2fContrast = a2fLFP_Faces-a2fLFP_NonFaces;
a2fCSD = (a2fContrast(1:end-2,:)-2*a2fContrast(2:end-1,:)+a2fContrast(3:end,:));

figure(14);clf;
set(gcf,'color',[1 1 1]);
imagesc(1e3*afTime,1:size(a2fCSD,1),a2fCSD)

set(gca,'ytick',1:12);
set(gca,'xtick',[-100:100:400])
colorbar

clear astrctUnits
aiSelectedUnitID = [15,88,98,107,116,128,137,150,158,28,38,45];
figure(13);clf;set(gcf,'color',[1 1 1]);
for ch=1:12
    fprintf('Loading spike channel %d\n',ch);
    strSpikeFile=sprintf('E:\\Data\\Doris\\Electrophys\\Houdini\\ML_AL_Project\\130718\\Processed\\SortedUnits\\130718_115530_Houdini-spikes_ch%d_sorted.raw',ch);

    strFOBfile = sprintf('E:\\Data\\Doris\\Electrophys\\Houdini\\ML_AL_Project\\130718\\RAW\\..\\Processed\\SingleUnitDataEntries\\Houdini_2013-07-18_12-00-13_Exp_NaN_Ch_%03d_Unit_%03d_Passive_Fixation_New_FOB.mat',ch,aiSelectedUnitID(ch));
    acUnit{ch}=load(strFOBfile);
    astrctUnits{ch} = fnReadDumpSpikeFile(strSpikeFile);
    iSelected=find(cat(1,astrctUnits{ch}.m_iUnitIndex) == aiSelectedUnitID(ch));
    astrctSelectedUnits(ch) = astrctUnits{ch}(iSelected);
    subplot(2,6,ch);
    imagesc(acUnit{ch}.strctUnit.m_aiPeriStimulusRangeMS,1:96, acUnit{ch}.strctUnit.m_a2fAvgFirintRate_Stimulus);
    set(gca,'xlim',[-100 400],'xtick',[-100 0 100 200 300]);
    if (ch ~= 1)
    
    end
    set(gca,'xticklabel',[]);
    set(gca,'yticklabel',[]);    
    hold on;
    plot([-100 400],[16.5 16.5],'w');
    plot([0 150],[1 1],'r','LineWidth',4);
end

aiValidFaceStimuli=find(strctUnit.m_aiStimulusIndexValid <= 16);

iSelectedStimuli = 211;
t0=strctUnit.m_afStimulusONTime(aiValidFaceStimuli(iSelectedStimuli));
figure(15);
clf;
hold on;
for k=1:12
    aiLocalInd = find(astrctSelectedUnits(k).m_afTimestamps >= t0 & astrctSelectedUnits(k).m_afTimestamps <= t0+0.4);
    if ~isempty(aiLocalInd)
        plot(astrctSelectedUnits(k).m_afTimestamps(aiLocalInd)-t0,k,'k.');
    end
end
set(gca,'ylim',[1 12])
set(gca,'xlim',[-0.1 0.5]);

for j=1: length(aiValidFaceStimuli)
    t0=strctUnit.m_afStimulusONTime(aiValidFaceStimuli(j));
    for k=1:12
        a2fTmp(j,k)=sum(astrctSelectedUnits(k).m_afTimestamps >= t0 & astrctSelectedUnits(k).m_afTimestamps <= t0+0.4);
    end
end

clear a2fTmp
for ch=1:12
    afFaceRes = mean(acUnit{ch}.strctUnit.m_a2fAvgFirintRate_Stimulus(1:16,:),1);
    afNonFaceRes = mean(acUnit{ch}.strctUnit.m_a2fAvgFirintRate_Stimulus(17:end,:),1);
    a2fFaceRes(ch,:)=afFaceRes;
    a2fNonFaceRes(ch,:)=afNonFaceRes;
end
figure(12);
clf;
set(gcf,'color',[1 1 1]);
for ch=1:12
    subplot(2,6,ch);
plot(acUnit{1}.strctUnit.m_aiPeriStimulusRangeMS, a2fFaceRes(ch,:),'b','LineWidth',2);
hold on;
plot(acUnit{1}.strctUnit.m_aiPeriStimulusRangeMS, a2fNonFaceRes(ch,:),'k','LineWidth',2)
set(gca,'xlim',[-100 400]);
end

imagesc(a2fNonFaceRes)
figure;
imagesc(acUnit{ch}.strctUnit.m_aiPeriStimulusRangeMS,1:12, a2fFaceRes,[0 10])

% E:\Data\Doris\Electrophys\Houdini\ML_AL_Project\130718\RAW\..\Processed\SingleUnitDataEntries\Houdini_2013-07-18_12-00-13_Exp_NaN_Ch_001_Unit_015_Passive_Fixation_New_FOB.mat
% E:\Data\Doris\Electrophys\Houdini\ML_AL_Project\130718\RAW\..\Processed\SingleUnitDataEntries\Houdini_2013-07-18_12-00-13_Exp_NaN_Ch_002_Unit_088_Passive_Fixation_New_FOB.mat
% E:\Data\Doris\Electrophys\Houdini\ML_AL_Project\130718\RAW\..\Processed\SingleUnitDataEntries\Houdini_2013-07-18_12-00-13_Exp_NaN_Ch_003_Unit_101_Passive_Fixation_New_FOB.mat
% E:\Data\Doris\Electrophys\Houdini\ML_AL_Project\130718\RAW\..\Processed\SingleUnitDataEntries\Houdini_2013-07-18_12-00-13_Exp_NaN_Ch_004_Unit_107_Passive_Fixation_New_FOB.mat
% E:\Data\Doris\Electrophys\Houdini\ML_AL_Project\130718\RAW\..\Processed\SingleUnitDataEntries\Houdini_2013-07-18_12-00-13_Exp_NaN_Ch_005_Unit_116_Passive_Fixation_New_FOB.mat
% E:\Data\Doris\Electrophys\Houdini\ML_AL_Project\130718\RAW\..\Processed\SingleUnitDataEntries\Houdini_2013-07-18_12-00-13_Exp_NaN_Ch_006_Unit_128_Passive_Fixation_New_FOB.mat
% E:\Data\Doris\Electrophys\Houdini\ML_AL_Project\130718\RAW\..\Processed\SingleUnitDataEntries\Houdini_2013-07-18_12-00-13_Exp_NaN_Ch_007_Unit_137_Passive_Fixation_New_FOB.mat
% E:\Data\Doris\Electrophys\Houdini\ML_AL_Project\130718\RAW\..\Processed\SingleUnitDataEntries\Houdini_2013-07-18_12-00-13_Exp_NaN_Ch_008_Unit_150_Passive_Fixation_New_FOB.mat
% E:\Data\Doris\Electrophys\Houdini\ML_AL_Project\130718\RAW\..\Processed\SingleUnitDataEntries\Houdini_2013-07-18_12-00-13_Exp_NaN_Ch_009_Unit_158_Passive_Fixation_New_FOB.mat
% E:\Data\Doris\Electrophys\Houdini\ML_AL_Project\130718\RAW\..\Processed\SingleUnitDataEntries\Houdini_2013-07-18_12-00-13_Exp_NaN_Ch_010_Unit_028_Passive_Fixation_New_FOB.mat
% E:\Data\Doris\Electrophys\Houdini\ML_AL_Project\130718\RAW\..\Processed\SingleUnitDataEntries\Houdini_2013-07-18_12-00-13_Exp_NaN_Ch_011_Unit_038_Passive_Fixation_New_FOB.mat
% E:\Data\Doris\Electrophys\Houdini\ML_AL_Project\130718\RAW\..\Processed\SingleUnitDataEntries\Houdini_2013-07-18_12-00-13_Exp_NaN_Ch_012_Unit_045_Passive_Fixation_New_FOB.mat
% 