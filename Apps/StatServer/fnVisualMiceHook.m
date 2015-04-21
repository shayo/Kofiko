function fnVisualMiceHook(bInit)
global g_bPlot
if bInit
    fndllMiceHook('Init');
end
iNumMice = fndllMiceHook('GetNumMice');
hFigure = figure;
set(hFigure,'CloseRequestFcn',@fnCloseVisualMiceHook,'Name','Move mice advancers to see which one is which...');
clf;
g_bPlot = 1;
N = 100;
a2fHistory = zeros(iNumMice,N);
iCounter = 1;
acNames = cell(1,iNumMice);
for k=1:iNumMice
    acNames{k} = sprintf('Advancer %d',k);
end;

while (g_bPlot)
    aiWheels = fndllMiceHook('GetWheels',0:iNumMice-1);
    a2fHistory(:,iCounter) = aiWheels;
    iCounter = iCounter + 1;
    if iCounter > N
        iCounter = 1;
    end
        
    plot(a2fHistory');
    legend(acNames);
    drawnow 
    A=GetSecs();
    while (1)
        B=GetSecs();
        if B-A > 0.05
            break;
        end
    end
end
if bInit
    fndllMiceHook('Release');
end
return;

function fnCloseVisualMiceHook(a,b)
global g_bPlot
g_bPlot = 0;
if ~isempty(gcbf)
   delete(gcbf);
end
