function fnCompileWorker()
% Compile using deployed project file...

strMatlab32Path = 'C:\MATLAB\R2009b_x32\';
strProjectFile = [pwd(),'CompiledWorker\DeployedProject.prj'];
stMainFile = [pwd(),'AnalysisScripts\Distributed\fnWorker.m'];
strOutputFolder = [pwd(),'CompiledWorker\'];
strIntermediateFolder = [pwd(),'CompiledWorker\'];
strOutputFileName = 'Worker';

acFilesM = fnGetAllFilesRecursive(pwd, '.m');
acFilesMAT = fnGetAllFilesRecursive(pwd, '.mat');
acFilesMEX = fnGetAllFilesRecursive(pwd, '.mexw32');
acstrFiles = [acFilesM,acFilesMAT,acFilesMEX];


% Path Initialization...
%strPipelinePath = genpath([g_strMainDirectory,'Code\Modules\']);
%addpath(strPipelinePath);
strPath = genpath(pwd());
if strPath(end) ~= ';'
    strPath(end+1) = ';';
end;
aiSep = find(strPath==';');
acStrPaths = cell(1,length(aiSep)-1);
q = 1;
for k=1:length(aiSep)-1
    if isempty(strfind(strPath(aiSep(k)+1:aiSep(k+1)-1),'.svn'))
        acStrPaths{q} = strPath(aiSep(k)+1:aiSep(k+1)-1);
        q=q+1;
    end
end;
acStrPaths=acStrPaths(1:q-1);
fnGenerateDeployProjectFile(strProjectFile,stMainFile, strOutputFolder,strOutputFileName, strIntermediateFolder,acStrPaths,acstrFiles);
tic
fprintf('Compiling Worker...\n');
eval(['!',strMatlab32Path,'bin\win32\mcc.exe -F ',strProjectFile]);
%mcc -m '.\AnalysisScripts\Distributed\fnWorker.m' -d '.\CompiledWorker\'
fTime = toc;
fprintf('Finished compiling worker in %.2f sec!\n',fTime);

return;

% 
% cd('CompiledWorker');
% eval('!condor_submit submit_to_condor_script.txt');
% cd('..');
% 
% fnWorker('C:\Shay\Data\Jobs\100802_131956\100728_155012_Houdini_IN_0.mat',...
%          'C:\Shay\Data\Jobs\100802_131956\100728_155012_Houdini_LOG_0.txt',...
%         'C:\Shay\Data\Jobs\100802_131956\100728_155012_Houdini_OUT_0.mat');