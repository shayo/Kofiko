function a2bSignificant = fnSignificantTuning(acData, acStimuliInd)
% Feature diemsnion significance according to Winrich's original cartoon
% paper....

aiAspectRatio = 1284:1294; % -5:5
aiAssemblyHeight = 1295:1305; % -5:5
aiEyeDistance = 1306:1316; % -5:5
aiIrisSize = 1317:1325; % -4:4
acStimuliInd = {aiAspectRatio, aiAssemblyHeight,aiEyeDistance,aiIrisSize};
iNumFeatures = length(acStimuliInd);
% We need to define surrogate data sets by shifting the data.
iNumUnits = length(acData);
a2bSignificant = zeros(iNumUnits, iNumFeatures);
iNumSurrogateTests = 5000;

aiAllRelevantStimuli = cat(2,acStimuliInd{:});

% Prep the stupid cell array
for iFeatureIter=1:iNumFeatures
    iNumStimuliForThisFeature = length(acStimuliInd{iFeatureIter});
    acFeatureStimuli{iFeatureIter} = cell(1, iNumStimuliForThisFeature);
    for k=1:iNumStimuliForThisFeature
        acFeatureStimuli{iFeatureIter}{k} = acStimuliInd{iFeatureIter}(k);
    end
end
   

iBeforeMS = 0;
iAfterMS = 300;
aiPeri =iBeforeMS:iAfterMS;
for iUnitIter=1:iNumUnits
    
    % Generate surrogate set for this unit by shiting spike times...
    %
    abRelevantStimuli = ismember(acData{iUnitIter}.strctUnit.m_aiStimulusIndexValid,  aiAllRelevantStimuli);
    aiRelevantStimuli = find(abRelevantStimuli);
    
    
    
    
    aiStimuliInd = acData{iUnitIter}.strctUnit.m_aiStimulusIndexValid(aiRelevantStimuli);
    
    
    iTimeSmoothingMS = 5;
    iNumTimeBins = iAfterMS-iBeforeMS+1;
    a3fHetro = zeros(iNumFeatures, iNumTimeBins, iNumSurrogateTests) ;
    
    if 0
    for iSurrogateIter=1:iNumSurrogateTests
        afSpikeTimesShifted = acData{iUnitIter}.strctUnit.m_afSpikeTimes+ (iSurrogateIter- iNumSurrogateTests/2) * 0.3;
        [a2bRaster] = fnRasterAux(afSpikeTimesShifted, acData{iUnitIter}.strctUnit.m_afStimulusONTime(aiRelevantStimuli), iBeforeMS, iAfterMS);
        % Take the raster and build a proper PSTH per feature dimension
        for iFeatureIter=1:iNumFeatures
            a2fAvgFirintRate_Shuffled  = 1e3 * fnAverageByCell(a2bRaster, aiStimuliInd, acFeatureStimuli{iFeatureIter}, iTimeSmoothingMS, true);
             % compute heterogeneity
             a3fHetro(iFeatureIter, :, iSurrogateIter) = fnHeterogeneity(a2fAvgFirintRate_Shuffled);
        end
    end
    else
        % Use "blocks"
        [a2bRaster] = fnRasterAux(acData{iUnitIter}.strctUnit.m_afSpikeTimes, acData{iUnitIter}.strctUnit.m_afStimulusONTime(aiRelevantStimuli), iBeforeMS, iAfterMS);
         % Permute the raster...
         iNumAppear = size(a2bRaster,1);
         
         for iSurrogateIter=1:iNumSurrogateTests
             aiRandPerm = randperm(iNumAppear);
             % Take the raster and build a proper PSTH per feature dimension
             for iFeatureIter=1:iNumFeatures
                 a2fAvgFirintRate_Shuffled  = 1e3 * fnAverageByCell(a2bRaster(aiRandPerm,:), aiStimuliInd, acFeatureStimuli{iFeatureIter}, iTimeSmoothingMS, true);
                 % compute heterogeneity
                 a3fHetro(iFeatureIter, :, iSurrogateIter) = fnHeterogeneity(a2fAvgFirintRate_Shuffled);
             end
         end
            
    end
    
    % now, zero lag:
    afSpikeTimesShifted = acData{iUnitIter}.strctUnit.m_afSpikeTimes;
    [a2bRaster] = fnRasterAux(afSpikeTimesShifted, acData{iUnitIter}.strctUnit.m_afStimulusONTime(aiRelevantStimuli), iBeforeMS, iAfterMS);
    % Take the raster and build a proper PSTH per feature dimension
    a2fHetroUnit = zeros(iNumFeatures, iNumTimeBins);
    for iFeatureIter=1:iNumFeatures
        a2fAvgFirintRate  = 1e3 * fnAverageByCell(a2bRaster, aiStimuliInd, acFeatureStimuli{iFeatureIter}, iTimeSmoothingMS, true);
        % compute heterogeneity
        a2fHetroUnit(iFeatureIter, :) = fnHeterogeneity(a2fAvgFirintRate);
    end
    
    figure(11);clf
    for k=1:iNumFeatures
        subplot(2,2,k);
          a2fAvgFirintRate  = 1e3 * fnAverageByCell(a2bRaster, aiStimuliInd, acFeatureStimuli{k}, iTimeSmoothingMS, true);
        imagesc(a2fAvgFirintRate)
    end
    
   
       figure(10);
          clf;
    for iFeatureIter=1:iNumFeatures
        
          a2fHetro=squeeze(a3fHetro(iFeatureIter,:,:));
          a2fHetroSorted = sort(a2fHetro,2);
          subplot(2,2,iFeatureIter);
          plot(aiPeri,a2fHetroUnit(iFeatureIter,:),'b');
          hold on;
          plot(aiPeri,a2fHetroSorted(:,999),'r');
    end
    
end



