function acUnits = fnDropFaceBias(acUnits)
strctTmp = load('SinhaV2.mat');
a2iPerm = strctTmp.a2iAllPerm;
iStimOffset = 96;
iCatOffset = 6;
acPartNames = {'Forehead','L Eye','Nose','R Eye','L Cheek','Up Lip','R Cheek','LL Cheek','Mouth','LR Cheek','Chin'};
 
a2iCorrectPairALargerB = [...
    1, 2;
    1, 4;
    5, 2;
    7, 4;
    3, 2;
    3, 4;
    3, 6;
    5, 9;
    7, 9;
    8, 9;
    10, 9;
    11, 9];


for iUnitIter=96:length(acUnits)
    fprintf('%d out of %d\n',iUnitIter,length(acUnits));
    strctUnit = acUnits{iUnitIter};
    if ~isfield(strctUnit.m_strctStatParams,'m_fStartAvgMS')
        strctUnit.m_strctStatParams.m_fStartAvgMS = strctUnit.m_strctStatParams.m_iStartAvgMS;
        strctUnit.m_strctStatParams.m_fEndAvgMS = strctUnit.m_strctStatParams.m_iEndAvgMS;
        
        strctUnit.m_strctStatParams.m_fStartBaselineAvgMS = strctUnit.m_strctStatParams.m_iStartBaselineAvgMS;
        strctUnit.m_strctStatParams.m_fEndBaselineAvgMS = strctUnit.m_strctStatParams.m_iEndBaselineAvgMS;
        
        strctUnit.m_strctStatParams.m_fBeforeMS = strctUnit.m_strctStatParams.m_iBeforeMS;
        strctUnit.m_strctStatParams.m_fAfterMS = strctUnit.m_strctStatParams.m_iAfterMS;
        strctUnit.m_strctStatParams.m_fTimeSmoothingMS = strctUnit.m_strctStatParams.m_iTimeSmoothingMS;
    end
    
    iStartAvg = find(strctUnit.m_aiPeriStimulusRangeMS>=strctUnit.m_strctStatParams.m_fStartAvgMS,1,'first');
    iEndAvg = find(strctUnit.m_aiPeriStimulusRangeMS>=strctUnit.m_strctStatParams.m_fEndAvgMS,1,'first');
    iStartBaselineAvg = find(strctUnit.m_aiPeriStimulusRangeMS>=strctUnit.m_strctStatParams.m_fStartBaselineAvgMS,1,'first');
    iEndBaselineAvg = find(strctUnit.m_aiPeriStimulusRangeMS>=strctUnit.m_strctStatParams.m_fEndBaselineAvgMS,1,'first');

    % Drop any image that comes right after a real face.
    aiFaceImagesInd = find(strctUnit.m_aiStimulusIndexValid <= 16);

    iNumEntries = size(strctUnit.m_aiStimulusIndexValid,1);
    abNewValidStim = ones(1,iNumEntries)>0;
    abNewValidStim( min(iNumEntries, aiFaceImagesInd+1)) = 0;
    
    strctUnit.m_afStimulusONTime = strctUnit.m_afStimulusONTime(abNewValidStim);

    
    a2bRaster = fnRaster2(strctUnit.m_afSpikeTimes, strctUnit.m_afStimulusONTime,...
        strctUnit.m_strctStatParams.m_fBeforeMS,strctUnit.m_strctStatParams.m_fAfterMS);

    strctUnit.m_a2bRaster_Valid = a2bRaster;
    strctUnit.m_aiStimulusIndexValid = strctUnit.m_aiStimulusIndexValid(abNewValidStim);
    iNumStimuli = size(strctUnit.m_a2bStimulusCategory,1);
    
    strctUnit.m_a2fAvgFirintRate_Stimulus  = 1e3 * fnAverageBy(strctUnit.m_a2bRaster_Valid, ...
        strctUnit.m_aiStimulusIndexValid, diag(1:iNumStimuli)>0,strctUnit.m_strctStatParams.m_fTimeSmoothingMS,...
        1);
    strctUnit.m_a2fAvgFirintRate_Category = 1e3 *  fnAverageBy(strctUnit.m_a2bRaster_Valid, ...
        strctUnit.m_aiStimulusIndexValid, strctUnit.m_a2bStimulusCategory,strctUnit.m_strctStatParams.m_fTimeSmoothingMS,...
        1);

    
    strctUnit.m_afAvgFirintRate_Stimulus = mean(strctUnit.m_a2fAvgFirintRate_Stimulus(:, iStartAvg:iEndAvg),2);
    
    a2fAvgFirintRate_Category_NoSmooth = 1e3 * fnAverageBy(strctUnit.m_a2bRaster_Valid, strctUnit.m_aiStimulusIndexValid, strctUnit.m_a2bStimulusCategory,0);
    strctUnit.m_afAvgFiringSamplesCategory = mean(a2fAvgFirintRate_Category_NoSmooth(:,iStartAvg:iEndAvg),2);
    
   [strctUnit.m_a2fPValueCat] = ...
        fnStatisticalTestBy(strctUnit.m_a2bRaster_Valid, strctUnit.m_aiStimulusIndexValid, strctUnit.m_a2bStimulusCategory,...
        iStartAvg,iEndAvg,iStartBaselineAvg,iEndBaselineAvg);


    strctUnit = fnSinhaAnalysis(strctUnit, iStimOffset,iCatOffset,a2iPerm,acPartNames,a2iCorrectPairALargerB);

    acUnits{iUnitIter} = strctUnit;
end
