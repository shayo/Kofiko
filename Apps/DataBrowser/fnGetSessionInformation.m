function [bValid,strctInfo] = fnGetSessionInformation(strKofikoFullFilename)
strctKofiko = load(strKofikoFullFilename);
bValid = true;
strctInfo = [];
if ~isfield(strctKofiko,'g_strctDAQParams') || ~isfield(strctKofiko,'g_strctAppConfig')
    bValid = false;
    return;
end

% Which paradigms were used?
if ~isfield(strctKofiko.g_strctAppConfig,'ParadigmSwitch')
    acstrParadigmNames = fnCellStructToArray(strctKofiko.g_astrctAllParadigms,'m_strName');
else
    acstrParadigmNames = strctKofiko.g_strctAppConfig.ParadigmSwitch.Buffer;
end
if isempty(acstrParadigmNames{1})
    acstrParadigmNames =acstrParadigmNames(2:end);
end

strctInfo.m_strKofikoFullFilename = strKofikoFullFilename;
strctInfo.m_strSubject = strctKofiko.g_strctAppConfig.m_strctSubject.m_strName;
strctInfo.m_strTimeDate = strctKofiko.g_strctAppConfig.m_strTimeDate;
strctInfo.m_acParadigms = unique(acstrParadigmNames);

% Electrophysiology information available?
strctInfo.m_iNumRecordedFrames = sum(strctKofiko.g_strctDAQParams.LastStrobe.Buffer == strctKofiko.g_strctSystemCodes.m_iStartRecord);

[strPath,strSession] = fileparts(strKofikoFullFilename);
astrctChannels = dir([strPath,filesep,strSession,'*spikes_ch*.raw']);
strctInfo.m_iNumRecordedChannels = length(astrctChannels);


% Target information ?
strStatServerInfo =  fullfile(strPath,[strSession,'-StatServerInfo.mat']);
if exist( strStatServerInfo,'file')
    strctStatServer = load(strStatServerInfo);
    
    iNumChannels = length(strctStatServer.g_strctNeuralServer.m_aiActiveSpikeChannels);
    % Extract the information per channel
    iCounter=1;
    for iCh=1:iNumChannels
        strctChannel.m_iChannel = strctStatServer.g_strctNeuralServer.m_aiActiveSpikeChannels(iCh);
        iGridIndex = strctStatServer.g_strctNeuralServer.m_a2iChannelToGridHoleAdvancer(strctChannel.m_iChannel,1);
        if ~isnan(iGridIndex)
            iHoleIndex = strctStatServer.g_strctNeuralServer.m_a2iChannelToGridHoleAdvancer(strctChannel.m_iChannel,2);
            
            
            if isfield(strctStatServer.g_strctNeuralServer.m_acGrids{iGridIndex},'m_strctModel')
                strctChannel.m_strGridModelName = strctStatServer.g_strctNeuralServer.m_acGrids{iGridIndex}.m_strModelName;
                strctChannel.m_fCenterOffsetX = strctStatServer.g_strctNeuralServer.m_acGrids{iGridIndex}.m_strctModel.m_aiLocX(iHoleIndex);
                strctChannel.m_fCenterOffsetY = strctStatServer.g_strctNeuralServer.m_acGrids{iGridIndex}.m_strctModel.m_aiLocY(iHoleIndex);
                strctChannel.m_strTargetName = strctStatServer.g_strctNeuralServer.m_acGrids{iGridIndex}.m_strctModel.m_strctGridParams.m_astrctHoleInformation(iHoleIndex).m_strTargetName;
                strctChannel.m_strElectrodeType = strctStatServer.g_strctNeuralServer.m_acGrids{iGridIndex}.m_strctModel.m_strctGridParams.m_astrctHoleInformation(iHoleIndex).m_strElectrodeType;
            else
                strctChannel.m_strGridModelName = strctStatServer.g_strctNeuralServer.m_acGrids{iGridIndex}.m_strName;
                strctChannel.m_fCenterOffsetX = strctStatServer.g_strctNeuralServer.m_acGrids{iGridIndex}.m_afGridHolesX(iHoleIndex);
                strctChannel.m_fCenterOffsetY = strctStatServer.g_strctNeuralServer.m_acGrids{iGridIndex}.m_afGridHolesY(iHoleIndex);
                strctChannel.m_strTargetName = strctStatServer.g_strctNeuralServer.m_acGrids{iGridIndex}.m_strctGridParams.m_astrctHoleInformation(iHoleIndex).m_strTargetName;
                strctChannel.m_strElectrodeType = strctStatServer.g_strctNeuralServer.m_acGrids{iGridIndex}.m_strctGridParams.m_astrctHoleInformation(iHoleIndex).m_strElectrodeType;
                
            end
            
            strctInfo.m_strctRecordingInfo.m_astrctChannels(iCounter) = strctChannel;
            iCounter=iCounter+1;
        end
    end
    strctInfo.m_strctRecordingInfo.m_strctNeuralServer= strctStatServer.g_strctNeuralServer;
    
else
    strctInfo.m_strctRecordingInfo = [];
end

return;
