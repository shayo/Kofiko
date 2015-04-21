function strctMergedUnit = fnMergeFOB_And_Sinha(strctFOB, strctSinha)
% Takes an old version of FOB unit and Sinha unit and merge them to
% "SinhaFOB" Unit
strctMergedUnit.m_strRecordedTimeDate = strctFOB.m_strRecordedTimeDate;
strctMergedUnit.m_iRecordedSession = [strctFOB.m_iRecordedSession,strctSinha.m_iRecordedSession];
strctMergedUnit.m_iChannel = [strctFOB.m_iChannel,strctSinha.m_iChannel];
strctMergedUnit.m_iUnitID =[strctFOB.m_iUnitID,strctSinha.m_iUnitID];
strctMergedUnit.m_fDurationMin = strctFOB.m_fDurationMin +  strctSinha.m_fDurationMin;
strctMergedUnit.m_strParadigm = 'Passive Fixation';
strctMergedUnit.m_strImageListUsed = '\\kofiko\StimulusSet\SinhaFOB\SinhaFOB.txt';
strctMergedUnit.m_strSubject = strctFOB.m_strSubject;
strctMergedUnit.m_strParadigmDesc = 'SinhaFOB';
strctMergedUnit.m_strImageListDescrip = 'SinhaFOB';
strctMergedUnit.m_afRecordingRange = [min([strctFOB.m_afRecordingRange, strctSinha.m_afRecordingRange]),...
                                     max([strctFOB.m_afRecordingRange, strctSinha.m_afRecordingRange])];
strctMergedUnit.m_afSpikeTimes = [strctFOB.m_afSpikeTimes; strctSinha.m_afSpikeTimes];

strctMergedUnit.m_strctStatParams = strctFOB.m_strctStatParams;
strctMergedUnit.m_aiPeriStimulusRangeMS =strctFOB.m_aiPeriStimulusRangeMS;

strctMergedUnit.m_strctStimulusParams.m_afStimulusON_MS = ...
    [strctFOB.m_strctStimulusParams.m_afStimulusON_MS,strctSinha.m_strctStimulusParams.m_afStimulusON_MS];

strctMergedUnit.m_strctStimulusParams.m_afStimulusOFF_MS = ...
    [strctFOB.m_strctStimulusParams.m_afStimulusOFF_MS,strctSinha.m_strctStimulusParams.m_afStimulusOFF_MS];
strctMergedUnit.m_strctStimulusParams.m_afStimulusSizePix = ...
    [strctFOB.m_strctStimulusParams.m_afStimulusSizePix,strctSinha.m_strctStimulusParams.m_afStimulusSizePix];

strctMergedUnit.m_strctStimulusParams.m_afRotationAngle = ...
    [strctFOB.m_strctStimulusParams.m_afRotationAngle,strctSinha.m_strctStimulusParams.m_afRotationAngle];

strctMergedUnit.m_afISICenter= strctFOB.m_afISICenter;
strctMergedUnit.m_afISIDistribution = strctFOB.m_afISIDistribution + strctSinha.m_afISIDistribution;

if ~isfield(strctFOB,'m_a2bRaster')
strctMergedUnit.m_a2bRaster_Valid = [strctFOB.m_a2bPSTH_Valid;strctSinha.m_a2bPSTH_Valid];

else
strctMergedUnit.m_a2bRaster_Valid = [strctFOB.m_a2bRaster_Valid;strctSinha.m_a2bRaster_Valid];
end
strctMergedUnit.m_afStimulusONTime = [strctFOB.m_afStimulusONTime,strctSinha.m_afStimulusONTime];

strctMergedUnit.m_aiStimulusIndexValid = [strctFOB.m_aiStimulusIndexValid; 96+strctSinha.m_aiStimulusIndexValid];
strctMergedUnit.m_a2fAvgFirintRate_Stimulus = [strctFOB.m_a2fAvgFirintRate_Stimulus ;strctSinha.m_a2fAvgFirintRate_Stimulus];
strctMergedUnit.m_a2fAvgFirintRate_Category = [strctFOB.m_a2fAvgFirintRate_Category;strctSinha.m_a2fAvgFirintRate_Category];

strctMergedUnit.m_afAvgFirintRate_Stimulus = [strctFOB.m_afAvgFirintRate_Stimulus ;strctSinha.m_afAvgFirintRate_Stimulus];

strctMergedUnit.m_afAvgFiringSamplesCategory = [strctFOB.m_afAvgFiringSamplesCategory ;strctSinha.m_afAvgFiringSamplesCategory];
strctMergedUnit.m_iNumCategories = [strctFOB.m_iNumCategories+strctSinha.m_iNumCategories];
strctMergedUnit.m_afBaseline = [strctFOB.m_afBaseline;strctSinha.m_afBaseline];
strctMergedUnit.m_fAvgBaseline = (strctFOB.m_fAvgBaseline + strctSinha.m_fAvgBaseline)/2;
strctMergedUnit.m_acCatNames = [strctFOB.m_acCatNames,strctSinha.m_acCatNames];

strctMergedUnit.m_a2bStimulusCategory = zeros(size(strctFOB.m_a2bStimulusCategory,1)+size(strctSinha.m_a2bStimulusCategory,1),...
    strctMergedUnit.m_iNumCategories,'uint8')>0;
strctMergedUnit.m_a2bStimulusCategory(1:size(strctFOB.m_a2bStimulusCategory,1), 1:strctFOB.m_iNumCategories) = ...
    strctFOB.m_a2bStimulusCategory;
strctMergedUnit.m_a2bStimulusCategory(1+size(strctFOB.m_a2bStimulusCategory,1):end, strctFOB.m_iNumCategories+1:end) = ...
    strctSinha.m_a2bStimulusCategory;



iStartAvg = find(strctMergedUnit.m_aiPeriStimulusRangeMS>=strctMergedUnit.m_strctStatParams.m_fStartAvgMS,1,'first');
iEndAvg = find(strctMergedUnit.m_aiPeriStimulusRangeMS>=strctMergedUnit.m_strctStatParams.m_fEndAvgMS,1,'first');
iStartBaselineAvg = find(strctMergedUnit.m_aiPeriStimulusRangeMS>=strctMergedUnit.m_strctStatParams.m_fStartBaselineAvgMS,1,'first');
iEndBaselineAvg = find(strctMergedUnit.m_aiPeriStimulusRangeMS>=strctMergedUnit.m_strctStatParams.m_fEndBaselineAvgMS,1,'first');


[strctMergedUnit.m_a2fPValueCat] = ...
    fnStatisticalTestBy(strctMergedUnit.m_a2bRaster_Valid, strctMergedUnit.m_aiStimulusIndexValid, ...
    strctMergedUnit.m_a2bStimulusCategory,...
    iStartAvg,iEndAvg,iStartBaselineAvg,iEndBaselineAvg);

strctMergedUnit.m_a2fAvgWaveFormCat =[strctFOB.m_a2fAvgWaveFormCat;strctSinha.m_a2fAvgWaveFormCat];

strctMergedUnit.m_a2fAvgLFPCategory =[strctFOB.m_a2fAvgLFPCategory;strctSinha.m_a2fAvgLFPCategory];
strctMergedUnit.m_strDisplayFunction = 'fnDisplaySinhaAnalysis';
strctMergedUnit.m_strKofikoFileName = strctFOB.m_strKofikoFileName;
strctMergedUnit.m_strPlexonFileName = {strctFOB.m_strPlexonFileName,strctSinha.m_strPlexonFileName};
strctMergedUnit.m_acSinhaPlots = strctSinha.m_acSinhaPlots;

return;
