for iUnitIter=1:length(acUnits)
    fprintf('Processing %d out of %d \n',iUnitIter,length(acUnits));
    strctUnit = acUnits{iUnitIter};
    iNumStimuli = 549;
    aiPeriStimulusRangeMS = strctUnit.m_strctStatParams.m_iBeforeMS:strctUnit.m_strctStatParams.m_iAfterMS;
    iStartAvg = find(aiPeriStimulusRangeMS>=strctUnit.m_strctStatParams.m_iStartAvgMS,1,'first');
    iEndAvg = find(aiPeriStimulusRangeMS>=strctUnit.m_strctStatParams.m_iEndAvgMS,1,'first');
    iStartBaselineAvg = find(aiPeriStimulusRangeMS>=strctUnit.m_strctStatParams.m_iStartBaselineAvgMS,1,'first');
    iEndBaselineAvg = find(aiPeriStimulusRangeMS>=strctUnit.m_strctStatParams.m_iEndBaselineAvgMS,1,'first');
    
    
    afSmoothingKernelMS = fspecial('gaussian',[1 7*strctUnit.m_strctStatParams.m_iTimeSmoothingMS],strctUnit.m_strctStatParams.m_iTimeSmoothingMS);
    a2fSmoothRaster = conv2(double(strctUnit.m_a2bRaster_Valid),afSmoothingKernelMS ,'same');
    afResponse = mean(a2fSmoothRaster(:,iStartAvg:iEndAvg),2);
    strctUnit.m_afBaselineRes = mean(a2fSmoothRaster(:,iStartBaselineAvg:iEndBaselineAvg),2);
    fMeanBaseline = mean(strctUnit.m_afBaselineRes);
    
    strctUnit.m_afStimulusResponseMinusBaseline = afResponse-strctUnit.m_afBaselineRes;
    
    % Now average according to stimulus !
    strctUnit.m_afAvgStimulusResponseMinusBaseline = NaN*ones(1,iNumStimuli);
    strctUnit.m_afStdStimulusResponseMinusBaseline = NaN*ones(1,iNumStimuli);
    strctUnit.m_afStdErrStimulusResponseMinusBaseline = NaN*ones(1,iNumStimuli);
    for iStimulusIter=1:iNumStimuli
        aiIndex = find(strctUnit.m_aiStimulusIndexValid == iStimulusIter);
        if ~isempty(aiIndex)
            [strctUnit.m_afAvgStimulusResponseMinusBaseline(iStimulusIter),strctUnit.m_afStdStimulusResponseMinusBaseline(iStimulusIter),...
                strctUnit.m_afStdErrStimulusResponseMinusBaseline(iStimulusIter)] = fnMyMean(strctUnit.m_afStimulusResponseMinusBaseline(aiIndex));
        end;
    end
    strctUnit.m_afAvgFiringRateCategory = ones(1,strctUnit.m_iNumCategories)*NaN;
    for iCatIter=1:strctUnit.m_iNumCategories
        abSamplesCat = ismember(strctUnit.m_aiStimulusIndexValid, find(strctUnit.m_a2bStimulusCategory(:, iCatIter)));
        if sum(abSamplesCat) > 0
            [strctUnit.m_afAvgFiringRateCategory(iCatIter),...
                strctUnit.m_afStdFiringRateCategory(iCatIter),...
                strctUnit.m_afStdErrFiringRateCategory(iCatIter)] = fnMyMean(strctUnit.m_afStimulusResponseMinusBaseline(abSamplesCat));
        end
    end
    
    
    for iCat1=1:strctUnit.m_iNumCategories
        
        abSamplesCat1 = ismember(strctUnit.m_aiStimulusIndexValid, find(strctUnit.m_a2bStimulusCategory(:, iCat1)));
        afSamplesCat1 = strctUnit.m_afStimulusResponseMinusBaseline(abSamplesCat1);
        if sum(abSamplesCat1) > 0
            
            for iCat2=iCat1+1:strctUnit.m_iNumCategories
                abSamplesCat2 = ismember(strctUnit.m_aiStimulusIndexValid, find(strctUnit.m_a2bStimulusCategory(:, iCat2)));
                if sum(abSamplesCat2) > 0
                    afSamplesCat2 = strctUnit.m_afStimulusResponseMinusBaseline(abSamplesCat2);
                    p = ranksum(afSamplesCat1,afSamplesCat2);
                    strctUnit.m_a2fPValueCat(iCat1,iCat2) = p;
                    strctUnit.m_a2fPValueCat(iCat2,iCat1) = p;
                end
            end
        end
        if ~isempty(afSamplesCat1)
            [h,p] = ttest(afSamplesCat1);
            strctUnit.m_a2fPValueCat(iCat1,end) = p;
            strctUnit.m_a2fPValueCat(end,iCat1) = p;
        else
            strctUnit.m_a2fPValueCat(iCat1,end) = NaN;
            strctUnit.m_a2fPValueCat(end,iCat1) = NaN;
        end
    end
    
    
    acUnits{iUnitIter} = strctUnit;
    
end

%%

strPath = 'D:\Data\Doris\Electrophys\Jobs\SinhaData_MinusBaselineLatencyToPeak\';

for iUnitIter=1:length(acUnits)
    strctUnit = acUnits{iUnitIter};
    if isfield(strctUnit,'m_iRecordedSession')
        strctUnit = acUnits{iUnitIter};
        strTimeDate = datestr(datenum(strctUnit.m_strRecordedTimeDate),31);
        strTimeDate(strTimeDate == ':') = '-';
        strTimeDate(strTimeDate == ' ') = '_';
        
        strParadigm = strctUnit.m_strParadigm;
        strParadigm(strParadigm == ' ') = '_';
        strDesr = strctUnit.m_strParadigmDesc;
        strDesr(strDesr == ' ') = '_';
        strUnitName = sprintf('%s_%s_Exp_%02d_Ch_%03d_Unit_%03d_%s_%s',...
            strctUnit.m_strSubject, strTimeDate,strctUnit.m_iRecordedSession,...
            strctUnit.m_iChannel(1),strctUnit.m_iUnitID(1), strParadigm, strDesr);
        strOutputFilename = fullfile(strPath, [strUnitName,'.mat']);
        fprintf('[%d/%d] Saving %s...',iUnitIter,length(acUnits),strUnitName);
        save(strOutputFilename,  'strctUnit');
        fprintf('Done!\n');
    else
        strctStatistics = acUnits{iUnitIter};
        strTimeDate = datestr(datenum(strctStatistics.m_strRecordedTimeDate),31);
        strTimeDate(strTimeDate == ':') = '-';
        strTimeDate(strTimeDate == ' ') = '_';
        strParadigm = strctStatistics.m_strParadigm;
        strParadigm(strParadigm == ' ') = '_';
        strDesr = strctStatistics.m_strParadigmDesc;
        strDesr(strDesr == ' ') = '_';
       
                strUnitName = sprintf('%s_%s_Behavior_%s_%s',...
            strctUnit.m_strSubject, strTimeDate, strParadigm, strDesr);
        strOutputFilename = fullfile(strPath, [strUnitName,'.mat']);
       fprintf('[%d/%d] Saving %s...',iUnitIter,length(acUnits),strUnitName);
         
        save(strOutputFilename,  'strctStatistics');      
        fprintf('Done!\n');
    end
end