function [choiceDirection, choiceDirectionOpposite] = fnCalculateAnswerDirection(varargin)
global g_strctParadigm


if ~nargin
	% trial over, we're calculating the results
	DirVector1 = [g_strctParadigm.m_strctCurrentTrial.m_strctPreCueFixation.m_pt2fFixationPosition] - ...
				[g_strctParadigm.m_strctCurrentTrial.m_strctPreCueFixation.m_pt2fFixationPosition(1), g_strctParadigm.m_strctCurrentTrial.m_strctTrialParams.m_aiStimServerScreen(4)];
	% Fixation point to selected choice location
	DirVector2 = [g_strctParadigm.m_strctCurrentTrial.m_strctPreCueFixation.m_pt2fFixationPosition] - ...
				[g_strctParadigm.m_strctCurrentTrial.m_astrctChoicesMedia(g_strctParadigm.m_strctCurrentTrial.m_strctTrialOutcome.m_aiSelectedChoice).m_pt2fPosition];

	%fancy maths to determine the angle from the fixation point to the selected answer location
	choiceDirection = round(((mod(-atan2(DirVector1(1)*DirVector2(2)-DirVector1(2)*DirVector2(1), DirVector1*DirVector2'), 2*pi) * 180/pi)/360)*20);


	choiceDirectionOpposite = ceil(rem(choiceDirection + ...
				size(g_strctParadigm.m_strctStatistics.m_aiAnswerDirectionBias,2)/2,size(g_strctParadigm.m_strctStatistics.m_aiAnswerDirectionBias,2)));

	% so we dont index 0 in any arrays 
	choiceDirectionOpposite(choiceDirectionOpposite == 0) = 20;
	choiceDirection(choiceDirection == 0) = 20;
else
	% trial prep, we're calculating the proposed coordinates
	%varargin{1}.m_strctChoices.m_pt2fFixationPosition
	
	
	DirVector1 = [varargin{1,1}.m_strctChoices.m_pt2fFixationPosition] - ...
				[varargin{1,1}.m_strctChoices.m_pt2fFixationPosition(1), varargin{1,1}.m_strctTrialParams.m_aiStimServerScreen(4)];
	% Fixation point to selected choice location # 1
	DirVector2 = [varargin{1,1}.m_strctChoices.m_pt2fFixationPosition] - ...
				[varargin{2}(1,:)];

	%fancy maths to determine the angle from the fixation point to the selected answer location
	choiceDirection = round(((mod(-atan2(DirVector1(1)*DirVector2(2)-DirVector1(2)*DirVector2(1), DirVector1*DirVector2'), 2*pi) * 180/pi)/360)*20);


	choiceDirectionOpposite = ceil(rem(choiceDirection + ...
				size(g_strctParadigm.m_strctTrainingVars.m_strctTrialBuffer.m_aiTrialCircularDirectionBuffer,2)/2,...
				size(g_strctParadigm.m_strctTrainingVars.m_strctTrialBuffer.m_aiTrialCircularDirectionBuffer,2)));

	% so we dont index 0 in any arrays 
	choiceDirectionOpposite(choiceDirectionOpposite == 0) = 20;
	choiceDirection(choiceDirection == 0) = 20;


end


return;