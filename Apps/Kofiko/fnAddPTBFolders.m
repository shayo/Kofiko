function fnAddPTBFolders(strFolder)
if ~exist('strFolder','var')
    strFolder = '.\PublicLib\PTB\';
end
addpath([strFolder,'PsychBasic']);
addpath([strFolder,'PsychBasic\MatlabWindowsFilesR2007a']);
addpath([strFolder,'PsychOneliners']);
addpath([strFolder,'PsychRects']);
addpath([strFolder,'PsychTests']);
addpath([strFolder,'PsychPriority']);
addpath([strFolder,'PsychAlphaBlending']);
addpath([strFolder,'PsychOpenGL\MOGL\core']);
addpath([strFolder,'PsychOpenGL\MOGL\wrap']);
addpath([strFolder,'PsychGLImageProcessing']);
addpath([strFolder,'PsychOpenGL']);
addpath([strFolder,'PsychSound']);
addpath([strFolder,'PsychHardware']);

