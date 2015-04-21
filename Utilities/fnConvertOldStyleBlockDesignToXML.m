strRoot = 'D:\Courses\Caltech\Bi184 (The primate visual system)\2013 StudentsStimuli\Symmetry\';

strImageList = [strRoot,'ExperimentImages.txt'];
strBlockList = [strRoot,'BlockDescription.txt']; 
strBlockOrderList = [strRoot,'BlockOrder.txt'];

strOutputFile = [strRoot,'SymmetryExperiment.xml'];


[acFileNames, acFileNamesNoPath] = fnLoadMRIStyleImageList(strImageList);

acFileNamesNetworkPath = strrep(acFileNames,'D:\Courses\Caltech','\\10.0.0.3\StimuliSet');
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
fprintf(hFileID,'         <Var Name = "NumTR"           InitialValue = "16"       Type = "Numeric" Panel = "Timing"  Description = "Num TR Rest (TR)" > </Var>\n');
fprintf(hFileID,'         <Var Name = "ImageTimeMS"     InitialValue = "500"      Type = "Numeric" Panel = "Timing"  Description = "Image ON time (ms)" > </Var>\n');

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
