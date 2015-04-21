function [a2iCodes,strctCodeIndex, acSubjects,acLists, a2iListToIndex, strctQuality] = fnGetUniqueExperimentCode(acEntries)
% returns a 5xN matrix.
% First column is subject index
% second column is experiment date
% third column is experiment recorded index
% forth column is recorded channel
% fifth column is recorded sorted unit
% sixth column is image descritption index (if passive fixation)
%
% a2iListToIndex is a matrix of size U x V, where
% V is the number of UNIQUE units recorded, and U is the number of unique
% passive fixation lists available.
%
strctCodeIndex.m_iSubject = 1;
strctCodeIndex.m_iExperimentDate = 2;
strctCodeIndex.m_iRecordedExp = 3;
strctCodeIndex.m_iChannel     = 4;
strctCodeIndex.m_iUnit        = 5;
strctCodeIndex.m_iImageList   = 6;

acSubjects = unique(fnExtractAllValues(acEntries,'m_strSubject'));
acLists = unique(fnExtractAllValues(acEntries,'m_strImageListDescrip'));
iNumEntries = length(acEntries);
a2iCodes  = zeros(iNumEntries, 6);
for iIter=1:iNumEntries
    a2iCodes(iIter,1) = find(ismember(acSubjects,acEntries{iIter}.m_strSubject));
    a2iCodes(iIter,2) = datenum(acEntries{iIter}.m_strRecordedTimeDate);
    if isfield(acEntries{iIter},'m_iRecordedSession')
        a2iCodes(iIter,3) = acEntries{iIter}.m_iRecordedSession;
    else
        a2iCodes(iIter,3) = -1;
    end
    if isfield(acEntries{iIter},'m_iChannel')
        a2iCodes(iIter,4) = acEntries{iIter}.m_iChannel;
    else
        a2iCodes(iIter,4) = -1;
    end
    if isfield(acEntries{iIter},'m_iUnitID')
        a2iCodes(iIter,5) = acEntries{iIter}.m_iUnitID;
    else
        a2iCodes(iIter,5) = -1;
    end
    if isfield(acEntries{iIter},'m_strImageListDescrip')
        a2iCodes(iIter,6) = find(ismember(acLists,acEntries{iIter}.m_strImageListDescrip));
    else
        a2iCodes(iIter,6) = -1;
    end
end

% How many unique units do we have ?
% We need to combine columns 1:5. 
a2iUnique = zeros(0,5);
iNumUniqueLists = length(acLists);
a2iListToIndex = zeros(iNumUniqueLists,0);
for iIter=1:iNumEntries
    % Search current entry in unique codes.
    iNumUnique = size( a2iUnique,1);
    % If not in unique array, add it (new unit)
    iIndex = find(sum(a2iUnique == repmat(a2iCodes(iIter,1:5),iNumUnique,1),2) == 5);
    if isempty(iIndex)
        a2iUnique(iNumUnique+1,:) = a2iCodes(iIter,1:5);
        iIndex = iNumUnique+1;
    end
    
    % At this point, iIndex corresponds to the unique unit index
    if isfield(acEntries{iIter},'m_strImageListDescrip')
        iListIndex = find(ismember(acLists,acEntries{iIter}.m_strImageListDescrip));
        a2iListToIndex(iListIndex,iIndex) = iIter;
    end
end


% Estimate units quality
strctQuality.m_aiNumSpikes = NaN*ones(1,iNumEntries);
strctQuality.m_afISIPerc = NaN*ones(1,iNumEntries);
strctQuality.m_afQuality = NaN*ones(1,iNumEntries);
fISIThresholdMS = 1;
for k=1:iNumEntries
    if ~isfield(acEntries{k},'m_afISIDistribution') || ~isfield(acEntries{k},'m_afSpikeTimes')  || ~isfield(acEntries{k},'m_afAvgWaveForm') 
        continue;
    end
    iIndex = find(acEntries{k}.m_afISICenter <= fISIThresholdMS,1,'last');
    strctQuality.m_afISIPerc(k) = sum(acEntries{k}.m_afISIDistribution(1:iIndex)) / sum(acEntries{k}.m_afISIDistribution) * 100;
    strctQuality.m_aiNumSpikes(k) = length(acEntries{k}.m_afSpikeTimes);
    
    fAmpRange = max(acEntries{k}.m_afAvgWaveForm)-min(acEntries{k}.m_afAvgWaveForm);
    fMaxStd = max(acEntries{k}.m_afStdWaveForm);
    strctQuality.m_afQuality(k) = fMaxStd./fAmpRange;
end

return;


function acFields = fnExtractAllValues(acEntries,strField)
iNumEntries = length(acEntries);
acFields = cell(1,iNumEntries);
iCounter = 0;
for iIter=1:iNumEntries
    if isfield(acEntries{iIter},strField)
        iCounter = iCounter + 1;
        acFields{iCounter} = getfield(acEntries{iIter},strField);
    end
end;
acFields = acFields(1:iCounter);
return;