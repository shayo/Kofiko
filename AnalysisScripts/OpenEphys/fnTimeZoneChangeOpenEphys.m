function targetTS = fnTimeZoneChangeOpenEphys(strctSync, strFrom, strTo, sourceTS)
if strcmpi(strFrom,'Software') 
    if strcmpi(strTo,'Hardware')
        targetTS = fnTimeZoneChangeOpenEphysAux(strctSync.strctSoftwareHardwareSync, sourceTS);
    elseif strcmpi(strTo,'Kofiko')
        targetTS = fnTimeZoneChangeOpenEphysAux(strctSync.strctLocalRemoteSync, sourceTS);
    end
elseif strcmpi(strFrom,'Hardware')
    if strcmpi(strTo,'Software')         
        targetTS = fnInvTimeZoneChangeOpenEphysAux(strctSync.strctSoftwareHardwareSync, sourceTS);
    elseif strcmpi(strTo,'Kofiko')         
        softwareTS = fnTimeZoneChangeOpenEphys(strctSync, 'Hardware', 'Software', sourceTS); 
        targetTS = fnTimeZoneChangeOpenEphys(strctSync, 'Software', 'Kofiko', softwareTS);
    end
elseif strcmpi(strFrom,'Kofiko')
    if strcmpi(strTo,'Software')         
        targetTS = fnInvTimeZoneChangeOpenEphysAux(strctSync.strctLocalRemoteSync, sourceTS);
    elseif strcmpi(strTo,'Hardware')
        softwareTS = fnTimeZoneChangeOpenEphys(strctSync, 'Kofiko', 'Software', sourceTS); 
        targetTS = fnTimeZoneChangeOpenEphys(strctSync, 'Software', 'Hardware', softwareTS);
    elseif strcmpi(strTo,'HardwarePrecise')
        targetTS = fnTimeZoneChangeOpenEphysAux(strctSync.strctKofikoSoftwareToEphysHardwareSync, sourceTS);
    end
end


function targetTS = fnTimeZoneChangeOpenEphysAux(strctSync, sourceTS)
% Convert a time stamp from one domain to another (say, hardware -> software) or viseversa
targetTS = (sourceTS - strctSync.sourceT0) * strctSync.coeff(2) + strctSync.coeff(1) + strctSync.targetT0;
return

function sourceTS = fnInvTimeZoneChangeOpenEphysAux(strctSync, targetTS)
% Convert a time stamp from one domain to another (say, hardware -> software) or viseversa
sourceTS = (targetTS-strctSync.targetT0-strctSync.coeff(1))/strctSync.coeff(2) +strctSync.sourceT0;
return;

