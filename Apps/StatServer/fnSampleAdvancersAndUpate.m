function aiCurrentAdvancerReadOut=fnSampleAdvancersAndUpate()
global g_strctCycle  g_strctNeuralServer g_strctWindows g_strctConfig
% Advancers
iNumMice = length(g_strctCycle.m_afAdvancerPrevReadOut);
aiCurrentAdvancerReadOut = fndllMiceHook('GetWheels',0:iNumMice-1);
if ~isempty(aiCurrentAdvancerReadOut) && length(aiCurrentAdvancerReadOut) ~= length(g_strctCycle.m_afAdvancerPrevReadOut)
   h=errordlg({'CRITICAL ERROR OCCURRED!. Number of advancers has changed!','Must shutdown now!'},'ERROR'); 
   waitfor(h);
   fnCloseStatServer();
   return;
end

if iNumMice > 0 && ~isempty(aiCurrentAdvancerReadOut) && sum(aiCurrentAdvancerReadOut ~= g_strctCycle.m_afAdvancerPrevReadOut) > 0
    
    aiChangedAdvanvers = find(aiCurrentAdvancerReadOut ~= g_strctCycle.m_afAdvancerPrevReadOut);
    for k=1:length(aiChangedAdvanvers)
        iAdvancerIndex = aiChangedAdvanvers(k);
        % Only register advancers that are used.....
        if sum(g_strctNeuralServer.m_aiUsedAdvancers == iAdvancerIndex) > 0
            fCurrDepthMM = g_strctNeuralServer.m_afAdvancerOffsetMM(iAdvancerIndex) + aiCurrentAdvancerReadOut(iAdvancerIndex) / g_strctConfig.m_strctAdvancers.m_fMouseWheelToMM;
            fnStatServerCallbacks('UpdateAdvancer',iAdvancerIndex,fCurrDepthMM );
        end
    end
    
    g_strctCycle.m_afAdvancerPrevReadOut = aiCurrentAdvancerReadOut;
    fnUpdateAdvancerText();
end
