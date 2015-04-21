function strctDICOM = fnReadDump(strFilename)
strctDICOM = [];

if ~exist(strFilename,'file')
    return;
end;


EOL = 10;
txt = fileread(strFilename);
iNumLines = sum(txt==EOL);
aiInd = [0,find(txt==EOL), length(txt)+1];
for k=1:iNumLines
    strLine = txt(aiInd(k)+1:aiInd(k+1));
    if strLine(end) == EOL
        strLine = strLine(1:end-1);
    end;
    % remove trailing zeros
    strLine = strLine(1: find(strLine ~= ' ',1,'last'));
    
    strLine = strrep(strLine,'""','''');
    
    if sum(strLine == '[') > 0
        % convert [ to ( and add 1 to index
        while (1)
            iStart = find(strLine == '[',1,'first');
            if isempty(iStart)
                break;
            end;
            iEnd = find(strLine == ']',1,'first');
            iIndexPlus1 = num2str(str2num(strLine(iStart+1:iEnd-1))+1);
            strLine = [strLine(1:iStart-1),'(',iIndexPlus1,')',strLine(iEnd+1:end)];
        end
    end
    
    
    % convert to matlab command style...
    if strLine(1) == '#'
        continue;
    end
    
    % remove comment
    iIndex = find(strLine=='#');
    if ~isempty(iIndex)
        strLine = strLine(1:iIndex-1);
    end
    
    % translate hex to decimal
    iIndex = strfind(strLine,' = 0x');
    if ~isempty(iIndex)
        strLine = [strLine(1:iIndex),' = ',num2str(hex2dec( strLine(iIndex+5:end)))];
    end
    
    if sum(strLine == '=')>0
        % has equal command
        try
            eval(['strctDICOM.',strLine,';']);
        catch
            fprintf('%d failed %s\n',k,strLine);
        end
    else
        % does not have equal command
        iIndex=find(strLine == ' ',1,'first');
        strCmd = [strLine(1:iIndex),' = ''',strLine(iIndex+1:end),''';'];
        try
            eval(['strctDICOM.',strCmd]);
        catch
            fprintf('%d failed %s\n',k,strCmd);
        end
        
    end;
    
end;

dbg = 1;

%hFileID = fopen(strFilename,'r+');
%while
