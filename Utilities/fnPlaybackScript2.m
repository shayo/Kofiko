save('Playback.mat');

    
[acFileNames] = fnReadImageList(strListName);
iNumImages = length(acFileNames);
images = cell(1,iNumImages);
for k=1:length(acFileNames)
    images{k}=imread(acFileNames{k});
end
%%
aiSubset=1:377
%aiSubset=378:626
iSelectedFrame = 1;


%%
fSamplingFreq = strctPlexon.m_strctEyeX.m_fFreq;
iSelectedFrame = find(strctPlexon.m_strctEyeY.m_afTimeStamp0 < strctSession.m_fPlexonStartTS,1,'last');

%afModifiedStimulusON_TS_Plexon(377)-afModifiedStimulusON_TS_Plexon(1)

afTime = afModifiedStimulusON_TS_Plexon(aiSubset(1)):1/1000:afModifiedStimulusOFF_TS_Plexon(aiSubset(end));

    fSamplingFreq = strctPlexon.m_astrctLFP(strctPlexon.m_astrctUnits(iSelectedUnit).m_iChannel).m_fFreq;
    afPlexonTime = single(strctPlexon.m_astrctLFP(strctPlexon.m_astrctUnits(iSelectedUnit).m_iChannel).m_afTimeStamp0(iSelectedFrame):...
        1/fSamplingFreq:strctPlexon.m_astrctLFP(strctPlexon.m_astrctUnits(iSelectedUnit).m_iChannel).m_afTimeStamp0(iSelectedFrame)+...
        (strctPlexon.m_astrctLFP(strctPlexon.m_astrctUnits(iSelectedUnit).m_iChannel).m_aiNumSamplesInFragment(iSelectedFrame)-1)*1/fSamplingFreq);
    
    afAllLFP = strctPlexon.m_astrctLFP(strctPlexon.m_astrctUnits(iSelectedUnit).m_iChannel).m_afData(...
        strctPlexon.m_astrctLFP(strctPlexon.m_astrctUnits(iSelectedUnit).m_iChannel).m_aiStart(iSelectedFrame):...
        strctPlexon.m_astrctLFP(strctPlexon.m_astrctUnits(iSelectedUnit).m_iChannel).m_aiEnd(iSelectedFrame));
    
    afLFP = interp1(afPlexonTime,afAllLFP,afTime);
%%

% 1.1 Raw eye signal from Plexon:
iStartIndex = strctPlexon.m_strctEyeY.m_aiStart(iSelectedFrame);
iEndIndex = strctPlexon.m_strctEyeY.m_aiEnd(iSelectedFrame);

afEyeXraw =  interp1(afPlexonTime,strctPlexon.m_strctEyeX.m_afData(iStartIndex:iEndIndex),afTime);
afEyeYraw =  interp1(afPlexonTime,strctPlexon.m_strctEyeY.m_afData(iStartIndex:iEndIndex),afTime);

afOffsetX = fnResampleKofikoToPlex(strctKofiko.g_strctEyeCalib.CenterX, afTime, strctSession);
afOffsetY = fnResampleKofikoToPlex(strctKofiko.g_strctEyeCalib.CenterY, afTime, strctSession);
afGainX = fnResampleKofikoToPlex(strctKofiko.g_strctEyeCalib.GainX, afTime, strctSession);
afGainY = fnResampleKofikoToPlex(strctKofiko.g_strctEyeCalib.GainY, afTime, strctSession);

% The way to convert Raw Eye signal from plexon to screen coordinates is:
afEyeXpix = (afEyeXraw(:)+2048 - afOffsetX).*afGainX + strctKofiko.g_strctStimulusServer.m_aiScreenSize(3)/2;
afEyeYpix = (afEyeYraw(:)+2048 - afOffsetY).*afGainY + strctKofiko.g_strctStimulusServer.m_aiScreenSize(4)/2;
apt2fFixationSpot = fnResampleKofikoToPlex(strctKofiko.g_astrctAllParadigms{iParadigmIndex}.FixationSpotPix, afTime, strctSession);
%%
afSpikeTimes = strctPlexon.m_astrctUnits(iSelectedUnit).m_afTimestamps;
a2fSpikeWaveForms = strctPlexon.m_astrctUnits(iSelectedUnit).m_a2fWaveforms;
%%
afFakeBroadBand = afLFP;
% Mount spikes on top of LFP
aiSpikeInd=find(afSpikeTimes >=afTime(1) & afSpikeTimes <=afTime(end));
afSpikeTimesInRange = afSpikeTimes(aiSpikeInd);
nS=size(a2fSpikeWaveForms,2);
for k=1:length(aiSpikeInd)
    plugIndex = find(afTime >= afSpikeTimes(aiSpikeInd(k)),1,'first');
    afFakeBroadBand(plugIndex:plugIndex+nS-1) = afFakeBroadBand(plugIndex:plugIndex+nS-1)+ a2fSpikeWaveForms(aiSpikeInd(k),:);
end
afNormBroadband = afFakeBroadBand / 1000;

audiowrite('PlaybackNew5.wav',[afNormBroadband(:),afNormBroadband(:)],1000);

% Render scene at time X
%%
timeWidth = 2;
timeHistory = 200;
hFig=figure(12);clf;


colordef(hFig, 'black');
set(gcf,'color',[ 0 0 0]);
h1=subplot(2,3,1);
h2=subplot(2,3,2);
h3=subplot(2,3,3);
h4=subplot(2,3,4);
h5=subplot(2,3,5);
set(h1,'position',[   0.2603    0.5670    0.3629/768*1024    0.3629]);
set(h2,'position',[0.0380    0.0602    0.9375    0.1532]);
set(h3,'position',[ 0.1300    0.2586    0.6755    0.1926]);
set(h4,'position',[    0.0429    0.0202    0.4755    0.0249]);
set(h5,'position',[0.7828    0.8999    0.1832    0.0302]);
axis(h4,'off');
text(0,0,'--- LFP','Color','w','parent',h4)
text(0.3,0,'--- Spikes','Color','r','parent',h4)
text(0,0.5,'--- Eye tracking','color','c','parent',h5);
axis(h5,'off')
hImage=imagesc(zeros(100,100),'parent',h1);colormap gray
set(h1,'xlim',[0 1024],'ylim',[0 768]);
black=zeros(100,100,'uint8');
hold(h1,'on');
box(h1,'on');
set(h1,'xtick',[],'ytick',[]);
%axis(h1,'off')

plot(h2,afTime,afLFP,'w');
hold(h2,'on');
for k=1:length(aiSpikeInd)
    plot(h2,afSpikeTimes(aiSpikeInd(k))*ones(1,2), [-3000 3000],'r');
end;
set(h2,'color',[0 0 0])
axis(h2,'off')

% Find out which image was presented.
hTime=text(0.7,0,'00:000','Color','w','parent',h4);
hEyeTrace = plot(h1,[0],[0],'c');
hCurrentTime  = plot(h2,[0 0],[-4000 4000],'g');
hFixationSpot = plot(h1,[0],[0],'wo');
% 10 ms refresh...
afStimulusSize = linspace(-128,128,100);
%for timeIndex=1:10:length(afTime)
slowDown = 2;
player = audioplayer(afNormBroadband,2000 / slowDown); % play at half speed!
soundLag = 0.2;
% Compute running average firing rate response

 CatNames = {'Frontal Faces'    'Bodies'    'Fruits'    'Gadgets'    'Hands'    'Scrambles'    'Profile Faces'};
afAvgResTime = -100:250;
[a2bRaster,Tmp,a2fAvgSpikeForm] = fnRaster(strctPlexon.m_astrctUnits(iSelectedUnit), ...
    afModifiedStimulusON_TS_Plexon(aiSubset), afAvgResTime(1),afAvgResTime(end));
rasterSize = size(a2bRaster,2);
numCategories = size(a2bStimulusCategory,2); % Faces, 
numImagesPresented = length(aiSubset);
abValidTrials = strctValidTrials.m_abValidTrials(aiSubset);
% Compute the average category response
a3fAvgResponse = zeros(numCategories,rasterSize,numImagesPresented);
for k=1:numImagesPresented
    subRasterValid = a2bRaster(abValidTrials(1:k),:);
    aiStimulusValidSubset = aiStimulusIndexValid(1:sum(abValidTrials(1:k)));
    a3fAvgResponse(:,:,k)=1e3 *  fnAverageBy(subRasterValid,aiStimulusValidSubset, a2bStimulusCategory,10,true);
end
    

%
hAvg = plot(h3,afAvgResTime,a3fAvgResponse(:,:,1)');
legend(h3,CatNames,'location','EastOutside');
ylabel(h3,'Firing rate (Hz)');
xlabel(h3,'Time (ms)');
   set(h3,'ylim',[0 80]);

lastPresentedImage = -1;
play(player);

while(player.CurrentSample > 1)
   t = afTime(1) + (afTime(end)-afTime(1))*(player.CurrentSample/player.TotalSamples) - soundLag;
   timeIndex = find(afTime >= t, 1,'first');
% frame every 10 ms (i.e. 100 Hz)
% writerObj = VideoWriter('E:\Playback.avi','Uncompressed AVI');
% writerObj.FrameRate = 100;
% open(writerObj);

% for timeIndex = 1:10:length(afTime)
%     t = afTime(timeIndex);

    fx = apt2fFixationSpot(timeIndex,1);
    fy = apt2fFixationSpot(timeIndex,2);
    
    set(hFixationSpot,'xdata',fx,'ydata',fy);
    set(hCurrentTime,'xData',ones(1,2)*t);
    imageIndex = find(afModifiedStimulusON_TS_Plexon <= t,1,'last');
    lastImageOnsetTS = afModifiedStimulusON_TS_Plexon(imageIndex);
    if isempty(lastImageOnsetTS)
        lastImageOnsetTS = afModifiedStimulusON_TS_Plexon(1);
        imageIndex=1;
    end
    bBlank = t > lastImageOnsetTS+0.1;
    
    if bBlank 
        set(hImage,'cdata',black,'xdata',afStimulusSize+fx,'ydata',afStimulusSize+fy);
    else
        set(hImage,'cdata',images{aiStimulusIndex(imageIndex)},'xdata',afStimulusSize+fx,'ydata',afStimulusSize+fy);
    end
      % sample eye position and draw
    if (timeIndex > timeHistory+1)
        set(hEyeTrace,'xdata',afEyeXpix(timeIndex-timeHistory:timeIndex),'ydata',afEyeYpix(timeIndex-timeHistory:timeIndex));
    end
    
    for kk=1:length(hAvg)
        set(hAvg(kk),'ydata',squeeze(a3fAvgResponse(kk,:,imageIndex)));
    end

     set(h2,'xlim',[t-timeWidth t+timeWidth]);
    set(hTime,'String',sprintf('Time: %.2f',t-afTime(1)));
    drawnow
%     X=getframe(hFig);
%     writeVideo(writerObj,X);
end

% close(writerObj);
stop(player)

