function hHandle = fnMyUIControlEdit(varargin)
% Access undocumented java callbacks... :)

hHandle = uicontrol(varargin{:});
% 
% while (1)
%     jHandle = java(findjobj(hHandle));
%     if isempty(jHandle)
%         drawnow
%         WaitSecs(0.001);
%     else
%         break;
%     end
% end
% jbh = handle(jHandle,'CallbackProperties');
% set(jbh, 'FocusGainedCallback',{@fnFocusCallback,'Gained'});
% set(jbh, 'FocusLostCallback',{@fnFocusCallback,'Lost'});
% 
Tmp = get(hHandle,'callback');
set(hHandle,'callback', {@fnMyUIControlEditCallbackWrapper, Tmp});

return;

function fnMyUIControlEditCallbackWrapper(a,b,Tmp)
global g_handles
if ~isempty(Tmp)
    if iscell(Tmp)
        feval(Tmp{1},Tmp{2:end});
    else
        if ischar(Tmp)
            eval(Tmp);
        else
            feval(Tmp,a,b);
        end
    end
end
uicontrol(g_handles.hDummyController);
return;




