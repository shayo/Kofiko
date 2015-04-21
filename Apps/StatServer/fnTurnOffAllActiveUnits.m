function fnTurnOffAllActiveUnits(bAsk)
global g_strctNeuralServer
if ~isempty(g_strctNeuralServer) && isfield(g_strctNeuralServer,'m_a2iCurrentActiveUnits') && sum(g_strctNeuralServer.m_a2iCurrentActiveUnits(:)>0) > 0
    if bAsk
        strAnswer=questdlg('You are about to close, but some units are still active. Do you want to inactivate them?','Warning!','Yes','No','Yes');
    else
        strAnswer = 'Yes';
    end
    
    if ~strcmpi(strAnswer,'No')
        aiInd = find(g_strctNeuralServer.m_a2iCurrentActiveUnits>0);
        [aiChannel,aiUnit] = ind2sub(size(g_strctNeuralServer.m_a2iCurrentActiveUnits),aiInd);
        for k=1:length(aiInd)
            fnStatServerCallbacks('ToggleActive',aiChannel(k),aiUnit(k));
        end
    end
end

return;
