function astrctQueue = fnCondorQueue()
strTempFileName = tempname;
strTempFileName2 = tempname;
system(['condor_q -xml >',strTempFileName]);
hFileID = fopen(strTempFileName);
hFileID2 = fopen(strTempFileName2,'w+');
while (1)
    strLine = fgetl(hFileID);
    if length(strLine) == 1 && strLine(1) == -1
        break;
    end;
    if ~strncmpi(strLine,'<!DOCTYPE',9)
        fprintf(hFileID2,'%s\n',strLine);
    end
end
fclose(hFileID);
fclose(hFileID2);

astrctQueue = [];
astrctTemp = xml2struct(strTempFileName2);
iNumJobs = 0;
for iIter=1:length(astrctTemp.Children)
    if strcmp(astrctTemp.Children(iIter).Name,'c')
        strctJob.m_iJobID = str2num(fnScanFields(astrctTemp.Children(iIter).Children, 'ClusterId'));
        strctJob.m_iJobStatus = str2num(fnScanFields(astrctTemp.Children(iIter).Children, 'JobStatus'));
        strctJob.m_strJobStatus = fnJobStatusString(strctJob.m_iJobStatus);
        iNumJobs = iNumJobs + 1;
        if iNumJobs == 1
            astrctQueue = strctJob;
        else
            astrctQueue(iNumJobs) = strctJob;
        end
    end
end
return;

function strValue = fnScanFields(astrctFields, strField)
strValue = [];
for k=1:length(astrctFields)
   if isfield(astrctFields(k),'Attributes') && ~isempty(astrctFields(k).Attributes) && strcmp(astrctFields(k).Attributes.Value,strField)
       strValue = astrctFields(k).Children.Children.Data;
       return;
   end
end

function strString = fnJobStatusString(iIndex)
switch  iIndex
    case 0
        strString = 'Never Run';
    case 1
        strString = 'Idle (waiting)';
    case 2
        strString = 'Running';
    case 3
        strString = 'Removed';
    case 4
        strString = 'Completed';
    case 5
        strString = 'Held';
    otherwise
        strString  = 'Unknown';
end
return;
