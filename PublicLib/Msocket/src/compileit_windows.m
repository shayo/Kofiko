% Note: this only works in windows
% Run mex -setup first, and select the C compiler to
% be the Microsoft compiler

% This needs to be changed to the approproate directory
libdir = ...
  'c:\\MATLAB\R2011b_x64\\extern\\lib\\win64\\microsoft'



files = {'udp_msconnect.c',...
  'udp_msaccept.c',...
  'udp_mslisten.c',...
  'udp_msclose.c',...
  'udp_mssendraw.c',...
  'udp_mssendraw_mod.cpp',...
    'udp_msrecvraw_mod.c',...
  'udp_msrecvraw.c'  };

% Create libraries for above files
for i1=1:length(files)
  cmd=sprintf('mex -I.  -L"%s" %s ws2_32.lib',...
    libdir,files{i1});
  cmd
  eval(cmd);
end

% Compile object code
mex -I. -DWIN32 -c matvar.cpp
mex -I. -DWIN32 -c udp_msrecv.cpp
mex -I. -DWIN32 -c udp_mssend.cpp
mex -I. -DWIN32 -c mscheckbuf.cpp

cmd = sprintf('mex -I. -DWIN32 udp_msrecv.obj matvar.obj ws2_32.lib -L"%s"',libdir);
cmd
eval(cmd);


cmd = sprintf('mex -I. -DWIN32 mscheckbuf.obj matvar.obj ws2_32.lib -L"%s"',libdir);
cmd
eval(cmd);

cmd = sprintf('mex -I. -DWIN32 udp_mssend.obj matvar.obj ws2_32.lib -L"%s"',libdir);
cmd
eval(cmd);

system('del *.obj');
system('move *.mexw32 ..');
