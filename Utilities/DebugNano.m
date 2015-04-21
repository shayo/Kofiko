fnDAQ('Init',0)
%%
fnDAQ('SetBit',18,0);
fnDAQ('SetBit',19,0);
PhotodiodeStateMachine = 0;
PhotodiodeStateMachineTimer = 0;
PhotodiodeONperiod = 0.25;
PhotodiodeOFFperiod = 0.15;

StimulationStateMachine = 0;
StimulationStateMachineTimer = 0;
StimulationFrequency = 0.4;
StimulationCounter = 0;
while (1)
    if PhotodiodeStateMachine == 0
        fnDAQ('SetBit',18,1);
        PhotodiodeStateMachineTimer = GetSecs();
        PhotodiodeStateMachine = 1;
    end
    if PhotodiodeStateMachine == 1 && GetSecs() - PhotodiodeStateMachineTimer > PhotodiodeONperiod
        fnDAQ('SetBit',18,0);
        PhotodiodeStateMachineTimer = GetSecs();
        PhotodiodeStateMachine = 2;
    end
    if PhotodiodeStateMachine == 2 && GetSecs() - PhotodiodeStateMachineTimer > PhotodiodeOFFperiod
        PhotodiodeStateMachine = 0;
    end

    if StimulationStateMachine == 0
        StimulationCounter=StimulationCounter+1;
        if (StimulationCounter > 3)
            break;
        end
        fnDAQ('TTL',19,250*1e-6);
        StimulationStateMachine = 1;
        StimulationStateMachineTimer = GetSecs();
    end
    if StimulationStateMachine == 1 && GetSecs() - StimulationStateMachineTimer > StimulationFrequency
        StimulationStateMachine = 0;
    end
end

    