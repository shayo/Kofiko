function astrctRuns = fnParseKofiko(strInputFolder,strParams)
if ~exist('strInputFolder','var') || isempty(strInputFolder)
    fprintf('usage: parsekofiko [foldername] [--force]\n');
    return;
end;

bForce = exist('strParams','var') && strcmpi(strParams,'--force');
strParsedFile = [strInputFolder,'/RecordedRuns.mat'];

if ~exist(strParsedFile,'file') || bForce
    astrctRuns = fnExtractRunInformation(strInputFolder);
    fprintf('-----------------------------------------\n');
    fprintf('saving output to %s\n',strParsedFile);
    save(strParsedFile,'astrctRuns');
else
    fprintf('%s exists. exitting\n',strParsedFile);
end

return;

