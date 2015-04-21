function strctDesign = fnLoadBlockDesignNewDesignFile(strDesignXML)
% strDesignXML = 'fMRI_FaceLocalizer_Shay.xml';
%% Parse XML file
try
    strctXML = fnMyXMLToStruct(strDesignXML,false);
catch
        fprintf('Error parsing XML file %s.\n',strDesignXML);
        strctDesign = [];
        return;
end

if ~isfield(strctXML,'Media') 
        fprintf('Error parsing design. Missing Media section\n');
        strctDesign = [];
        return;
end



if ~isfield(strctXML.Media,'Image')    
    iNumImages = 0;
else
    iNumImages = length(strctXML.Media.Image);
end
if iNumImages == 1
    strctXML.Media.Image = {strctXML.Media.Image};
end;

if ~isfield(strctXML.Media,'Movie')
iNumMovies= 0;
else
iNumMovies= length(strctXML.Media.Movie);
end

if iNumMovies == 1
    strctXML.Media.Movie = {strctXML.Media.Movie};
end;

iNumMediaFiles = iNumImages+iNumMovies;

%% Make sure Images and Movies are available on the network. if possible, load images to standard memory
clear strctDesign
strctDesign.m_strctXML = strctXML;

strctDesign.m_strDesignFileName = strDesignXML;
strctDesign.m_bLoadOnTheFly = false;

% Verify all images/movies are available!
acMediaName = cell(1,iNumMediaFiles);
fprintf('Loading/Verifying images/movies existance, please wait...    ');
for iFileIter=1:iNumMediaFiles
    fprintf('\b\b\b\b%4d',iFileIter);
    
    
    acAttributes = cell(0);
    strLengthMS = [];
    if iFileIter <= iNumImages
        % We are reading an image entry
        strFileName = strctXML.Media.Image{iFileIter}.FileName;
        strName = strctXML.Media.Image{iFileIter}.Name;
        if isfield(strctXML.Media.Image{iFileIter},'Attr')
            acAttributes = fnSplitString(strctXML.Media.Image{iFileIter}.Attr);
        end
        if isfield(strctXML.Media.Image{iFileIter},'LengthMS')
            strLengthMS = strctXML.Media.Image{iFileIter}.LengthMS;
        end
    else
        strFileName = strctXML.Media.Movie{iFileIter-iNumImages}.FileName;
        strName = strctXML.Media.Movie{iFileIter-iNumImages}.Name;
        if isfield(strctXML.Media.Movie{iFileIter-iNumImages},'Attr')
            acAttributes = fnSplitString(strctXML.Media.Movie{iFileIter-iNumImages}.Attr);
        end
        if isfield(strctXML.Media.Movie{iFileIter-iNumImages},'LengthMS')
            strLengthMS = strctXML.Media.Movie{iFileIter-iNumImages}.LengthMS;
        end
    end
    
    if isempty(strLengthMS)
             fprintf('\nA media file is missing the "LengthMS" field (%s) \n',strFileName);
            strctDesign = [];
            return;
    end
   
    bExist = exist(strFileName,'file');
    if ~bExist
        % exist sometimes fails for unknown reason... verify again with
        % dir...
            fprintf('\nA media file is missing from the design! : %s \n',strFileName);
            strctDesign = [];
            return;
    end
    strctDesign.m_astrctMedia(iFileIter).m_strFileName = strFileName;
    strctDesign.m_astrctMedia(iFileIter).m_strName = strName;
    strctDesign.m_astrctMedia(iFileIter).m_bMovie = iFileIter>iNumImages;
    strctDesign.m_astrctMedia(iFileIter).m_acAttributes = acAttributes;
    strctDesign.m_astrctMedia(iFileIter).m_strLengthMS = strLengthMS;
    acMediaName{iFileIter} =strName;
end
fprintf('\b\b\b\bDone.\n');
[acUniqueNames,aiIndices1,aiIndices2] = unique(acMediaName);
if length(acUniqueNames) ~= length(acMediaName)
    aiHist=hist(aiIndices2, 1:length(aiIndices1));
    aiDuplicateNames = find(aiHist > 1);
    fprintf('Two images/movies have the same name:');
    for j=1:length(aiDuplicateNames)
        fprintf('DUPLICATE: %s\n',acUniqueNames{aiDuplicateNames(j)});
    end;
    
    fprintf('Aborting...\n');
    strctDesign = [];
    return;
end
strctDesign.m_acMediaName= acMediaName;

%%
[strctDesign.m_acAttributes, strctDesign.m_a2bMediaAttributes] = fnBuildImageAttributeMatrix(strctDesign.m_astrctMedia);
%% Validate Blocks and block order
if ~isfield(strctXML,'Blocks') ||  (isfield(strctXML,'Blocks') && ~isfield(strctXML.Blocks,'Block') )
        fprintf('Aborting... XML file is missing the <Blocks> block\n');
    strctDesign = [];
    return;
end

if ~isfield(strctXML,'BlockOrder') || (isfield(strctXML,'BlockOrder') && ~isfield(strctXML.BlockOrder,'Order'))
        fprintf('Aborting... XML file is missing the <BlockOrder> block\n');
    strctDesign = [];
    return;
end
%% Prep the blocks structure
iNumBlocks = length(strctXML.Blocks.Block);
if iNumBlocks == 1
    strctXML.Blocks.Block = {strctXML.Blocks.Block};
end
strctDesign.m_acBlocks = cell(1,iNumBlocks);
strctDesign.m_acAllBlockNames = cell(1,iNumBlocks);
for iBlockIter=1:iNumBlocks
    strctBlock.m_strName = strctXML.Blocks.Block{iBlockIter}.Name;
    strctDesign.m_acAllBlockNames{iBlockIter} = strctBlock.m_strName;
    strctBlock.m_acAttributes = fnSplitString(strctXML.Blocks.Block{iBlockIter}.Attr);
    abRequiredAttributes = ismember(strctDesign.m_acAttributes,strctBlock.m_acAttributes);
    strctBlock.m_aiMediaIndices = find(sum(strctDesign.m_a2bMediaAttributes(:,abRequiredAttributes),2) > 0);
    strctDesign.m_acBlocks{iBlockIter} = strctBlock;
end



%% Block ordering
iNumOrders = length(strctXML.BlockOrder.Order);
if iNumOrders == 1
    strctXML.BlockOrder.Order = {strctXML.BlockOrder.Order};
end

strctDesign.m_acBlockOrders = cell(1,iNumOrders);
for iOrderIter=1:iNumOrders
    strctOrder.m_strName = strctXML.BlockOrder.Order{iOrderIter}.Name;
    if ~isfield(strctXML.BlockOrder.Order{iOrderIter},'Block')
        fprintf('Aborting... XML file is missing the <Block> block under the <Order> block\n');
        strctDesign = [];
        return;
    end
    iNumBlocksInOrder = length(strctXML.BlockOrder.Order{iOrderIter}.Block);
    if iNumBlocksInOrder == 1
        strctXML.BlockOrder.Order{iOrderIter}.Block = {strctXML.BlockOrder.Order{iOrderIter}.Block};
    end
    
    strctOrder.m_acBlocks = cell(1,iNumBlocksInOrder);
    strctOrder.m_aiBlockIndices = zeros(1,iNumBlocksInOrder);
    for iBlockIter=1:iNumBlocksInOrder
        clear strctBlock
        strctBlock.m_strName = strctXML.BlockOrder.Order{iOrderIter}.Block{iBlockIter}.Name;
        iBlockIndex = find(ismember(strctDesign.m_acAllBlockNames,strctBlock.m_strName));
        if isempty(iBlockIndex)
            fprintf('Aborting... In order %s, unknown block (%s) \n', strctOrder.m_strName, strctBlock.m_strName );
            strctDesign = [];
            return;
        end
        strctOrder.m_aiBlockIndices(iBlockIter) = iBlockIndex;
        strctBlock.m_strctXML = strctXML.BlockOrder.Order{iOrderIter}.Block{iBlockIter};
        strctOrder.m_acBlocks{iBlockIter} = strctBlock;
    end
    strctDesign.m_acBlockOrders{iOrderIter} = strctOrder;
end


%% Global Variables
if isfield(strctXML,'GlobalVars')
    % Parse global defined variables....
    if isfield(strctXML.GlobalVars,'Var')
        iNumVars = length(strctXML.GlobalVars.Var);
        if iNumVars == 1
            strctXML.GlobalVars.Var = {strctXML.GlobalVars.Var};
        end
        for iVarIter=1:iNumVars
            astrctVariables(iVarIter).m_strName = strctXML.GlobalVars.Var{iVarIter}.Name;
            astrctVariables(iVarIter).m_strValue = strctXML.GlobalVars.Var{iVarIter}.InitialValue;
            astrctVariables(iVarIter).m_strType = strctXML.GlobalVars.Var{iVarIter}.Type;
            if isfield(strctXML.GlobalVars.Var{iVarIter},'Panel')
                astrctVariables(iVarIter).m_strPanel = strctXML.GlobalVars.Var{iVarIter}.Panel;
            end
             if isfield(strctXML.GlobalVars.Var{iVarIter},'Description')
                astrctVariables(iVarIter).m_strDescription = strctXML.GlobalVars.Var{iVarIter}.Description;
            end
        end
        strctDesign.m_astrctGlobalVars = astrctVariables;
    end
else
    strctDesign.m_astrctGlobalVars = [];
end

return;
