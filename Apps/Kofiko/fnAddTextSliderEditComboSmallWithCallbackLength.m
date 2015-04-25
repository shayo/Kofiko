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

Tmp= get(hPanel,'Position');
iPanelHeight = Tmp(4);
iPanelWidth = Tmp(3);
%{
eval(['strctControllers.',strTextVar ,' = uicontrol(''Parent'',hPanel,''Style'', ''text'', ''String'', ''',strDescription,'''',...
     ',''Position'', [5 iPanelHeight-iCurrLinePos 150 20],''HorizontalAlignment'',''Left'');']);
	 
	 %}
strctControllers.(strTextVar) = uicontrol('Parent',hPanel,'Style', 'text', 'String', strDescription,...
     'Position', [5 iPanelHeight-iCurrLinePos 150 20],'HorizontalAlignment','Left');
iRange = fMaxSlider-fMinSlider;
afSliderStep = [afRange./iRange];
strctControllers.(strSliderVar) = uicontrol('Parent',hPanel,'Style', 'slider',  'Min',fMinSlider,'Max',fMaxSlider, 'value',fInitialValue',...
    'SliderStep', afSliderStep',...
    'Position', [110 iPanelHeight-iCurrLinePos+5 iPanelWidth-165 20],'Callback',...
    global g_strctParadigm; fnStandardSliderCallback(g_strctParadigm.m_strctControllers.(strSliderVar),...
    g_strctParadigm.m_strctControllers.(strEditVar),strVarName););
%{
eval(['strctControllers.',strSliderVar ,' = uicontrol(''Parent'',hPanel,''Style'', ''slider'',  ''Min'',fMinSlider,''Max'',fMaxSlider, ''value'',fInitialValue',...
    ',''SliderStep'', afSliderStep','',...
    ',''Position'', [110 iPanelHeight-iCurrLinePos+5 iPanelWidth-165 20],''Callback'',''',...
    'global g_strctParadigm; fnStandardSliderCallback(g_strctParadigm.m_strctControllers.',strSliderVar,',',...
    'g_strctParadigm.m_strctControllers.',strEditVar,',''''',strVarName,''''');''); ']);
    %}
eval(['strctControllers.',strEditVar ,' = fnMyUIControlEdit(''Parent'',hPanel,''Style'', ''edit'',''String'',num2str(fInitialValue)'...
    ',''Position'', [iPanelWidth-45 iPanelHeight-iCurrLinePos+5 40 20],''Callback'',''',...
    'global g_strctParadigm; fnStandardEditCallback(g_strctParadigm.m_strctControllers.',strSliderVar,',',...
    'g_strctParadigm.m_strctControllers.',strEditVar,',''''',strVarName,''''');''); ']);

return;

%{
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





%}

