function fnTransferNeuralDataToBuffer()
global g_strctNeuralServer g_strctCycle g_counter

PL_WaitForServer(g_strctNeuralServer.m_hSocket, 100);


[NumSpikeAndStrobeEvents, a2fSpikeAndEvents, a2fWaveForms] =PL_GetWFEvs(g_strctNeuralServer.m_hSocket); % PL_GetWFEvs,PL_GetTS
%assert( size(a2fSpikeAndEvents,1) ==size(a2fWaveForms,1))

% a2fSpikeAndEvents is a t - n by 4 matrix, timestamp info:
%       t(:, 1) - timestamp type (1 - neuron, 4 - external event)
%       t(:, 2) - channel numbers
%       t(:, 3) - unit numbers
%       t(:, 4) - timestamps in seconds


if NumSpikeAndStrobeEvents == 0
    a2fSpikeAndEvents = zeros(0, g_strctNeuralServer.m_iNumberUnitsPerChannel);
    a2fWaveForms = zeros(0,g_strctNeuralServer.m_fNumPointsInWaveform );
else
    abStrobes = a2fSpikeAndEvents(:,1) == 4;
    a2fSpikeAndEvents(abStrobes,3) = a2fSpikeAndEvents(abStrobes,3) + 32768;
    
%     MaxCh = max(a2fSpikeAndEvents(~abStrobes,2));
%     MaxUnit = max(a2fSpikeAndEvents(~abStrobes,3));
%     
%     if ~isempty(MaxCh) && ~isempty(MaxUnit) && (MaxCh >  ||  MaxUnit > g_strctNeuralServer.m_iNumActiveSpikeChannels) && ~g_strctCycle.m_strctWarnings.m_bUnidentifiedChannel
%         fnStatCriticalLog('Ch %d or Unit %d above allocation?!?!?!',MaxCh,MaxUnit);
%         g_strctCycle.m_strctWarnings.m_bUnidentifiedChannel = true;
%     end
    
end
[NumAnalog, afAnalogTime, a2fLFP] = PL_GetADVEx(g_strctNeuralServer.m_hSocket);
NumActiveChannels = g_strctNeuralServer.m_iNumActiveSpikeChannels;


if NumAnalog(1) == 0
    a2fLFP = zeros(0, NumActiveChannels);
else
    a2fLFP = a2fLFP(:,g_strctNeuralServer.m_aiSpikeToAnalogMapping);
    afAnalogTime =afAnalogTime(1);%g_strctNeuralServer.m_aiSpikeToAnalogMapping);
    
end;

% fnStatLog('Packet query time %.2f ms ', (fTimer2-fTimer1)*1e3 );

if NumSpikeAndStrobeEvents > 0
    iNumTrials = sum(a2fSpikeAndEvents(abStrobes,3) ==  g_strctCycle.m_strctTrialBufferOpt.TrialStartCode);
    if iNumTrials > 0
        g_strctCycle.m_iTrialCounter =g_strctCycle.m_iTrialCounter + iNumTrials;
        if iNumTrials > 1
            fnStatLog('Packet received with %d trials [%d]', iNumTrials,g_strctCycle.m_iTrialCounter );
        else
            aiTrialType = find(a2fSpikeAndEvents(:,3) > 0 & a2fSpikeAndEvents(:,3) < 30000 & a2fSpikeAndEvents(:,1) == 4);
            if ~isempty(aiTrialType) && length(aiTrialType) == 1
                fnStatLog('Packet received with trial type %d [%d]', a2fSpikeAndEvents(aiTrialType,3),g_strctCycle.m_iTrialCounter );
            else
                fnStatLog('Packet received with %d trials [%d]', iNumTrials,g_strctCycle.m_iTrialCounter );
            end
        end
    end
end


if NumAnalog(1) > 0 || NumSpikeAndStrobeEvents > 0
    
    %Opt = g_strctCycle.m_strctTrialBufferOpt;
    %g_DebugDataLog = [g_DebugDataLog; {a2fSpikeAndEvents, a2fLFP,afAnalogTime,a2fWaveForms}];
    
    
    %         save('DebugTrialStatLong','a2fSpikeAndEvents','a2fLFP','afAnalogTime','Opt','g_DebugDataLog');
    
    TrialCircularBuffer('UpdatePlexon', a2fSpikeAndEvents, a2fLFP, afAnalogTime,a2fWaveForms);
    
    g_counter=g_counter+1;
    %         if g_strctCycle.m_iTrialCounter > 15000
    %          save('DebugTrialStatLong','a2fSpikeAndEvents','a2fLFP','afAnalogTime','Opt','g_DebugDataLog');
    %
    %             dbg = 1;
    %          save('D:\DebugTrialStatLong','a2fSpikeAndEvents','a2fLFP','afAnalogTime','Opt','g_DebugDataLog');
    %
    %
    %         end
    %         g_DebugDataLog = [g_DebugDataLog; {a2fSpikeAndEvents, a2fLFP(:,1:NumActiveChannels),afAnalogTime}];
    %         if g_counter > 100
    %             Opt = g_strctCycle.m_strctTrialBufferOpt;
    %             save('DebugTrialStat2','a2fSpikeAndEvents','a2fLFP','afAnalogTime','Opt','g_DebugDataLog');
    %         end
end





return;

global g_strctCycle g_strctNeuralServer
fCurrTime = GetSecs();

if ~g_strctCycle.m_bConditionInfoAvail
    % We have no idea how trials are run...
    % just sample spikes and LFP every 1 second
    
    if fCurrTime-g_strctNeuralServer.m_fLastSampleTS > 1
        g_strctNeuralServer.m_fLastSampleTS = fCurrTime;
        % Now sample (!)
        
        switch g_strctConfig.m_strctNeuralServer.m_strType
            case 'PLEXON'
                [n, t] =PL_GetTS(g_strctNeuralServer.m_hSocket);
                [n1, t1, d1] = PL_GetADVEx(g_strctNeuralServer.m_hSocket);
            case 'BLACKROCK'
                [spike_data, data_start_time, lfp_data] = cbmex('trialdata', 1);
                assert(false);
                % This needs to be changed to make it compatible with
                % blackrock.
        end
        
        iTrialCounter = g_strctNeuralServer.m_strctBuffer.m_iTrialCounter;
        
        g_strctNeuralServer.m_strctBuffer.m_afTrialStartTS(iTrialCounter) = t1(1);
        
        % Output:
        %   n - 1 by 1 matrix, number of timestamps retrieved
        %   t - n by 4 matrix, timestamp info:
        %       t(:, 1) - timestamp types (1 - neuron, 4 - external event)
        %       t(:, 2) - channel numbers ( =257 for strobed ext events )
        %       t(:, 3) - unit numbers ( strobe value for strobed ext events )
        %       t(:, 4) - timestamps in seconds
        
        % Distribute spikes ....
        abSpikeEntries = t(:,1) == 1;
        iTrialBufferLength = size( g_strctNeuralServer.m_strctBuffer.m_a4fSpikeTS_Buffer,1);
        
        a2fActualSpikes = t(abSpikeEntries,:);
        
        g_strctNeuralServer.m_strctBuffer.m_aiTrialType(iTrialCounter) = 0; % No trial type....
        
        fSpikeAlignTS = g_strctNeuralServer.m_strctBuffer.m_afTrialStartTS(iTrialCounter);
        
        fSpikeTrialBufferLength = size( g_strctNeuralServer.m_strctBuffer.m_a4fSpikeTS_Buffer,4);
        for iChannelIter=1:g_strctNeuralServer.m_iNumActiveSpikeChannels
            for iUnitIter=1:g_strctNeuralServer.m_iNumberUnitsPerChannel
                afSpikes = a2fActualSpikes((a2fActualSpikes(:,2) == iChannelIter & a2fActualSpikes(:,3) == iUnitIter),4);
                iMaxUpdateLength = min( length(afSpikes), fSpikeTrialBufferLength);
                g_strctNeuralServer.m_strctBuffer.m_a4fSpikeTS_Buffer(iTrialCounter, iChannelIter, iUnitIter, :) = NaN;
                g_strctNeuralServer.m_strctBuffer.m_a4fSpikeTS_Buffer(iTrialCounter, iChannelIter, iUnitIter, 1:iMaxUpdateLength) = afSpikes(1:iMaxUpdateLength)-fSpikeAlignTS;
                
            end
        end
        g_strctNeuralServer.m_strctBuffer.m_a2iSpikes_NumValidSamples =  min(g_strctNeuralServer.m_strctBuffer.m_a2iSpikes_NumValidSamples + 1,iTrialBufferLength-1);
        
        % Update A/D
        %
        % Output:
        %   n - m by 1 matrix, where m is the total number of enabled A/D channels,
        %		number of data points retrieved (for each channel),
        %   t - m by 1 matrix, timestamp of the first data point for each enabled channel (in seconds)
        %   d - n by nch matrix, where nch is the number of enabled A/D channels,
        %       continuous A/D channel sample data:
        %         d(:, 1) - a/d values for the first enabled channel, in volts
        %         d(:, 2) - a/d values for the second enabled channel, in volts
        %         etc.
        
        fLFPTrialBufferLength = size(g_strctNeuralServer.m_strctBuffer.m_a3fLFP_Buffer,3);
        for iChannelIter=1:g_strctNeuralServer.m_iNumActiveSpikeChannels
            g_strctNeuralServer.m_strctBuffer.m_a2fLFP_TS(iTrialCounter,:) = t1(iChannelIter);
            iMaxUpdateLength = min(n1(iChannelIter), fLFPTrialBufferLength);
            g_strctNeuralServer.m_strctBuffer.m_a3fLFP_Buffer(iTrialCounter,iChannelIter,:) = NaN;
            g_strctNeuralServer.m_strctBuffer.m_a3fLFP_Buffer(iTrialCounter,iChannelIter,1:iMaxUpdateLength) = d1(1:iMaxUpdateLength,iChannelIter);
        end
        
        g_strctNeuralServer.m_strctBuffer.m_aiLFP_NumValidSamples = min(g_strctNeuralServer.m_strctBuffer.m_aiLFP_NumValidSamples+1, iTrialBufferLength-1);
        
        g_strctNeuralServer.m_strctBuffer.m_iTrialCounter = g_strctNeuralServer.m_strctBuffer.m_iTrialCounter + 1;
        
        if g_strctNeuralServer.m_strctBuffer.m_iTrialCounter > iTrialBufferLength
            g_strctNeuralServer.m_strctBuffer.m_iTrialCounter = 1;
            
        end
    end
    
else
    % Only collect relevant data.... ?
end

