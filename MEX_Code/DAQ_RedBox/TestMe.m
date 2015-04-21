addpath('D:\Code\Doris\Kofiko\Kofiko_Experimental\MEX\win32');
g_strctConfig.m_strctDirectories.m_strPTB_Folder = 'D:\Code\Doris\Kofiko\PublicLib\PTB\';

addpath(genpath(g_strctConfig.m_strctDirectories.m_strPTB_Folder));
addpath([g_strctConfig.m_strctDirectories.m_strPTB_Folder,'PsychBasic']);
addpath([g_strctConfig.m_strctDirectories.m_strPTB_Folder,'PsychBasic\MatlabWindowsFilesR2007a']);
addpath([g_strctConfig.m_strctDirectories.m_strPTB_Folder,'PsychOneliners']);
addpath([g_strctConfig.m_strctDirectories.m_strPTB_Folder,'PsychRects']);
addpath([g_strctConfig.m_strctDirectories.m_strPTB_Folder,'PsychTests']);
addpath([g_strctConfig.m_strctDirectories.m_strPTB_Folder,'PsychPriority']);
addpath([g_strctConfig.m_strctDirectories.m_strPTB_Folder,'PsychAlphaBlending']);
addpath([g_strctConfig.m_strctDirectories.m_strPTB_Folder,'PsychOpenGL\MOGL\core']);
addpath([g_strctConfig.m_strctDirectories.m_strPTB_Folder,'PsychOpenGL\MOGL\wrap']);
addpath([g_strctConfig.m_strctDirectories.m_strPTB_Folder,'PsychGLImageProcessing']);
addpath([g_strctConfig.m_strctDirectories.m_strPTB_Folder,'PsychOpenGL']);


Res = fnDAQRedBox('Init');
% 0.01ms to get status
% 8 ms to set digital value
% 16 ms to read analog value

tic
z = zeros(1,1000);
for k=1:1000
    x= GetSecs();
    fnDAQRedBox('SetBit',0,mod(k,255));
    y = GetSecs();
    z(k) = (y-x) * 1e3;
    
end
fprintf('GetStatus takes %.2f ms\n',toc/1000*1e3);


tic
for k=1:1000
    fnDAQRedBox('SetBit',0,mod(k,2));
end
fprintf('SetBit takes %.2f ms\n',toc/1000*1e3);



tic
for k=1:1000
    A=fnDAQRedBox('GetAnalog',0);
end
fprintf('GetAnalog takes %.2f ms\n',toc/1000*1e3);


