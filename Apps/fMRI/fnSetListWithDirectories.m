function acAllNames=fnSetListWithDirectories(hListbox, strInputFolder,bMultSel, bSortByDate)
if ~exist('bSortByDate','var')
    bSortByDate = false;
end;
if ~isempty(strInputFolder)
    astrctDir = dir(strInputFolder);
    abIsDir = cat(1,astrctDir.isdir);
    acAllNames = {astrctDir.name};
    acAllNames = acAllNames(abIsDir);

    afTime = cat(1,astrctDir.datenum);
    afTime = afTime(abIsDir);
    if bSortByDate
        [afDummy, aiInd] = sort(afTime,'descend');
        acAllNames=acAllNames(aiInd);
    end
    
    if exist('bMultSel','var') && ~bMultSel
        set(hListbox,'string',acAllNames,'min',1,'max',1,'value',1);
    else
        set(hListbox,'string',acAllNames,'min',1,'max',sum(abIsDir),'value',1);
    end
end
