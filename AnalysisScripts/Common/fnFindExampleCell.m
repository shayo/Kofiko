function iSelectedCell = fnFindExampleCell(acUnits, strSubject, strRecordedTimeDate, iExperiment, iChannel, iUnitID, strList)
iSelectedCell = [];
for k=1:length(acUnits)
    if strcmp(acUnits{k}.m_strRecordedTimeDate,strRecordedTimeDate) && ...
            strcmpi(acUnits{k}.m_strSubject, strSubject) && ...
            acUnits{k}.m_iRecordedSession == iExperiment && ...
            acUnits{k}.m_iUnitID == iUnitID && ...
            acUnits{k}.m_iChannel == iChannel
        if ~exist('strList','var') || (exist('strList','var') && strcmpi(strList, acUnits{k}.m_strImageListDescrip))
            iSelectedCell = k;
            break;
        end
    end
end
return;
