function [ColorChoiceCell, ColorCueCell] = fnGenerateColorTuningEstimate(g_strctParadigm, g_strctPlexon)



numConditions = numel(fields(g_strctPlexon.m_afConditionSpikes));
ColorChoiceCell = {};
CurrentSaturation = g_strctParadigm.m_strctMasterColorTableLookup{g_strctParadigm.iSelectedColorList};

maximums = zeros(numConditions,1);
for i = 1:numConditions
			
	cond = ['condition',num2str(i)];
	maximums(i) = mean(sum([g_strctPlexon.m_afConditionSpikes.(cond)(g_strctPlexon.m_afConditionSpikes.(cond)(:,2) == 1)],2));
end
normMax = max(maximums);

for i = 1:numConditions
    if isnan(normMax)
        normalizedSpikes(i) = 0;
    else
        normalizedSpikes(i) = maximums(i)/normMax;
    end
end
PeakResponse = find(max(normalizedSpikes));
%ColorChoiceCell{end+1,1} = [PeakResponse,CurrentSaturation,1];
ColorChoiceCell{end+1,1} = PeakResponse;
ColorChoiceCell{end,2} = CurrentSaturation;
%ColorChoiceCell{end,3} = 1;
%ColorChoiceCell{end,3} = 1;
ColorChoiceCell{end+1,1} = round(rem(PeakResponse + numConditions/4,numConditions)); % 90 degrees
ColorChoiceCell{end,2} = CurrentSaturation; 
%ColorChoiceCell{end,3} = 0; 
ColorChoiceCell{end+1,1} = round(rem(PeakResponse + numConditions/2,numConditions)); %Opposite
ColorChoiceCell{end,2} = CurrentSaturation; 
%ColorChoiceCell{end,3} = 0; 


ColorChoiceCell{end+1,1} = round(rem(PeakResponse + ((numConditions/4) + (numConditions/2)) ,numConditions)); % 270 degrees
ColorChoiceCell{end,2} = CurrentSaturation; 
%ColorChoiceCell{end,3} = 0;

colorEqualsZero = cellfun(@any,ColorChoiceCell(:,1));
if ~colorEqualsZero
	ColorChoiceCell{~colorEqualsZero,1} = numConditions; % Set to the max condition. Equivalent of 0
end


return;


function [ColorCueCell] = GetCueList(g_strctParadigm, ColorChoiceCell)


ColorSaturations = fields(g_strctParadigm.m_strctMasterColorTable);
for iFields = 1 : numel(ColorSaturations)

	ColorCueCell{iFields,1} = ColorSaturations{iFields}; % Name of saturation
	ColorCueCell{iFields,:} = g_strctParadigm.m_strctMasterColorList.(ColorSaturations{iFields}).RGB([ColorChoiceCell{1,1},ColorChoiceCell{2,1},ColorChoiceCell{3,1},ColorChoiceCell{4,1}],:);
	


end
return;




return;