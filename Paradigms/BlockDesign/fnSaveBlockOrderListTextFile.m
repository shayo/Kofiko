function fnSaveBlockOrderListTextFile(strFile, acBlocks)
hFileID= fopen(strFile,'wb+');
for k=1:length(acBlocks);
    fprintf(hFileID,'%s\r\n',acBlocks{k});
end

fclose(hFileID);
return;
