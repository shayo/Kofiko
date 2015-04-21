function [astrctTrials,astrctChoices] = fnReadForcedChoiceDesignFile(strDesignFile)
hFileID = fopen(strDesignFile);
[strPath,strFile] = fileparts(strDesignFile);
iNumChoices = 0;
iNumTrials = 0;

while(1)
    strLine =  fgets(hFileID);
    
    switch strLine(1)
        case -1
            break;
        case 13
        case 10
        case 32
        case 'C'
            astrctIntervals = fnGetIntervals(strLine ~= 32);
            assert(length(astrctIntervals) == 5);
            strctChoice.m_strName = strtrim(strLine(astrctIntervals(2).m_iStart:astrctIntervals(2).m_iEnd));
            strctChoice.m_strImageFileName = strLine(astrctIntervals(3).m_iStart:astrctIntervals(3).m_iEnd);
            strctChoice.m_pt2fRelativePos = [str2num(strLine(astrctIntervals(4).m_iStart:astrctIntervals(4).m_iEnd)),...
                              str2num(strLine(astrctIntervals(5).m_iStart:astrctIntervals(5).m_iEnd))];
            strctChoice.m_Image = imread(fullfile(strPath,strctChoice.m_strImageFileName));
            iNumChoices = iNumChoices + 1;
            astrctChoices(iNumChoices) = strctChoice;
        case 'T'
            astrctIntervals = fnGetIntervals(strLine ~= 32 & strLine ~= 9 & strLine ~= 10 & strLine ~= 13);
            assert(length(astrctIntervals) >= 3);
            clear strctImage
            strctTrial.m_strImageFileName = strLine(astrctIntervals(2).m_iStart:astrctIntervals(2).m_iEnd);
            if ~exist(fullfile(strPath,strctTrial.m_strImageFileName),'file')
                fprintf('ERROR reading design file!. %s is missing !\n',strctTrial.m_strImageFileName);
                continue;
            end
            strctTrial.m_Image = imread(fullfile(strPath,strctTrial.m_strImageFileName));
            iNumChoices = length(astrctIntervals) - 2;
            strctTrial.m_aiChoices = zeros(1,iNumChoices);
            for k=1:iNumChoices
                strChoice = strtrim(strLine(astrctIntervals(2+k).m_iStart:astrctIntervals(2+k).m_iEnd));
                % Find the corresponding choice
                iChoiceIndex = -1;
                for j=1:length(astrctChoices)
                    if strcmpi(strChoice, astrctChoices(j).m_strName)
                        iChoiceIndex = j;
                        break;
                    end
                end
                assert(iChoiceIndex > 0);
                strctTrial.m_aiChoices(k) = iChoiceIndex;
            end
            
            iNumTrials = iNumTrials + 1;
            astrctTrials(iNumTrials) = strctTrial;
            
        otherwise
            assert(false);
    end
end;
if ~exist('astrctTrials','var')
    assert(false);
end;
fclose(hFileID);
