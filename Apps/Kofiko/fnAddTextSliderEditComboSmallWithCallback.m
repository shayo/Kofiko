function strctControllers = fnAddTextSliderEditComboSmallWithCallback(strctControllers, iCurrLinePos, ...
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

eval(['strctControllers.',strTextVar ,' = uicontrol(''Parent'',strctControllers.m_hPanel,''Style'', ''text'', ''String'', ''',strDescription,'''',...
     ',''Position'', [5 strctControllers.m_iPanelHeight-iCurrLinePos 150 20],''HorizontalAlignment'',''Left'');']);

iRange = fMaxSlider-fMinSlider;
afSliderStep = [afRange./iRange];
eval(['strctControllers.',strSliderVar ,' = uicontrol(''Parent'',strctControllers.m_hPanel,''Style'', ''slider'',  ''Min'',fMinSlider,''Max'',fMaxSlider, ''value'',fInitialValue',...
    ',''SliderStep'', afSliderStep','',...
    ',''Position'', [110 strctControllers.m_iPanelHeight-iCurrLinePos+5 strctControllers.m_iPanelWidth-165 20],''Callback'',''',...
    'global g_strctParadigm; fnStandardSliderCallback(g_strctParadigm.m_strctControllers.',strSliderVar,',',...
    'g_strctParadigm.m_strctControllers.',strEditVar,',''''',strVarName,''''');''); ']);
    
eval(['strctControllers.',strEditVar ,' = fnMyUIControlEdit(''Parent'',strctControllers.m_hPanel,''Style'', ''edit'',''String'',num2str(fInitialValue)'...
    ',''Position'', [strctControllers.m_iPanelWidth-45 strctControllers.m_iPanelHeight-iCurrLinePos+5 40 20],''Callback'',''',...
    'global g_strctParadigm; fnStandardEditCallback(g_strctParadigm.m_strctControllers.',strSliderVar,',',...
    'g_strctParadigm.m_strctControllers.',strEditVar,',''''',strVarName,''''');''); ']);
    

return;