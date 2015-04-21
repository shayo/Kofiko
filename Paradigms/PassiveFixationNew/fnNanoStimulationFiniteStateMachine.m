function fnNanoStimulationFiniteStateMachine()
global g_hNanoStimulatorPort g_strctParadigm

SOFT_TRIGGER = 11;
iChannel=1;
% for varying frequencys
afFrequencySweep = [1,20,40,100,200];
% for varying delays after detected spike
iNumSpikeRepeats = 30;
afTriggerDelayMs = [0,1,2,5,10,20];

switch g_strctParadigm.m_strctNanoStimulator.m_iMachineState
    case 0
        % Do nothing.
    case 1
        % Verify nano stimulation is connected.
        if ~isempty(g_hNanoStimulatorPort)
            % Start stimulation protocol (varying frequencies)
            g_strctParadigm.m_strctNanoStimulator.m_iFrequencySweepIter = 1;
            g_strctParadigm.m_strctNanoStimulator.m_iMachineState  = 2;
            
            % Save current set of parameters
            g_strctParadigm.m_strctNanoStimulator.m_astrctSavedParams = fnReadParametersFromStimulator(g_hNanoStimulatorPort);
            
        else
            % Error message.
            fnParadigmToKofikoComm('DisplayMessage', 'Open NanoStimGUI First!');
        end
    case 2
        % Deliver some stimulations....
        %                      PulseHz, Pulse_Usec, Train_Usec,  TrainHz, NumTrains
        
        iNumRepeats= fnTsGetVar(g_strctParadigm,'NanoStimulatorNumTrainRepeat');
        InterTrainTimeSec= fnTsGetVar(g_strctParadigm,'NanoStimulatorInterTrainInterval');
        
        fnParadigmToKofikoComm('DisplayMessage', sprintf('Sweep %d Hz',afFrequencySweep(g_strctParadigm.m_strctNanoStimulator.m_iFrequencySweepIter)));
        afStndardAntidromic = [afFrequencySweep(g_strctParadigm.m_strctNanoStimulator.m_iFrequencySweepIter),        150,        1000000,       1/InterTrainTimeSec,      iNumRepeats,      true,       100,        150,        250,      1,      true,150,600,0];
        strctParams=fnStimulationParamsArrayToStruct(iChannel,afStndardAntidromic);
        bOK = fnSetStimulationTrain(iChannel, strctParams);
        Res=IOPort('Write',  g_hNanoStimulatorPort , uint8([sprintf('%02d %d',SOFT_TRIGGER,iChannel-1),10]));
        g_strctParadigm.m_strctNanoStimulator.m_fStimTimerTS = GetSecs();
        g_strctParadigm.m_strctNanoStimulator.m_iFrequencySweepIter=g_strctParadigm.m_strctNanoStimulator.m_iFrequencySweepIter+1;
        g_strctParadigm.m_strctNanoStimulator.m_iMachineState  = 3;
        g_strctParadigm.m_strctNanoStimulator.m_iTrainCount = 0;
    case 3 % Wait inter train time x repetitions
        iNumRepeats= fnTsGetVar(g_strctParadigm,'NanoStimulatorNumTrainRepeat');
        InterTrainTimeSec= fnTsGetVar(g_strctParadigm,'NanoStimulatorInterTrainInterval');
        
        if GetSecs()-g_strctParadigm.m_strctNanoStimulator.m_fStimTimerTS > InterTrainTimeSec*iNumRepeats+1 % +1 just in case
            if g_strctParadigm.m_strctNanoStimulator.m_iFrequencySweepIter > length(afFrequencySweep)
                % Done!
                g_strctParadigm.m_strctNanoStimulator.m_iMachineState  = 0;
                fnParadigmToKofikoComm('DisplayMessage', 'Sweep Finished');
                
                strctParams.m_astrctChannels = g_strctParadigm.m_strctNanoStimulator.m_astrctSavedParams;
                for k=1:length(g_strctParadigm.m_strctNanoStimulator.m_astrctSavedParams)
                    bOK = fnSetStimulationTrain(k, strctParams);
                end
                      
            else
                % Still working
                g_strctParadigm.m_strctNanoStimulator.m_iMachineState  = 2;
                
            end
        else
            if GetSecs()-g_strctParadigm.m_strctNanoStimulator.m_fStimTimerTS > InterTrainTimeSec*g_strctParadigm.m_strctNanoStimulator.m_iTrainCount
                fnParadigmToKofikoComm('DisplayMessage', sprintf('Train %d, %d Hz',g_strctParadigm.m_strctNanoStimulator.m_iTrainCount,afFrequencySweep(g_strctParadigm.m_strctNanoStimulator.m_iFrequencySweepIter-1)));
                g_strctParadigm.m_strctNanoStimulator.m_iTrainCount=g_strctParadigm.m_strctNanoStimulator.m_iTrainCount+1;
            end
        end
        
    case 10
        % Machine for antidromic evoked stimulations
        % Verify nano stimulation is connected.
        if ~isempty(g_hNanoStimulatorPort)
            % Start stimulation protocol (varying frequencies)
            g_strctParadigm.m_strctNanoStimulator.m_iDelaySweepIter = 1;
            g_strctParadigm.m_strctNanoStimulator.m_iMachineState  = 11;
            
            % Save current set of parameters
            g_strctParadigm.m_strctNanoStimulator.m_astrctSavedParams = fnReadParametersFromStimulator(g_hNanoStimulatorPort);
             
        else
            % Error message.
            fnParadigmToKofikoComm('DisplayMessage', 'Open NanoStimGUI First!');
        end
    case 11
        fnParadigmToKofikoComm('DisplayMessage', sprintf('Spike Delay %d ms',afTriggerDelayMs(g_strctParadigm.m_strctNanoStimulator.m_iDelaySweepIter)));
        
        InterTrainTimeSec= fnTsGetVar(g_strctParadigm,'NanoStimulatorInterTrainInterval');
        
        afStndardAntidromic = [1,        150,        25*1000,       1,      1,      true,       100,        150,        afTriggerDelayMs(g_strctParadigm.m_strctNanoStimulator.m_iDelaySweepIter)*1000+250,      1,      true,afTriggerDelayMs(g_strctParadigm.m_strctNanoStimulator.m_iDelaySweepIter)*1000+150,600,0];
        strctParams=fnStimulationParamsArrayToStruct(iChannel,afStndardAntidromic);
        bOK = fnSetStimulationTrain(iChannel, strctParams);
        g_strctParadigm.m_strctNanoStimulator.m_aiTriggersBefore = fnGetNanoStimulatorTriggerCount();
        g_strctParadigm.m_strctNanoStimulator.m_iMachineState  = 12;
        g_strctParadigm.m_strctNanoStimulator.m_fStimTimerTS = GetSecs();
    case 12
        % Check whether enough spikes were detected
        if GetSecs()-g_strctParadigm.m_strctNanoStimulator.m_fStimTimerTS > 2 % Check every two seconds
            aiTriggers = fnGetNanoStimulatorTriggerCount();
            iNumTriggersNeeded= fnTsGetVar(g_strctParadigm,'NanoStimulatorSpikeTriggerCount');
            
            fnParadigmToKofikoComm('DisplayMessage', ...
                sprintf('%d/%d Spikes at %d ms',aiTriggers(iChannel)-g_strctParadigm.m_strctNanoStimulator.m_aiTriggersBefore(iChannel),...
                iNumTriggersNeeded,afTriggerDelayMs(g_strctParadigm.m_strctNanoStimulator.m_iDelaySweepIter)));
            
            if aiTriggers(iChannel) >= g_strctParadigm.m_strctNanoStimulator.m_aiTriggersBefore(iChannel) + iNumTriggersNeeded
                g_strctParadigm.m_strctNanoStimulator.m_iDelaySweepIter=g_strctParadigm.m_strctNanoStimulator.m_iDelaySweepIter+1;
                if g_strctParadigm.m_strctNanoStimulator.m_iDelaySweepIter > length(afTriggerDelayMs)
                    g_strctParadigm.m_strctNanoStimulator.m_iMachineState  = 0;
                    fnParadigmToKofikoComm('DisplayMessage', 'Sweep Finished');
                    
                    strctParams.m_astrctChannels = g_strctParadigm.m_strctNanoStimulator.m_astrctSavedParams;
                    for k=1:length(g_strctParadigm.m_strctNanoStimulator.m_astrctSavedParams)
                        bOK = fnSetStimulationTrain(k, strctParams);
                       end
                            
                else
                    g_strctParadigm.m_strctNanoStimulator.m_iMachineState  = 11;
                end
            end
        end
        
        
      case 20  
        % Verify nano stimulation is connected.
        if ~isempty(g_hNanoStimulatorPort)
            % Start stimulation protocol (varying frequencies)
            g_strctParadigm.m_strctNanoStimulator.m_iFrequencySweepIter = 1;
            g_strctParadigm.m_strctNanoStimulator.m_iMachineState  = 21;
            
            % Save current set of parameters
            g_strctParadigm.m_strctNanoStimulator.m_astrctSavedParams = fnReadParametersFromStimulator(g_hNanoStimulatorPort);
              
        else
            % Error message.
            fnParadigmToKofikoComm('DisplayMessage', 'Open NanoStimGUI First!');
        end
         
    case 21
        % Deliver some 5 ms stimulation
        %                      PulseHz, Pulse_Usec, Train_Usec,  TrainHz, NumTrains
        iChannel=2;
        afFrequencySweep = [1,20,40,100,150];

        iNumRepeats= fnTsGetVar(g_strctParadigm,'NanoStimulatorNumTrainRepeat');
        InterTrainTimeSec= fnTsGetVar(g_strctParadigm,'NanoStimulatorInterTrainInterval');
        
        fnParadigmToKofikoComm('DisplayMessage', sprintf('Sweep %d Hz',afFrequencySweep(g_strctParadigm.m_strctNanoStimulator.m_iFrequencySweepIter)));
        afStndardOptogenetics = [afFrequencySweep(g_strctParadigm.m_strctNanoStimulator.m_iFrequencySweepIter),        5000,        1000000,       1/InterTrainTimeSec,      iNumRepeats,      false,       0,        0,        0,      1,      true,0,0,0];
        strctParams=fnStimulationParamsArrayToStruct(iChannel,afStndardOptogenetics);
        bOK = fnSetStimulationTrain(iChannel, strctParams);
        Res=IOPort('Write',  g_hNanoStimulatorPort , uint8([sprintf('%02d %d',SOFT_TRIGGER,iChannel-1),10]));
        g_strctParadigm.m_strctNanoStimulator.m_fStimTimerTS = GetSecs();
        g_strctParadigm.m_strctNanoStimulator.m_iFrequencySweepIter=g_strctParadigm.m_strctNanoStimulator.m_iFrequencySweepIter+1;
        g_strctParadigm.m_strctNanoStimulator.m_iMachineState  = 22;
        g_strctParadigm.m_strctNanoStimulator.m_iTrainCount = 0;
    case 22 % Wait inter train time x repetitions
        iNumRepeats= fnTsGetVar(g_strctParadigm,'NanoStimulatorNumTrainRepeat');
        InterTrainTimeSec= fnTsGetVar(g_strctParadigm,'NanoStimulatorInterTrainInterval');
            afFrequencySweep = [1,20,40,100,150];

        if GetSecs()-g_strctParadigm.m_strctNanoStimulator.m_fStimTimerTS > InterTrainTimeSec*iNumRepeats+1 % +1 just in case
            if g_strctParadigm.m_strctNanoStimulator.m_iFrequencySweepIter > length(afFrequencySweep)
                % Done!
                g_strctParadigm.m_strctNanoStimulator.m_iMachineState  = 23;
                
            else
                % Still working
                g_strctParadigm.m_strctNanoStimulator.m_iMachineState  = 21;
                
            end
        else
            if GetSecs()-g_strctParadigm.m_strctNanoStimulator.m_fStimTimerTS > InterTrainTimeSec*g_strctParadigm.m_strctNanoStimulator.m_iTrainCount
                fnParadigmToKofikoComm('DisplayMessage', sprintf('Train %d, %d Hz',g_strctParadigm.m_strctNanoStimulator.m_iTrainCount,afFrequencySweep(g_strctParadigm.m_strctNanoStimulator.m_iFrequencySweepIter-1)));
                g_strctParadigm.m_strctNanoStimulator.m_iTrainCount=g_strctParadigm.m_strctNanoStimulator.m_iTrainCount+1;
            end
        end
    case 23
        % Continuous train...
   %                      PulseHz, Pulse_Usec, Train_Usec,  TrainHz, NumTrains
        iNumRepeats= fnTsGetVar(g_strctParadigm,'NanoStimulatorNumTrainRepeat');
        InterTrainTimeSec= fnTsGetVar(g_strctParadigm,'NanoStimulatorInterTrainInterval');
   
             iChannel=2;
        afStndardOptogenetics = [1,        500000,        1000000,       1/InterTrainTimeSec,      iNumRepeats,      false,       0,        0,        0,      1,      true,0,0,0];
        strctParams=fnStimulationParamsArrayToStruct(iChannel,afStndardOptogenetics);
        bOK = fnSetStimulationTrain(iChannel, strctParams);
        Res=IOPort('Write',  g_hNanoStimulatorPort , uint8([sprintf('%02d %d',SOFT_TRIGGER,iChannel-1),10]));
        g_strctParadigm.m_strctNanoStimulator.m_fStimTimerTS = GetSecs();
        g_strctParadigm.m_strctNanoStimulator.m_iMachineState  = 24;
        g_strctParadigm.m_strctNanoStimulator.m_iTrainCount = 0;
    case 24
        iNumRepeats= fnTsGetVar(g_strctParadigm,'NanoStimulatorNumTrainRepeat');
        InterTrainTimeSec= fnTsGetVar(g_strctParadigm,'NanoStimulatorInterTrainInterval');
        if GetSecs()-g_strctParadigm.m_strctNanoStimulator.m_fStimTimerTS > InterTrainTimeSec*iNumRepeats+1 % +1 just in case
                  g_strctParadigm.m_strctNanoStimulator.m_iMachineState  = 25;
                  g_strctParadigm.m_strctNanoStimulator.m_iFrequencySweepIter= 1;
        end
    case 25
        % Now deliver 1 ms stimulations.
        
     % Deliver some 5 ms stimulation
        %                      PulseHz, Pulse_Usec, Train_Usec,  TrainHz, NumTrains
        iChannel=2;
        afFrequencySweep = [1,20,40,100,200,300];

        iNumRepeats= fnTsGetVar(g_strctParadigm,'NanoStimulatorNumTrainRepeat');
        InterTrainTimeSec= fnTsGetVar(g_strctParadigm,'NanoStimulatorInterTrainInterval');
        
        fnParadigmToKofikoComm('DisplayMessage', sprintf('Sweep %d Hz',afFrequencySweep(g_strctParadigm.m_strctNanoStimulator.m_iFrequencySweepIter)));
        afStndardOptogenetics = [afFrequencySweep(g_strctParadigm.m_strctNanoStimulator.m_iFrequencySweepIter),        1000,        1000000,       1/InterTrainTimeSec,      iNumRepeats,      false,       0,        0,        0,      1,      true,0,0,0];
        strctParams=fnStimulationParamsArrayToStruct(iChannel,afStndardOptogenetics);
        bOK = fnSetStimulationTrain(iChannel, strctParams);
        Res=IOPort('Write',  g_hNanoStimulatorPort , uint8([sprintf('%02d %d',SOFT_TRIGGER,iChannel-1),10]));
        g_strctParadigm.m_strctNanoStimulator.m_fStimTimerTS = GetSecs();
        g_strctParadigm.m_strctNanoStimulator.m_iFrequencySweepIter=g_strctParadigm.m_strctNanoStimulator.m_iFrequencySweepIter+1;
        g_strctParadigm.m_strctNanoStimulator.m_iMachineState  = 26;
        g_strctParadigm.m_strctNanoStimulator.m_iTrainCount = 0;
        
    case 26
   iNumRepeats= fnTsGetVar(g_strctParadigm,'NanoStimulatorNumTrainRepeat');
        InterTrainTimeSec= fnTsGetVar(g_strctParadigm,'NanoStimulatorInterTrainInterval');
          afFrequencySweep = [1,20,40,100,200,300];

        if GetSecs()-g_strctParadigm.m_strctNanoStimulator.m_fStimTimerTS > InterTrainTimeSec*iNumRepeats+1 % +1 just in case
            if g_strctParadigm.m_strctNanoStimulator.m_iFrequencySweepIter > length(afFrequencySweep)
                % Done!
                g_strctParadigm.m_strctNanoStimulator.m_iMachineState  = 27;
                
            else
                % Still working
                g_strctParadigm.m_strctNanoStimulator.m_iMachineState  = 25;
                
            end
        else
            if GetSecs()-g_strctParadigm.m_strctNanoStimulator.m_fStimTimerTS > InterTrainTimeSec*g_strctParadigm.m_strctNanoStimulator.m_iTrainCount
                fnParadigmToKofikoComm('DisplayMessage', sprintf('Train %d, %d Hz',g_strctParadigm.m_strctNanoStimulator.m_iTrainCount,afFrequencySweep(g_strctParadigm.m_strctNanoStimulator.m_iFrequencySweepIter-1)));
                g_strctParadigm.m_strctNanoStimulator.m_iTrainCount=g_strctParadigm.m_strctNanoStimulator.m_iTrainCount+1;
            end
        end        
        
    case 27
        g_strctParadigm.m_strctNanoStimulator.m_iMachineState  = 0;
        fnParadigmToKofikoComm('DisplayMessage', 'Sweep Finished');
        strctParams.m_astrctChannels = g_strctParadigm.m_strctNanoStimulator.m_astrctSavedParams;
        for k=1:length(g_strctParadigm.m_strctNanoStimulator.m_astrctSavedParams)
            bOK = fnSetStimulationTrain(k, strctParams);
        end
        
        
end



