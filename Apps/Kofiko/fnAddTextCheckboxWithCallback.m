function fnAddTextCheckboxWithCallback(hPanel, iCurrLinePos,strDescription, strVarName, fInitialValue)
%
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)


global g_strctParadigm


Tmp= get(hPanel,'Position');
iPanelHeight = Tmp(4);
iPanelWidth = Tmp(3);

strTextVar = ['m_h',strVarName,'Text'];
strCheckBoxVar = ['m_h',strVarName,'CheckBox'];

eval(['g_strctParadigm.m_strctDesignRunTimeControllers.',strTextVar ,' = uicontrol(''Parent'',hPanel,''Style'', ''text'', ''String'', ''',strDescription,'''',...
     ',''Position'', [5 iPanelHeight-iCurrLinePos 150 20],''HorizontalAlignment'',''Left'');']);

eval(['g_strctParadigm.m_strctDesignRunTimeControllers.',strCheckBoxVar ,' = uicontrol(''Parent'',hPanel,''Style'', ''checkbox'',''value'',fInitialValue'...
    ',''Position'', [iPanelWidth-45 iPanelHeight-iCurrLinePos+5 40 20],''Callback'',''',...
    'global g_strctParadigm; fnStandardCheckBoxCallback(g_strctParadigm.m_strctDesignRunTimeControllers.',strCheckBoxVar,','''''...
    strVarName,''''');feval(g_strctParadigm.m_strCallbacks,''''RestartTrial'''');''); ']);
return;