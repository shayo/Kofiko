%exit script template
%TODO:
%update folder paths and I.P at #000001 and #000002

function fnStatServerExitScript_Rig23B(strSession, strSubject)
% Runs when you close stat server....
% Session is of the format 110831_141933
iSep = find(strSession == '_');
strDate = strSession(1:iSep-1);

%% #000001
strStatServerLogFolder = 'C:\Default\';
strPlexonLogFolder = ['\\plexon-23b\Shay\',strSubject,'\'];
strKofikoLogFolder = '\\192.168.50.93\Logs\';

%#000002
strDestinationDataFolder = ['D:\Data\Doris\Electrophys\',strSubject,'\Sinha_Controls_Project\',strDate,'\RAW\'];
%%

% make a new folder at the destination
if ~exist(strDestinationDataFolder,'dir')
    mkdir(strDestinationDataFolder);
end;

fprintf('Copying stuff to %s\n',strDestinationDataFolder);

% Copy Stat Serv log file...
strStatServerLogFile = [strStatServerLogFolder,strSession,'_',strSubject,'-StatServerInfo.mat'];
strAdvancersFile = [strStatServerLogFolder,strSession,'_',strSubject,'-Advancers.txt'];
strActiveUnitsFile= [strStatServerLogFolder,strSession,'_',strSubject,'-ActiveUnits.txt'];
% Copy Plexon file...
strPlexonFile = [strPlexonLogFolder,strSession,'_',strSubject,'.plx'];
% Copy Kofiko file...
strKofikoFile = [strKofikoLogFolder,strSession,'_',strSubject,'.mat'];
strKofikoTextLogFile = [strKofikoLogFolder,strSession,'_',strSubject,'.txt'];

acFilesToCopy = {strStatServerLogFile,strAdvancersFile,strActiveUnitsFile,strPlexonFile,strKofikoFile,strKofikoTextLogFile};
for iFileIter=1:length(acFilesToCopy)
    fprintf('Trying to copy file %s...',acFilesToCopy{iFileIter});
    if exist(acFilesToCopy{iFileIter},'file')
        copyfile(acFilesToCopy{iFileIter},strDestinationDataFolder);
        fprintf('Done!\n');
    else
        fprintf('Cannot find file %s\n',acFilesToCopy{iFileIter});
    end
end

%% Running PLX_To_Kofiko...
strPlexonFileAtDest = [strDestinationDataFolder,strSession,'_',strSubject,'.plx'];
strctOptions.m_bSpikes = true;
strctOptions.m_bAnalog = true;
strctOptions.m_bStrobe = true;
strctOptions.m_bSync= true;

fnConvertPLXtoFastDataAccess(strPlexonFileAtDest,strctOptions,[]);

%% Run Spike Sorting...
SpikeSorter(strDestinationDataFolder)

%% Update Data Browser ?

