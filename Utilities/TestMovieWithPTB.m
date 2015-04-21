
g_strctAppConfig.m_strctDirectories.m_strPTB_Folder = 'C:\Shay\Code\PublicLib\PTB\';

addpath([g_strctAppConfig.m_strctDirectories.m_strPTB_Folder,'PsychBasic']);
addpath([g_strctAppConfig.m_strctDirectories.m_strPTB_Folder,'PsychBasic\MatlabWindowsFilesR2007a']);
addpath([g_strctAppConfig.m_strctDirectories.m_strPTB_Folder,'PsychOneliners']);
addpath([g_strctAppConfig.m_strctDirectories.m_strPTB_Folder,'PsychRects']);
addpath([g_strctAppConfig.m_strctDirectories.m_strPTB_Folder,'PsychTests']);
addpath([g_strctAppConfig.m_strctDirectories.m_strPTB_Folder,'PsychPriority']);
addpath([g_strctAppConfig.m_strctDirectories.m_strPTB_Folder,'PsychAlphaBlending']);
addpath([g_strctAppConfig.m_strctDirectories.m_strPTB_Folder,'PsychOpenGL\MOGL\core']);
addpath([g_strctAppConfig.m_strctDirectories.m_strPTB_Folder,'PsychOpenGL\MOGL\wrap']);
addpath([g_strctAppConfig.m_strctDirectories.m_strPTB_Folder,'PsychGLImageProcessing']);
addpath([g_strctAppConfig.m_strctDirectories.m_strPTB_Folder,'PsychOpenGL']);

[hPTBWindow, aiScreenRect] = Screen(    'OpenWindow',2,[0 0 0]);

strMovie = '\\192.168.50.93\StimulusSet\head_gaze_movies\Nicole\MJPEG\02_Nicole_front-down.avi';

[hMovie,fDuration,fFramesPerSeconds,iWidth,iHeight]=Screen('OpenMovie', hPTBWindow, strMovie);



Screen('PlayMovie', hMovie, 1,0,1);
Screen('SetMovieTimeIndex',hMovie,0);

while 1
    [hFrameTexture, fTimeToFlip] = Screen('GetMovieImage', hPTBWindow, hMovie,1);
    if hFrameTexture < 0
        break;
    end
    Screen('DrawTexture', hPTBWindow, hFrameTexture);
   fCueOnsetTS = Screen('Flip',hPTBWindow); % This would block the server until the next flip.
   Screen('Close', hFrameTexture);
end

     