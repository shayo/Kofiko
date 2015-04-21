 [astrctUnits,strctChannelInfo] = ...
     fnReadDumpSpikeFile('D:\Data\Doris\Electrophys\Houdini\Targeting ML and PL 2011\New Recordings New Format\110717\110717_120309_Houdini-spikes_ch1.raw');
 
 afTimeStamps = astrctUnits(1).m_afTimestamps;
 
  strctAnalog = fnReadDumpAnalogFile('D:\Data\Doris\Electrophys\Houdini\Targeting ML and PL 2011\New Recordings New Format\110717\110717_120309_Houdini-RAW_ML.raw');
  afTime = strctAnalog.m_afStartTS:1/strctAnalog.m_fSamplingFreq:strctAnalog.m_afEndTS-1/strctAnalog.m_fSamplingFreq;
 
  iSelectedSpike = 100;
  
  figure(1);
  clf;
  
  plot(strctAnalog.m_afData(1:10:end));
  
 fThreshold=4*mad(strctAnalog.m_afData)l
  
 fSamplingRateHz = strctAnalog.m_fSamplingFreq
 
fWaveFormBeforemSec = 0.5 ;
fWaveFormAftermSec = 1;
fMaxSpikeWidthSamples = 10;
iMaxSpikes = 50000;
    
    fWaveFormBeforeMicroSec = fWaveFormBeforemSec * 1e3;
    fWaveFormAfterMicroSec = fWaveFormAftermSec * 1e3;
    fWaveFormLengthMicroSec = (fWaveFormBeforeMicroSec+fWaveFormAfterMicroSec);
    fWaveFormLengthSamples = ceil(fSamplingRateHz * fWaveFormLengthMicroSec /  1e6);
    
    iNumSamplesBefore = ceil(fWaveFormBeforeMicroSec/1e6 * fSamplingRateHz);
    iNumSamplesAfter = ceil(fWaveFormAfterMicroSec/1e6 * fSamplingRateHz);
    
    afSpikeTime = ((-iNumSamplesBefore:(iNumSamplesAfter-1))*fSamplingRateHz)/1e6;
    fprintf('Detecting spikes for repetition %d out of %d\n',iRepIter,iNumRep);
    a2fWaveForms = zeros(iMaxSpikes,fWaveFormLengthSamples,'single');
    aiEvents = zeros(1,iMaxSpikes);
    
    iDataPointIter=fWaveFormLengthSamples;
    iCounter = 1;
    
        while (1)
            if mod(iDataPointIter,10000) == 0
                fprintf('%.2f ',iDataPointIter/iNumDataPts * 1e2);
                drawnow
            end;
            if iDataPointIter > iNumDataPts-fWaveFormLengthSamples
                break;
            end
            
            if afStream(iDataPointIter) < fThreshold
                % Align to minimum for better spike sorting ?
                [fDummy,iOffset] = min(afStream(iDataPointIter:iDataPointIter+fMaxSpikeWidthSamples-1));
                iOffset = iOffset - 1;
                
                aiEvents(iCounter) = iDataPointIter+iOffset;
                a2fWaveForms(iCounter,:) = afStream(iOffset+iDataPointIter-iNumSamplesBefore:iOffset+iDataPointIter+iNumSamplesAfter-1);
                iCounter = iCounter + 1;
                
                iDataPointIter = iDataPointIter + iNumSamplesAfter+iOffset;
            else
                iDataPointIter = iDataPointIter + 1;
            end
        end
        
        fprintf('Done!\n%d Spikes detected.\n',iCounter-1);
        a2fWaveForms = a2fWaveForms(1:iCounter-1,:);
        % Translate events to time stamps
        afTimeStamps = (aiEvents(1:iCounter-1)-1) /fSamplingRateHz;
        
        a2fWaveFormsAll = [a2fWaveFormsAll;a2fWaveForms];
        afTimeStampsAll = [afTimeStampsAll,afTimeStamps+fTimeOffset];
        
        % Resample LFP to 2kHz
        afLFPstream = a3fData(:,aiCorrespondingLFPChannel(iChannelIter),iRepIter);
        
        
        iSubSampling = fSamplingRateHz / fOutputLFPSamplingRateHz;
        afLFP = [afLFP;fTimeOffset+afLFPstream(1:iSubSampling:end)];
    end
    astrctUnits(iChannelIter).m_afSpikeTime = afSpikeTime;
    astrctUnits(iChannelIter).m_afTimestamps = afTimeStampsAll;
    astrctUnits(iChannelIter).m_a2fWaveforms = a2fWaveFormsAll;
    astrctUnits(iChannelIter).m_afLFP = afLFP;
    astrctUnits(iChannelIter).m_fLFPSamplingRateHz = fOutputLFPSamplingRateHz;
    astrctUnits(iChannelIter).m_strChannel = strctInfo.recChNames{iSpikeChannel};
    
    figure;
    clf;
    subplot(1,2,1);
    hold on;
    plot(afSpikeTime,a2fWaveForms','k');
    plot(afSpikeTime,mean(a2fWaveForms,1),'r');
    xlabel('Time (ms)');
    ylabel('Amplitude');
    title(strctInfo.recChNames{iSpikeChannel});
    subplot(1,2,2);
    a2fSortedAllWaveFormsZeroMean = bsxfun(@minus,a2fWaveForms,mean(a2fWaveForms,1));
    [coeff,ignore] = eig(a2fSortedAllWaveFormsZeroMean'*a2fSortedAllWaveFormsZeroMean);
    a2fPCACoeff = fliplr(coeff);
    a2fPCA = a2fSortedAllWaveFormsZeroMean*a2fPCACoeff(:,1:2);
    plot(a2fPCA(:,1),a2fPCA(:,2),'k.');
    axis equal
    
end
