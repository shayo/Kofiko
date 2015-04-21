% Fix Kofiko File
strKofikoFile = 'C:\Data\Data\Doris\Electrophys\Houdini\GaussianProcess_Project\Sessions\100805\100805_120956_Houdini.mat';
load(strKofikoFile);
%% Fix Here
g_astrctAllParadigms{3}.ImageList.Buffer{2} = '\\Kofiko-23B\StimulusSet\Monkey_Bodyparts\StandardFOB_v2_sweep.txt';
g_astrctAllParadigms{3}.ImageList.Buffer{4} = '\\Kofiko-23B\StimulusSet\Monkey_Bodyparts\StandardFOB_v2_sweep.txt';

%%
save([strKofikoFile,'.Fix'],'g_astrctAllParadigms','g_strctAppConfig','g_strctDAQParams','g_strctEyeCalib','g_strctLog','g_strctStimulusServer','g_strctSystemCodes');
