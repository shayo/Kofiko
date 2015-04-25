function [b_success] = fnInitializeHandMappingCommandStructure()
%
% Initializes values for the hand mapping paradign
global g_strctParadigm  g_strctStimulusServer


% Only 1 stimuli. THERE CAN BE ONLY ONE!!!
g_strctParadigm.m_iNumStimuli = 1;

% Placeholder for the design so Kofiko doesn't flip out later
%g_strctParadigm.m_strctDesign = 1;




% Start with bar size of 200 length 100 width and 0 rotation
%g_strctParadigm.m_strctHandMappingParameters.m_bLength = 200;
g_strctParadigm.m_strctHandMappingParameters.m_bLength = 200;
g_strctParadigm.m_strctHandMappingParameters.m_bWidth = 100;
g_strctParadigm.m_strctHandMappingParameters.m_bOrientation = 0;

% Start with 0 movement distance and 1 bar
g_strctParadigm.m_strctHandMappingParameters.m_bMoveDistance = 0;
g_strctParadigm.m_strctHandMappingParameters.m_bNumberOfBars = 1;

% Booleans
% No initial randomized bar position or orientation
g_strctParadigm.m_strctHandMappingParameters.m_bRandomStimulusPosition = 0;
g_strctParadigm.m_strctHandMappingParameters.m_bRandomStimulusOrientation = 0;

% Get the experiment master color file
% We can do this later
%{
try 
   g_strctParadigm.m_strctColorValues = load(
return
%} 

b_success = 1;
return;