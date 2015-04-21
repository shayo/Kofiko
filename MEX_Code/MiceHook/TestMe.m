addpath('D:\Code\Doris\Kofiko\Kofiko_Experimental\MEX\win32');
fndllMiceHook('Init');

g_strctAppConfig.m_strctDirectories.m_strPTB_Folder = 'D:\Code\Doris\Kofiko\PublicLib\PTB\';
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

%%
B = 0;
T = 0;
Px = 0;
Py =0;
while(1)
    [fEyeXPix, fEyeYPix] = GetMouse(2);
     A= fndllMiceHook('GetButtons',0);
     C= fndllMiceHook('GetMouseData',0);
  
    if A(1) || Px~=fEyeXPix || Py ~= fEyeYPix
        B = 1;
        T = GetSecs();
        Px = fEyeXPix;
        Py = fEyeYPix;
    end;
    if GetSecs()-T > 2
        B = 0;
    end
    %[ A,fEyeXPix, fEyeYPix,rand(),Px,Py,B]
    [C(1)+768 ./   fEyeXPix,C(2) ./   fEyeYPix, C(1) ./   fEyeYPix,C(2) ./   fEyeXPix]
    
end

%%
figure(1);
clf;
while (1)
        [fEyeXPix, fEyeYPix] = GetMouse(2);

     A=fndllMiceHook('GetButtons',0);
   if A(1)
       plot(fEyeXPix,fEyeYPix,'g*','MarkerSize',30);
       wavplay(rand(1,1000)*1000,40000,'async')
   else
       plot(fEyeXPix,fEyeYPix,'ro','MarkerSize',30);
   end
   axis([-1024 1024 -1024 1024]);
   drawnow
end



%fndllMiceHook('Release');

% 0) \\?\HID#VID_04E7&PID_0020&Col03#6&ed0c983&2&0002#{378de44c-56ef-11d1-bc8c-00a0c91405dd}
% 1) \\?\HID#VID_04E7&PID_0020&Col01#6&ed0c983&2&0000#{4d1e55b2-f16f-11cf-88cb-001111000030}
% 2) \\?\HID#VID_09DB&PID_007A#6&29433ae8&0&0000#{4d1e55b2-f16f-11cf-88cb-001111000030}
% 3) \\?\HID#VID_046D&PID_C526&MI_01&Col03#7&1c92dce0&0&0002#{4d1e55b2-f16f-11cf-88cb-001111000030}
% 4) \\?\HID#VID_046D&PID_C526&MI_01&Col02#7&1c92dce0&0&0001#{4d1e55b2-f16f-11cf-88cb-001111000030}
% 5) \\?\HID#VID_046D&PID_C526&MI_01&Col01#7&1c92dce0&0&0000#{4d1e55b2-f16f-11cf-88cb-001111000030}
% 8) \\?\Root#RDP_MOU#0000#{378de44c-56ef-11d1-bc8c-00a0c91405dd}
% 9) \\?\HID#VID_046D&PID_C526&MI_00#7&4cf509b&0&0000#{378de44c-56ef-11d1-bc8c-00a0c91405dd}
% 10) \\?\ACPI#IBM3780#4&2b110597&0#{378de44c-56ef-11d1-bc8c-00a0c91405dd}

% 0) \\?\HID#VID_04E7&PID_0020&Col03#6&ed0c983&2&0002#{378de44c-56ef-11d1-bc8c-00a0c91405dd}
% 1) \\?\HID#VID_04E7&PID_0020&Col01#6&ed0c983&2&0000#{4d1e55b2-f16f-11cf-88cb-001111000030}

