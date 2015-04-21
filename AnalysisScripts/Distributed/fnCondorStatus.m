function astrctMachines = fnCondorStatus()
astrctMachines = [];

strTempFileName = tempname;
strTempFileName2 = tempname;
system(['condor_status -xml >',strTempFileName]);
hFileID = fopen(strTempFileName);
hFileID2 = fopen(strTempFileName2,'w+');
bFileEmpty = true;
while (1)
    strLine = fgetl(hFileID);
    if length(strLine) == 1 && strLine(1) == -1
        break;
    end;
    bFileEmpty = false;
    if ~strncmpi(strLine,'<!DOCTYPE',9)
        fprintf(hFileID2,'%s\n',strLine);
    end
end
fclose(hFileID);
fclose(hFileID2);
    
if bFileEmpty
    return;
end

astrctTemp = xml2struct(strTempFileName2);
iNumMachines = 0;
for iIter=1:length(astrctTemp.Children)
    if strcmp(astrctTemp.Children(iIter).Name,'c')
        strctMachine.m_strName = fnScanFields(astrctTemp.Children(iIter).Children, 'Name');
        strctMachine.m_strMachine  = fnScanFields(astrctTemp.Children(iIter).Children, 'Machine');
        strctMachine.m_strState = fnScanFields(astrctTemp.Children(iIter).Children, 'State');
        strctMachine.m_iMemory = str2num(fnScanFields(astrctTemp.Children(iIter).Children, 'Memory'));
        iNumMachines = iNumMachines + 1;
        if iNumMachines == 1
            astrctMachines = strctMachine;
        else
            astrctMachines(iNumMachines) = strctMachine;
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
