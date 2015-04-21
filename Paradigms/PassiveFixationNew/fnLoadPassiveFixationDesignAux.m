function strctDesign = fnLoadPassiveFixationDesignAux(strDesignFile)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
[strPath, strFile, strExt] = fileparts(strDesignFile);

if strcmpi(strExt,'.txt')
    % convert to XML and load....
    [strTempXmlFile] = fnConvertOldStyleImageListToNewStyleImageList(strDesignFile);
    strctDesign = fnReadNewStyleDesign(strTempXmlFile);
else
    strctDesign = fnReadNewStyleDesign(strDesignFile);
end

return;

function strctDesign = fnReadNewStyleDesign(strDesignXML)
global g_strctParadigm
% Parse XML...
 [strctDesign, bStereoRequired] = fnParsePassiveFixationDesignMediaFiles(strDesignXML, true, true);
 if isempty(strctDesign)
     return;
 end;
 % Design contain array of media (images, movies, stereo images, stereo
 % movies, multiple images, etc...)
 % Each media can contain more than one file that is needed.
 % The next step is to understand exactly which files are needed to be
 % loaded and to keep an indexing system from media to loaded files (or PTB
 % textures).
 [acFileNames, acMediaToHandleIndex] = fnMediaToFilesToLoad(strctDesign.m_astrctMedia);

% Update media fields with infomration
for iMediaIter=1:length(strctDesign.m_astrctMedia)
    strctDesign.m_astrctMedia(iMediaIter).m_aiMediaToHandleIndexInBuffer = acMediaToHandleIndex{iMediaIter};
end

fnParadigmToKofikoComm('ClearMessageBuffer');
% Instruct stimulus server to load the required files.
bForceStereoForMonocularLists = fnTsGetVar(g_strctParadigm,'ForceStereoOnMonocularLists') > 0;

if bStereoRequired || bForceStereoForMonocularLists
    fnParadigmToStimulusServer('SetStereoMonoMode','Stereo');
else
    fnParadigmToStimulusServer('SetStereoMonoMode','Mono');
end

fnParadigmToStimulusServer('ForceMessage','LoadImageList',acFileNames);
% Now, load these files locally as well...
fnParadigmPassiveCleanTextureMemory();

  bShowWhileLoading =  isfield(g_strctParadigm,'m_bShowWhileLoading') && g_strctParadigm.m_bShowWhileLoading ;
 
[g_strctParadigm.m_strctTexturesBuffer.m_ahHandles,...
    g_strctParadigm.m_strctTexturesBuffer.m_a2iTextureSize,...
    g_strctParadigm.m_strctTexturesBuffer.m_abIsMovie,...
    g_strctParadigm.m_strctTexturesBuffer.m_aiApproxNumFrames,...
    g_strctParadigm.m_strctTexturesBuffer.m_afMovieLengthSec,...
    g_strctParadigm.m_strctTexturesBuffer.m_acImages] = fnInitializeTexturesAux(acFileNames,bShowWhileLoading,false);
    
bTimeout = fnParadigmToKofikoComm('BlockUntilMessage','LoadedImage', length(acFileNames),10); % 10 sec timeout
if bTimeout
        fnParadigmToKofikoComm('DisplayMessage','Stimulus server not finished loading!!!!');
end
return;
 

function [acFilesNames, acMediaToHandleIndex] = fnMediaToFilesToLoad(astrctMedia)
acAllFiles = cell(0);
iNumMedia = length(astrctMedia);
for k=1:iNumMedia
    acAllFiles = [acAllFiles, astrctMedia(k).m_acFileNames];
end
acFilesNames = unique(acAllFiles);

acMediaToHandleIndex= cell(1,iNumMedia);
for k=1:iNumMedia
    for j=1:length(astrctMedia(k).m_acFileNames)
        acMediaToHandleIndex{k}(j) = fnFindString( acFilesNames,  astrctMedia(k).m_acFileNames{j});
    end
end
return;



function strXMLfile = fnConvertOldStyleImageListToNewStyleImageList(strDesignFile)
[acFileNames ] = fnReadImageList(strDesignFile);
iNumMediaFiles = length(acFileNames);
% Try to load the corresponding category file
acMediaAttributes = cell(1, iNumMediaFiles);

[strPath, strFile, strExt] = fileparts(strDesignFile);
strCatFile = [strPath,'\',strFile,'_Cat.mat'];
if exist(strCatFile,'file')
    Tmp = load(strCatFile);
    a2bStimulusToCondition = Tmp.a2bStimulusCategory > 0;
    acConditionNames = Tmp.acCatNames;
    
    if size(a2bStimulusToCondition,1) ~= iNumMediaFiles || size(a2bStimulusToCondition,2) ~= length(acConditionNames)
        fnParadigmToKofikoComm('DisplayMessage','Category file does not match list!');
        acConditionNames = [];
    end;
     abVisibleConditions = ones(1, length(  acConditionNames)) > 0;
    for iMediaIter=1:iNumMediaFiles
         acMediaAttributes{iMediaIter} = acConditionNames(a2bStimulusToCondition(iMediaIter,:));
    end
else
   acConditionNames = [];
   abVisibleConditions = [];
end;

% Now that we have file names and conditions, generate the xml...
[strPath, strFile] = fileparts(strDesignFile);
strXMLfile = [tempdir,strFile,'.xml'];
hFileID = fopen(strXMLfile,'w+');
fprintf(hFileID,'<Config>\n\n');
fprintf(hFileID,'    <Media>\n');
for iFileIter=1:length(acFileNames)
    
    strAttributes = '';
     if ~isempty(acMediaAttributes{iFileIter} )
         iNumAttributes = length(acMediaAttributes{iFileIter});
         if iNumAttributes == 1
             strAttributes = acMediaAttributes{iFileIter}{1};
         else
            for iAttrIter=1:iNumAttributes
                strAttributes = [strAttributes,';',acMediaAttributes{iFileIter}{iAttrIter}];
            end
         end
         
     end
     
    [strDummy, strName] = fileparts(acFileNames{iFileIter});
     fprintf(hFileID,'        <Image Name = "%s" FileName = "%s"  Attr = "%s"> </Image>\n',strName,acFileNames{iFileIter},strAttributes);
end

fprintf(hFileID,'\n    </Media>\n');
 fprintf(hFileID,'    <Conditions>\n');
 iNumConditions = length(acConditionNames);
 for iCondIter=1:iNumConditions       
     fprintf(hFileID,'        <Condition Name = "%s" ValidAttributes = "%s" DefaultVisibility = "1"> </Condition>\n',acConditionNames{iCondIter},acConditionNames{iCondIter});
 end  
  fprintf(hFileID,'    </Conditions>\n');
  
  
      
fprintf(hFileID,'    <StatServer\n');
fprintf(hFileID,'        NumTrialsInCircularBuffer = "200"\n');
fprintf(hFileID,'        Pre_TimeSec = "0.5"\n');
fprintf(hFileID,'        Post_TimeSec = "0.5"\n');
fprintf(hFileID,'    > </StatServer>   \n');

fprintf(hFileID,'</Config>\n\n');
fclose(hFileID);
return;






