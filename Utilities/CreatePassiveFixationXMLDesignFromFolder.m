% strRoot = 'C:\kofiko\StimulusSet\fMRI_Standard_Localizer\';
% strImageList = [strRoot,'stimlist_face_body_places_localizer.txt'];
% strBlockList = [strRoot,'blocklist_face_body_places_localizer.txt']; 
% strBlockOrderList = [strRoot,'BlockOrder_face_localizer_monkey.txt'];
% strOutputFile = [strRoot,'fMRI_Standard_Localizer_Experiment.xml'];

clear all
%strExperimentTextFile = 'C:\kofiko\StimulusSet\PlaceLocalizer_1.5\experiment_place_localizer.txt';
strExperimentTextFile = 'C:\kofiko\StimulusSet\fMRI_Standard_Localizer\FaceLocalizerExperiment.txt';

%%
 fid = fopen(strExperimentTextFile);
 C = textscan(fid, '%s');
 fclose(fid);
 
[strRoot,strF,strE]= fileparts(strExperimentTextFile);
 strRoot=[strRoot,'\'];
 strImageList=C{1}{1};
 strBlockList=C{1}{2};
 strBlockOrderList=C{1}{3};
strOutputFile =  [strRoot,'\',strF,'.xml'];


[acFileNames, ~] = fnLoadMRIStyleImageList(strImageList);
acFileNamesNoPath = cell(size(acFileNames));
for k=1:length(acFileNamesNoPath)
    acFileNamesNoPath{k} = acFileNames{k};
    acFileNamesNoPath{k}(acFileNamesNoPath{k} == '\') = '_';
    acFileNamesNoPath{k}(acFileNamesNoPath{k} == ' ') = '_';
end

acFileNamesNetworkPath = strrep(acFileNames,'C:\kofiko\StimulusSet','\\10.0.0.3\StimulusSet');
[acImageIndices, acBlockNames] = fnLoadMRIStyleBlockList(strBlockList);
acBlocks= fnLoadBlockOrderListTextFile(strBlockOrderList);
iNumMedia = length(acFileNames);
iNumBlocksToDisplay = length(acBlocks);
iNumBlocks = length(acBlockNames);

% assert that there are no overlapping images in blocks. otherwise, it is
% more tricky to generate the attributes....
for i=1:iNumBlocks
    for j=i+1:iNumBlocks
        if ~isempty(intersect(acImageIndices{i},acImageIndices{j}))
            fprintf('Cannot run this automatic script because images are shared by different blocks\n');
            return;
        end
    end
end

acAttributes = cell(1,iNumMedia);
for k=1:iNumBlocks
    for j=1:length(acImageIndices{k})
       acAttributes{acImageIndices{k}(j)} = sprintf('Block%d',k);
    end
end


hFileID = fopen(strOutputFile,'w+');
fprintf(hFileID,'<Config>\n\n');
fprintf(hFileID,'     <GlobalVars>\n');
fprintf(hFileID,'         <Var Name = "NumTR"           InitialValue = "16"       Type = "Numeric" Panel = "Timing"  Description = "Num TR (TR)" > </Var>\n');
fprintf(hFileID,'         <Var Name = "ImageTimeMS"     InitialValue = "1000"      Type = "Numeric" Panel = "Timing"  Description = "Image ON time (ms)" > </Var>\n');

fprintf(hFileID,'     </GlobalVars>\n');
fprintf(hFileID,'\n\n');
fprintf(hFileID,'       <Blocks>\n');
for iBlockIter=1:iNumBlocks
		fprintf(hFileID,'               <Block Name = "%s" Attr = "Block%d" > </Block>\n',acBlockNames{iBlockIter},iBlockIter);
end
fprintf(hFileID,'    </Blocks>\n');
fprintf(hFileID,'\n\n');
fprintf(hFileID,'   <BlockOrder>\n');     
fprintf(hFileID,'        <Order Name = "Default">\n');     
for iBlockIter=1:iNumBlocksToDisplay
    fprintf(hFileID,'			<Block Name = "%s"             LengthTR = "NumTR"  > </Block>\n', acBlocks{iBlockIter});
end
fprintf(hFileID,'	    </Order>\n');     
fprintf(hFileID,'\n');     
fprintf(hFileID,'     </BlockOrder>\n');     


fprintf(hFileID,'\n\n');
fprintf(hFileID,'    <Media>\n');
for iMediaIter=1:iNumMedia

    
        fprintf(hFileID,'   <Image Name = "%s" FileName = "%s"  Attr = "%s" LengthMS = "ImageTimeMS" > </Image>\n',...
            acFileNamesNoPath{iMediaIter},    acFileNamesNetworkPath{iMediaIter},acAttributes{iMediaIter});
end
fprintf(hFileID,'    </Media>\n');

fprintf(hFileID,'</Config>\n\n');
    
fclose(hFileID);

fprintf('Converted %s to \n%s\n',strExperimentTextFile,strOutputFile);

