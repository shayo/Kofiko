function fnResumeStatServerFromCrash()
global g_bAppIsRunning
drawnow
g_bAppIsRunning = true;
while (g_bAppIsRunning)
    fnStatServerCycle();
end;

fnCloseStatServer();

return;
