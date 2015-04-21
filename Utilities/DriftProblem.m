s = PL_InitClient(0);

afTimeDifferenceBetweenHardwareAndSoftware_Sec = zeros(1,100);

NumRepeatitions = 100;

for k=1:NumRepeatitions
    
    N = 100; % Number of times to inject a strobe word
    afSoftwareTime = zeros(1,N);
    afHardwareTime = zeros(1,N);
    for iTrial=1:N
        iPlexonSpecialSyncStrobeWord = 32754;
        [n, t] = PL_GetTS(s); % Clear buffer
        afSoftwareTime(iTrial) = GetSecs();
        PL_SendUserEventWord(s, iPlexonSpecialSyncStrobeWord);
        
        while (1)
            [n, t] = PL_GetTS(s);
            iIndex=find(t(:,1) == 4 & t(:,2) == 257  & t(:,3) == iPlexonSpecialSyncStrobeWord,1,'last');
            if ~isempty(iIndex)
                break;
            end;
        end
        afHardwareTime(iTrial) = t(iIndex,4);
    end
    
    afTimeDiff = afHardwareTime-afSoftwareTime;
    fMeanTimeDifference = median(afTimeDiff);
    afTimeDiff0 = afTimeDiff-fMeanTimeDifference;
    fJitterMS = std(afTimeDiff0)*1e3;
    
    afTimeDifferenceBetweenHardwareAndSoftware_Sec(k)=fMeanTimeDifference;
    fprintf('Sync between hardware and software timestamp : %.3f,  %.3fms jitter\n',fMeanTimeDifference,fJitterMS);
    
    % Sleep for 5 seconds
    A=GetSecs();
    while GetSecs()-A < 5
    end
    
    figure(1);
    clf;
    plot(1:k,afTimeDifferenceBetweenHardwareAndSoftware_Sec(1:k));
    drawnow
    
end