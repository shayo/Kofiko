function acData = fnLoadDataEntries(acDataEntries)
iNumEntries = length(acDataEntries);
abMissingData = zeros(1,iNumEntries)>0;
fprintf('000');
for iIter=1:iNumEntries
    fprintf('\b\b\b%03d',iIter);drawnow
    if ~isfield(acDataEntries{iIter},'m_strFile')
        if exist(acDataEntries{iIter},'file')
            acData{iIter} = load(acDataEntries{iIter});
        else
            abMissingData(iIter) = true;
            acData{iIter} = [];
        end
        
    else
        
        if exist(acDataEntries{iIter}.m_strFile,'file')
            acData{iIter} = load(acDataEntries{iIter}.m_strFile);
        else
            abMissingData(iIter) = true;
            acData{iIter} = [];
        end
    end
end
if sum(abMissingData) > 0
    fprintf('Some data entries are missing:\n');
    aiMissingItems = find(abMissingData);
    for j=1:length(aiMissingItems)
        fprintf('%s\n',acDataEntries{aiMissingItems(j)}.m_strFile);
    end
    
end
return;

