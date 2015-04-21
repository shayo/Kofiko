 load('D:\Data\Doris\Electrophys\Rocco\Sinha Project\AllUnits\Sinha\Rocco_2009-12-16_17-16-03_Exp_02_Ch_001_Unit_001_Passive_Fixation_SinhaFOB');


a2iPartRatio = nchoosek(1:11,2);
a2iCorrectEdges = [...
    2, 1;
    4, 1;
    2, 5;
    4, 7;
    2, 3;
    4, 3;
    6, 3;
    9, 5;
    9, 7;
    9, 8;
    9, 10;
    9, 11];

aiSinhaRatio = zeros(1,12);
for k=1:12
aiSinhaRatio(k) = find(a2iPartRatio(:,1) == a2iCorrectEdges(k,1) & a2iPartRatio(:,2) == a2iCorrectEdges(k,2) | ...
     a2iPartRatio(:,1) == a2iCorrectEdges(k,2) & a2iPartRatio(:,2) == a2iCorrectEdges(k,1));
end
acPartNames = {'Forehead','Left Eye','Nose','Right Eye','Left Cheek','Upper Lip','Right Cheek','Lower Left Cheek','Mouth','Lower Right Cheek','Chin'};

a2fFiring = [strctUnit.m_afAvgFiringSamplesCategory(aiSinhaRatio+6),strctUnit.m_afAvgFiringSamplesCategory(aiSinhaRatio+6+55)];
afPValue = zeros(1,12);
acNames = cell(1,12);
for k=1:12
    iPartA = a2iCorrectEdges(k,1);
    iPartB = a2iCorrectEdges(k,2);
    afPValue(k)=strctUnit.m_a2fPValueCat(aiSinhaRatio(k)+6, aiSinhaRatio(k)+6+55);
    acNames{k} = [acPartNames{iPartA},' - ',acPartNames{iPartB}];
    
end

afMaxFir = max(a2fFiring,[],2);
figure(3);
clf;
barh(a2fFiring);
hold on;
set(gca,'yticklabel',acNames);
ylabel('Part Pairs');
xlabel('Avg. Firing Rate (Hz)');

aiSig = find(afPValue < 0.05);
plot(afMaxFir(aiSig)*1.05,aiSig,'r*');
title(sprintf('Cell %s, Exp %d, Ch %d, Unit %d',strctExampleCell.m_strRecordedTimeDate,...
    strctExampleCell.m_iRecordedSession,strctExampleCell.m_iChannel,strctExampleCell.m_iUnitID));
