function [strctDesign, bStereoRequired] = fnParseHandMappingMediaFiles(strDesignXML, bVerifyExistance, bMessages)

% We don't have a design for Hand Mapping, but I'm keeping the functions around just in case we ever want to import anything
% Also, it's less of a pain in the ass to break this than have to reprogram the init functions of kofiko


    strctDesign = [];
bStereoRequired = false;
%% Load the XML    
try
    fprintf('Parsing XML, please wait...');
    strctXML = fnMyXMLToStruct(strDesignXML,false,true);
    fprintf('Done!\n');
catch
    fprintf('Error reading XML!\n');
    if bMessages
        fnParadigmToKofikoComm('DisplayMessage','Error parsing XML!');
    end
    return;
end

if ~isfield(strctXML,'Media') 
    if bMessages
        fnParadigmToKofikoComm('DisplayMessage','Error parsing XML! Media Section Missing');
    end
    return;
end
%% Parse the media section
[astrctMedia, acMediaName] = fnParseAndReorderMedia(strctXML,bVerifyExistance ,bMessages );
if isempty(astrctMedia)
    return;
end;

strctDesign.m_strDesignFileName = strDesignXML;
strctDesign.m_bLoadOnTheFly = false;
strctDesign.m_acMediaName = acMediaName;
strctDesign.m_astrctMedia = astrctMedia;
bStereoRequired = sum(ismember({'StereoImage','StereoMovie'},{astrctMedia.m_strMediaType})) > 0;
%% Verify media file naming convension
[acUniqueNames,aiIndices1,aiIndices2] = unique(acMediaName);
if length(acUniqueNames) ~= length(acMediaName)
    aiHist=hist(aiIndices2, 1:length(aiIndices1));
    aiDuplicateNames = find(aiHist > 1);
    fprintf('Two images/movies have the same name:\n');
    for j=1:length(aiDuplicateNames)
        fprintf('DUPLICATE: %s\n',acUniqueNames{aiDuplicateNames(j)});
    end;
    if bMessages
        fnParadigmToKofikoComm('DisplayMessage','Design has duplicate media files.Aborting.');
    end
    fprintf('Aborting...\n');
    strctDesign = [];
    return;
end

%% Parse Condition section
% Now extract information from XML about conditions....
[acAllAttributes, a2bMediaAttributes] = fnBuildImageAttributeMatrix(strctDesign.m_astrctMedia);
    iNumMediaFiles = length(acMediaName);

if isfield(strctXML,'Conditions') 
    if isempty(strctXML.Conditions)
        iNumConditions = 0;
    else
        iNumConditions = length(strctXML.Conditions.Condition);
    end
    strctDesign.m_a2bStimulusToCondition = zeros(iNumMediaFiles, iNumConditions) > 0;
    strctDesign.m_abVisibleConditions = zeros(1, iNumConditions) > 0;
    if iNumConditions == 1
        strctXML.Conditions.Condition = {strctXML.Conditions.Condition};
    end
    
    for iCondIter=1:iNumConditions
        strctCondition = strctXML.Conditions.Condition{iCondIter};
        
        if isfield(strctCondition,'Name')
            strctDesign.m_acConditionNames{iCondIter} = strctCondition.Name;
        else
            strctDesign.m_acConditionNames{iCondIter} = sprintf('Condition %d',iCondIter);
        end
        
        % Find which stimuli match this condition
        abStimuliWithValidAttributes = ones(iNumMediaFiles,1) > 0;
        if isfield(strctCondition,'ValidAttributes')
           acRequiredAttributes = fnSplitString(strctCondition.ValidAttributes);
           abStimuliWithValidAttributes =  all(a2bMediaAttributes(:,ismember(acAllAttributes,acRequiredAttributes)),2);
        end
        
        abStimuliWithInvalidAttributes = zeros(iNumMediaFiles,1) > 0;
        if isfield(strctCondition,'InvalidAttributes')
           acRequiredAttributes = fnSplitString(strctCondition.InvalidAttributes);
           abStimuliWithInvalidAttributes =  all(a2bMediaAttributes(:,ismember(acAllAttributes,acRequiredAttributes)),2);
        end
        
        if isfield(strctCondition,'DefaultVisibility')
            strctDesign.m_abVisibleConditions(iCondIter) = str2num(strctCondition.DefaultVisibility) > 0 ;
        end
           strctDesign.m_a2bStimulusToCondition(:, iCondIter) = abStimuliWithValidAttributes & ~abStimuliWithInvalidAttributes;
    end
else
    strctDesign.m_acConditionNames = [];
    strctDesign.m_a2bStimulusToCondition = [];
    strctDesign.m_abVisibleConditions = [];
end

%% Parse block and block order sections....
if isfield(strctXML,'Blocks')
    if ~iscell(strctXML.Blocks.Block)
        strctXML.Blocks.Block = {strctXML.Blocks.Block};
    end
    iNumBlocks = length(strctXML.Blocks.Block);
    % Build Media to Block Matrix...
    
    a2bMediaInBlock = zeros(iNumMediaFiles,iNumBlocks) > 0;
    acBlockNames = cell(1,iNumBlocks);
    for iBlockIter=1:iNumBlocks
        if ~isfield(strctXML.Blocks.Block{iBlockIter},'Name')
            strBlockName = sprintf('Block %d',iBlockIter);
        else
            strBlockName = strctXML.Blocks.Block{iBlockIter}.Name;
        end
        acBlockNames{iBlockIter} = strBlockName;
        if ~isfield(strctXML.Blocks.Block{iBlockIter},'Attr')
            % Assume empty block ?
            fprintf('Warning. Block "%s" has no attributes. No media will be presented!\n',strBlockName);
        else
             acBlockAttributes = fnSplitString( strctXML.Blocks.Block{iBlockIter}.Attr);
             aiRequiredAttributes = find(ismember(acAllAttributes,acBlockAttributes));
             a2bMediaInBlock(sum(a2bMediaAttributes(:,aiRequiredAttributes),2) > 0, iBlockIter) = 1;
        end
        
        astrctBlocks(iBlockIter).m_strBlockName = strBlockName;
        astrctBlocks(iBlockIter).m_aiMedia = find(a2bMediaInBlock(:,iBlockIter));
        if isempty(astrctBlocks(iBlockIter).m_aiMedia)
            fprintf('Critical error! Design contains an empty block (no matching media files found for block %s\n',strBlockName);
            strctDesign = [];
            return;

        end
        
        % For future versions..... ?!?
        if isfield(strctXML.Blocks.Block{iBlockIter},'MicroStim') && str2num(strctXML.Blocks.Block{iBlockIter}.MicroStim) > 0
            if isfield(strctXML.Blocks.Block{iBlockIter},'MicroStimChannels')
                astrctBlocks(iBlockIter).m_aiMicroStimChannels = str2num(strctXML.Blocks.Block{iBlockIter}.MicroStimChannels);
            else
                astrctBlocks(iBlockIter).m_aiMicroStimChannels = 1;
            end
            
            astrctBlocks(iBlockIter).m_bMicroStim = true;
        else
            astrctBlocks(iBlockIter).m_bMicroStim = false;
        end
        if isfield(strctXML.Blocks.Block{iBlockIter},'MicroStimAttr') 
            astrctBlocks(iBlockIter).m_acMicroStimAttributes = fnSplitString(strctXML.Blocks.Block{iBlockIter}.MicroStimAttr);
        else
            astrctBlocks(iBlockIter).m_acMicroStimAttributes = [];
        end
        
        astrctBlocks(iBlockIter).m_fBlockLengthMS = [];
    end
     strctDesign.m_strctBlocksAndOrder.m_astrctBlocks = astrctBlocks;
     strctDesign.m_strctBlocksAndOrder.m_a2bMediaInBlock = a2bMediaInBlock;
       
    else
     % Add a fictetious block that contains all media files and a single
     % block order that contains only this block.
         iNumMediaFiles = length(acMediaName);
       strctDesign.m_strctBlocksAndOrder.m_a2bMediaInBlock = ones(iNumMediaFiles,1) > 0;
       strctDesign.m_strctBlocksAndOrder.m_astrctBlocks(1).m_strBlockName = 'Block 1';
       strctDesign.m_strctBlocksAndOrder.m_astrctBlocks(1).m_aiMedia = 1:iNumMediaFiles;
       strctDesign.m_strctBlocksAndOrder.m_astrctBlocks(1).m_bMicroStim = false;
       strctDesign.m_strctBlocksAndOrder.m_astrctBlocks(1).m_fBlockLengthMS = [];
end

% Block order
if isfield(strctXML,'BlockOrder')
    if ~iscell(strctXML.BlockOrder.Order)
        strctXML.BlockOrder.Order = {strctXML.BlockOrder.Order};
    end
    iNumDifferentOrders = length(strctXML.BlockOrder.Order);
    for iOrderIter=1:iNumDifferentOrders 
        if isfield(strctXML.BlockOrder.Order{iOrderIter},'Name')
            strOrderName = strctXML.BlockOrder.Order{iOrderIter}.Name;
        else
            strOrderName = sprintf('Order %d',iOrderIter);
        end
        
        if ~iscell(strctXML.BlockOrder.Order{iOrderIter}.Block)
            strctXML.BlockOrder.Order{iOrderIter}.Block = {strctXML.BlockOrder.Order{iOrderIter}.Block};
        end
        
        iNumBlockOrder = length(strctXML.BlockOrder.Order{iOrderIter}.Block);
        aiBlockIndex = zeros(1,iNumBlockOrder);
        aiNumRepititions = zeros(1,iNumBlockOrder);
        for iBlockOrderIter=1:iNumBlockOrder
            if ~isfield(strctXML.BlockOrder.Order{iOrderIter}.Block{iBlockOrderIter},'Name')
                fprintf('Missing block name in block order module\n');
                strctDesign = [];
                return;
            end
            
            iIndex = fnFindString(lower(acBlockNames),  lower(strctXML.BlockOrder.Order{iOrderIter}.Block{iBlockOrderIter}.Name));
            if iIndex == -1
                fprintf('Unknown block name in block order module (%s) \n', strctXML.BlockOrder.Order{iOrderIter}.Block{iBlockOrderIter}.Name);
                strctDesign = [];
                return;
            end
            
            if isfield(strctXML.BlockOrder.Order{iOrderIter}.Block{iBlockOrderIter},'Repitition')
                iNumRepeat = str2num(strctXML.BlockOrder.Order{iOrderIter}.Block{iBlockOrderIter}.Repitition);
            else
                iNumRepeat = 1;
            end
            
            aiBlockIndex(iBlockOrderIter) = iIndex;
            aiNumRepititions(iBlockOrderIter) = iNumRepeat;
        end
        
        strctDesign.m_strctBlocksAndOrder.m_astrctBlockOrder(iOrderIter).m_strOrderName = strOrderName;
        strctDesign.m_strctBlocksAndOrder.m_astrctBlockOrder(iOrderIter).m_aiBlockIndexOrder = aiBlockIndex;
        strctDesign.m_strctBlocksAndOrder.m_astrctBlockOrder(iOrderIter).m_aiBlockRepitition =aiNumRepititions;
    end
else
    % Add fictetious block order...
    strctDesign.m_strctBlocksAndOrder.m_astrctBlockOrder(1).m_strOrderName = 'Default Order';
    strctDesign.m_strctBlocksAndOrder.m_astrctBlockOrder(1).m_aiBlockIndexOrder = 1;
    strctDesign.m_strctBlocksAndOrder.m_astrctBlockOrder(1).m_aiBlockRepitition = 1;
end
    
 
return;



function [astrctMedia,acMediaName, acFileNamesToLoad] = fnParseAndReorderMedia(strctXML,bVerifyExistance,bMessages)
if ~isfield(strctXML.Media,'Image')    
    iNumImages = 0;
    strctXML.Media.Image= [];
else
    iNumImages = length(strctXML.Media.Image);
end
if iNumImages == 1
    strctXML.Media.Image= {strctXML.Media.Image};
end

if ~isfield(strctXML.Media,'StereoImage')    
    iNumStereoImages = 0;
    strctXML.Media.StereoImage = [];
else
    iNumStereoImages = length(strctXML.Media.StereoImage);
end
if iNumStereoImages == 1
    strctXML.Media.StereoImage= {strctXML.Media.StereoImage};
end

if ~isfield(strctXML.Media,'StereoMovie')    
    iNumStereoMovies = 0;
     strctXML.Media.StereoMovie = [];
else
    iNumStereoMovies = length(strctXML.Media.StereoMovie);
end
if iNumStereoMovies == 1
    strctXML.Media.StereoMovie= {strctXML.Media.StereoMovie};
end

if ~isfield(strctXML.Media,'Movie')
    iNumMovies= 0;
     strctXML.Media.Movie =[];
else
    iNumMovies= length(strctXML.Media.Movie);
end
if iNumMovies == 1
    strctXML.Media.Movie = {strctXML.Media.Movie};
end
if ~isfield(strctXML.Media,'Command')    
    iNumCommands = 0;
    strctXML.Media.Command= [];
else
    iNumCommands = length(strctXML.Media.Command);
end
if iNumCommands == 1
    strctXML.Media.Command = {strctXML.Media.Command};
end

iNumMediaFiles = iNumImages+iNumMovies+iNumCommands+iNumStereoMovies+iNumStereoImages;

% Verify all images/movies are available!
acMediaName = cell(1,iNumMediaFiles);
if bMessages
    try
        fnParadigmToKofikoComm('DisplayMessageNow','Loading/Verifying images/movies existance, please wait...');
    catch
    end
end
try
    [astrctMonoImages, aiImageOrdering] = fnAddMonoEntries(strctXML.Media.Image,bVerifyExistance, 'Image');
    [astrctMonoMovies, aiMovieOrdering] = fnAddMonoEntries(strctXML.Media.Movie,bVerifyExistance, 'Movie');
	[astrctMonoCommands, aiCommandOrdering] = fnAddMonoEntries(strctXML.Media.Command,bVerifyExistance, 'Command');
    [astrctStereoImages, aiStereoImageOrdering] = fnAddStereoEntries(strctXML.Media.StereoImage,bVerifyExistance, 'StereoImage');
    [astrctStereoMovies, aiStereoMovieOrdering] = fnAddStereoEntries(strctXML.Media.StereoMovie,bVerifyExistance, 'StereoMovie');
catch
    astrctMedia = [];
    acMediaName = [];
    return;
end

aiOrdering = [aiImageOrdering, aiMovieOrdering, aiCommandOrdering, aiStereoImageOrdering, aiStereoMovieOrdering];
astrctMedia = [astrctMonoImages, astrctMonoMovies,astrctMonoCommands, astrctStereoImages, astrctStereoMovies];
[aiDummy, aiNewOrder] = sort(aiOrdering);
astrctMedia = astrctMedia(aiNewOrder);
acMediaName = {astrctMedia.m_strName};
return;


function [astrctMedia, aiOrderingInXML] = fnAddMonoEntries(acMedia,bVerifyExistance, strMediaType)
if isempty(acMedia)
    astrctMedia = [];
    aiOrderingInXML = [];
end;
iNumMediaFiles = length(acMedia );
aiOrderingInXML = zeros(1,iNumMediaFiles);
astrctMedia = [];
for iFileIter=1:iNumMediaFiles
    acAttributes = cell(0);
    if ~isfield(acMedia{iFileIter},'FileName')
        error('A FileName field is missing in the design!');
    end
    aiOrderingInXML(iFileIter) = acMedia{iFileIter}.XML_Ordering(2);
    strFileName = acMedia{iFileIter}.FileName;
    if ~isfield(acMedia{iFileIter},'Name')
        [strPath,strFile]=fileparts(strFileName);
        strName = strFile;
    else
        strName = acMedia{iFileIter}.Name;
    end
    if isfield(acMedia{iFileIter},'Attr')
        acAttributes = fnSplitString(acMedia{iFileIter}.Attr);
    end
    
    if bVerifyExistance
        bExist = exist(strFileName,'file');
        if ~bExist
            fprintf('\nA media file is missing from the design! : %s \n',strFileName);
            astrctMedia = [];
            error('Missing File!');
        end
    end;
    astrctMedia(iFileIter).m_acFileNames = {strFileName};
    astrctMedia(iFileIter).m_strName = strName;
    astrctMedia(iFileIter).m_strMediaType = strMediaType;
    astrctMedia(iFileIter).m_acAttributes = acAttributes;
end

return;




function [astrctMedia, aiOrderingInXML] = fnAddStereoEntries(acMedia,bVerifyExistance, strMediaType)
if isempty(acMedia)
    astrctMedia = [];
    aiOrderingInXML = [];
end;
iNumMediaFiles = length(acMedia );
aiOrderingInXML = zeros(1,iNumMediaFiles);
astrctMedia = [];
for iFileIter=1:iNumMediaFiles
    acAttributes = cell(0);
    if ~isfield(acMedia{iFileIter},'LeftFileName') || ~isfield(acMedia{iFileIter},'RightFileName') 
        error('LeftFileName or RightFileNAme fields are missing in the design!');
    end
    
    strLeftFileName = acMedia{iFileIter}.LeftFileName;
    strRightFileName = acMedia{iFileIter}.RightFileName;
    
    if ~isfield(acMedia{iFileIter},'Name')
        [strPath,strLeftFile]=fileparts(strLeftFileName);
        [strPath,strRightFile]=fileparts(strRightFileName);
        strName = [strLeftFile,'-',strRightFile];
    else
        strName = acMedia{iFileIter}.Name;
    end
    if isfield(acMedia{iFileIter},'Attr')
        acAttributes = fnSplitString(acMedia{iFileIter}.Attr);
    end
    aiOrderingInXML(iFileIter) = acMedia{iFileIter}.XML_Ordering(2);
    
    if bVerifyExistance
        bExist = exist(strLeftFileName,'file') && exist(strRightFileName,'file');
        if ~bExist
            fprintf('\nA media file is missing from the design! : %s or %s\n',strLeftFileName,strRightFileName);
            acMediaName = [];
            astrctMedia = [];
            error('Missing File!');
        end
    end;
    astrctMedia(iFileIter).m_acFileNames = {strLeftFileName, strRightFileName};
    astrctMedia(iFileIter).m_strName = strName;
   astrctMedia(iFileIter).m_strMediaType = strMediaType;
    astrctMedia(iFileIter).m_acAttributes = acAttributes;
end

return;
