function strctUnit = fnAnalyzeParameterSweep(strctUnit, strctKofiko, strctPlexon, strctSession,iSessionIter, strctConfig,iParadigmIndex)

dbg = 1;

iAvgLen = 30;
afSmoothingKernelMS = fspecial('gaussian',[1 7*iAvgLen],iAvgLen);
iStartAvg = find(strctUnit.m_aiPeriStimulusRangeMS>=strctConfig.m_strctParams.m_iStartAvgMS,1,'first');
iEndAvg = find(strctUnit.m_aiPeriStimulusRangeMS>=strctConfig.m_strctParams.m_iEndAvgMS,1,'first');


if length(unique(strctUnit.m_aiStimulusIndex)) == 2
    fprintf('%d out of %d are valid trials\n',length(strctUnit.m_aiStimulusIndexValid),length(strctUnit.m_aiStimulusIndex))
    
    aiStimuliRange = unique(strctUnit.m_aiStimulusIndexValid);
    
    afXRange  = unique(strctUnit.m_strctStimulusParams.m_afPosXRelativeToFixationSpot);
    afYRange  = unique(strctUnit.m_strctStimulusParams.m_afPosYRelativeToFixationSpot);
    afThetaRange = unique(strctUnit.m_strctStimulusParams.m_afRotationAngle);
    afSizeRange = unique(strctUnit.m_strctStimulusParams.m_afStimulusSizePix);
    
    % StimulusIndex, X, Y, Size, Rotation
    a5fMean = NaN*ones( length(aiStimuliRange), length(afXRange), length(afYRange), length(afThetaRange), length(afSizeRange));
    a5fStd = NaN*ones( length(aiStimuliRange), length(afXRange), length(afYRange), length(afThetaRange), length(afSizeRange));
    fprintf('Number of elements in 5-space: %d\n',prod(size(a5fMean)));
    for iStimIter=1:length(aiStimuliRange)
        for iXIter=1:length(afXRange)
            for iYIter=1:length(afYRange)
                for iSizeIter=1:length(afSizeRange)
                    for iThetaIter=1:length(afThetaRange)
                        % Find all valid trials with these parameters....
                        
                        aiTrialInd = find(strctUnit.m_aiStimulusIndexValid == aiStimuliRange(iStimIter) & ...
                                          strctUnit.m_strctStimulusParams.m_afPosXRelativeToFixationSpot == afXRange(iXIter) & ...
                                          strctUnit.m_strctStimulusParams.m_afPosYRelativeToFixationSpot == afYRange(iYIter) & ...
                                          strctUnit.m_strctStimulusParams.m_afRotationAngle == afThetaRange(iThetaIter) & ...
                                          strctUnit.m_strctStimulusParams.m_afStimulusSizePix == afSizeRange(iSizeIter));
                        if ~isempty(aiTrialInd)
                            a2fSmoothRaster = 1e3*conv2(double(strctUnit.m_a2bRaster_Valid(aiTrialInd,:)),afSmoothingKernelMS ,'same');
                            a5fMean(iStimIter, iXIter, iYIter, iSizeIter, iThetaIter) = mean(mean(a2fSmoothRaster(:,iStartAvg:iEndAvg),2),1);
                            a5fStd(iStimIter, iXIter, iYIter, iSizeIter, iThetaIter) = std(mean(a2fSmoothRaster(:,iStartAvg:iEndAvg),2),1);
                            
                        end
                        
                    end
                end
            end
        end
    end

    strctUnit.m_strctSweep.m_a5fMean = a5fMean;
    strctUnit.m_strctSweep.m_a5fStd = a5fStd;
    strctUnit.m_strctSweep.aiStimuliRange = aiStimuliRange;
    strctUnit.m_strctSweep.afXRange  = afXRange;
    strctUnit.m_strctSweep.afYRange  = afYRange; 
    strctUnit.m_strctSweep.afThetaRange = afThetaRange;
    strctUnit.m_strctSweep.afSizeRange = afSizeRange;
    
%     
%     
%     if length(afSizeRange) > 1
%         iSizeIndex = find(afSizeRange == 128);
%     else
%         iSizeIndex = 1;
%     end
%     
%     a2fPosMeanFace = squeeze(a5fMean(1, :, :, iSizeIndex, 1));
%     a2fPosMeanNonFace = squeeze(a5fMean(2, :, :, iSizeIndex, 1));
%     figure(11);
%     clf;
%     surf(afXRange,afYRange,a2fPosMeanFace);
%     hold on;
%     surf(afXRange,afYRange,-a2fPosMeanNonFace);
%     figure(12);
%     surf(afXRange,afYRange,a2fPosMeanFace-a2fPosMeanNonFace);
end
return;
