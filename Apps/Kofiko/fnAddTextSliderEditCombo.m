function strctControllers = fnAddTextSliderEditCombo(strctControllers, iCurrLinePos, ...
    strDescription, strVarName,iPanelHeight,iPanelWidth, fMinSlider, fMaxSlider, afRange, fInitialValue)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)

global g_strctParadigm
strTextVar = ['m_h',strVarName,'Text'];
strSliderVar = ['m_h',strVarName,'Slider'];
strEditVar = ['m_h',strVarName,'Edit'];

eval(['strctControllers.',strTextVar ,' = uicontrol(''Parent'',strctControllers.m_hPanel,''Style'', ''text'', ''String'', ''',strDescription,'''',...
     ',''Position'', [5 iPanelHeight-iCurrLinePos 150 20],''HorizontalAlignment'',''Left'');']);

iRange = fMaxSlider-fMinSlider;
afSliderStep = [afRange./iRange];
eval(['strctControllers.',strSliderVar ,' = uicontrol(''Parent'',strctControllers.m_hPanel,''Style'', ''slider'',  ''Min'',fMinSlider,''Max'',fMaxSlider, ''value'',fInitialValue',...
    ',''SliderStep'', afSliderStep','',...
    ',''Position'', [5 iPanelHeight-iCurrLinePos-15 iPanelWidth-60 20],''Callback'',''',g_strctParadigm.m_strCallbacks,'(''''', strVarName,'Slider'''');'');']);

eval(['strctControllers.',strEditVar ,' = fnMyUIControlEdit(''Parent'',strctControllers.m_hPanel,''Style'', ''edit'',''String'',num2str(fInitialValue)'...
    ',''Position'', [iPanelWidth-50 iPanelHeight-iCurrLinePos-15 40 20],''Callback'',''',g_strctParadigm.m_strCallbacks,'(''''', strVarName,'Edit'''');'');'])

return;