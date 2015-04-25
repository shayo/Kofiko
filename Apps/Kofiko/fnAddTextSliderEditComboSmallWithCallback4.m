function strctControllers = fnAddTextSliderEditComboSmallWithCallback4(strctControllers, hPanel, iCurrLinePos, ...
    strDescription, strVarName, fMinSlider, fMaxSlider, afRange, fInitialValue)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)


global g_strctParadigm

if fInitialValue < fMinSlider
    fMinSlider = fInitialValue;
end

if fInitialValue > fMaxSlider
    fMaxSlider = fInitialValue;
end


strTextVar = ['m_h',strVarName,'Text'];
strSliderVar = ['m_h',strVarName,'Slider'];
strEditVar = ['m_h',strVarName,'Edit'];
strSliderListenerVar = ['m_h', strVarName,'Listener'];
strSliderHandleForListenerVar = ['m_h', strVarName,'HandleForListener'];

Tmp= get(hPanel,'Position');
iPanelHeight = Tmp(4);
iPanelWidth = Tmp(3);

eval(['strctControllers.',strTextVar ,' = uicontrol(''Parent'',hPanel,''Style'', ''text'', ''String'', ''',strDescription,'''',...
     ',''Position'', [5 iPanelHeight-iCurrLinePos 150 20],''HorizontalAlignment'',''Left'');']);

iRange = fMaxSlider-fMinSlider;
afSliderStep = [afRange./iRange];
eval(['strctControllers.',strSliderVar ,' = uicontrol(''Parent'',hPanel,''Style'', ''slider'',  ''Min'',fMinSlider,''Max'',fMaxSlider, ''value'',fInitialValue',...
    ',''SliderStep'', afSliderStep','',...
    ',''Position'', [110 iPanelHeight-iCurrLinePos+5 iPanelWidth-165 20],''Callback'',''',...
    'global g_strctParadigm; fnStandardSliderCallback(g_strctParadigm.m_strctControllers.',strSliderVar,',',...
    'g_strctParadigm.m_strctControllers.',strEditVar,',''''',strVarName,''''');''); ']);
    
eval(['strctControllers.',strEditVar ,' = fnMyUIControlEdit(''Parent'',hPanel,''Style'', ''edit'',''String'',num2str(fInitialValue)'...
    ',''Position'', [iPanelWidth-45 iPanelHeight-iCurrLinePos+5 40 20],''Callback'',''',...
    'global g_strctParadigm; fnStandardEditCallback(g_strctParadigm.m_strctControllers.',strSliderVar,',',...
    'g_strctParadigm.m_strctControllers.',strEditVar,',''''',strVarName,''''');''); ']);
   %{ 
if  g_strctParadigm.m_iMachineState ~= 0
	jScrollBar = findjobj(eval(['strctControllers.',strTextVar ]));
	jScrollBar.AdjustmentValueChangedCallback = feval(g_strctParadigm.m_strCallbacks,strVarName);
end

g_strctParadigm.m_strCurrentGUIObject = strVarName;
strctControllers.(strSliderHandleForListenerVar) = handle(strctControllers.(strSliderVar));
%hhslider = eval(['handle([''strctControllers.''',strSliderVar'])
%eval(['strctControllers.',strSliderListenerVar,' = handle([''strctControllers.''',strSliderVar])
strctControllers.(strSliderListenerVar) = findprop(strctControllers.(strSliderHandleForListenerVar),'Value');

%strctControllers.(strSliderListenerVar) = handle.listener(strctControllers.(strSliderHandleForListenerVar), 'ActionEvent',@UpdateField);
eval(['strctControllers.(strSliderListenerVar) = handle.listener(strctControllers.(strSliderHandleForListenerVar), ''ActionEvent'',',...
    'global g_strctParadigm; fnStandardEditCallback(m_strctControllers.(strSliderVar)',...
    'm_strctControllers.(strEditVar),strVarName))']);

%eval(['strctControllers.',strSliderListenerVar ,' = handle.listener(strctControllers.(strSliderHandleForListenerVar), ''ActionEvent'','...
%    'fnStandardEditCallback(g_strctParadigm.m_strctControllers.',strSliderVar,',',...
%    'g_strctParadigm.m_strctControllers.',strEditVar,',''''',strVarName,''''');'');']);
%strctControllers.(strSliderListenerVar) = handle.listener(strctControllers.(strSliderHandleForListenerVar), 'ActionEvent',@(x) eval(['g_strctParadigm.m_strCallbacks',(strVarName)]));

%eval(['strctControllers.',strSliderListenerVar,' = handle.listener(hhSlider,hProp,'PropertyPostSet',eval(['@',g_strctParadigm.m_strCallbacks,'(',strVarName,')']));
%eval(['strctControllers.',strSliderListenerVar,' = handle.listener(hhSlider,hProp,''PropertyPostSet''',['@', eval([g_strctParadigm.m_strCallbacks,'(',strVarName,')'])]]);
%g_strctParadigm.m_strctControllers.(strSliderListenerVar) = handle.listener(g_strctParadigm.m_strctControllers.(strSliderHandleForListenerVar),g_strctParadigm.m_strctControllers.(strSliderListenerVar)...
%                                        ,'PropertyPostSet',feval(g_strctParadigm.m_strCallbacks,strVarName));
setappdata(strctControllers.(strSliderHandleForListenerVar),'sliderListener',strctControllers.(strSliderListenerVar));

g_strctParadigm.m_bGUILoaded 
if g_strctParadigm.m_bGUILoaded 
disp('triggered')
hhSlider = handle(hSlider);
hProp = findprop(hhSlider,'Value');  % a schema.prop object
hListener = handle.listener(hhSlider,hProp,'PropertyPostSet',eval(['@',g_strctParadigm.m_strCallbacks,'(',strVarName,')']));
setappdata(hSlider,'sliderListener',hListener);  % this is important - read above
end
disp('posttrigger')
%}
return;


