function [bMessageSentOK] = fnParadigmToParadigmComm(acParadigmNames, varargin)
global g_astrctAllParadigms  g_iCurrParadigm g_strctParadigm g_abParadigmInitialized
% Send a message to another paradigm's callback function
% Can be used to modify data structures...
%
% Inputs:
% acParadigmNames: a cell array containing paradigm names, or
% a single string that can either be a single paradigm, or the keyword
% "All", which will broadcast the message to all paradigms.
% , varargin

if ~iscell(acParadigmNames)
    acParadigmNames = {acParadigmNames};
end

acAllParadigmNames = fnCellStructToArray(g_astrctAllParadigms,'m_strName');

if length(acParadigmNames) == 1 && strcmpi(acParadigmNames{1},'All')
    acParadigmNames = acAllParadigmNames;
end

strCallingParadigmName = g_astrctAllParadigms{g_iCurrParadigm}.m_strName;
bMessageSentOK = true;
g_astrctAllParadigms{g_iCurrParadigm} = g_strctParadigm;

iCallingParadigmIndex = g_iCurrParadigm;

bInitCalled = false;
for iIter=1:length(acAllParadigmNames)
    
    if strcmpi(acParadigmNames{iIter},strCallingParadigmName)
        % Do not pass this message to the calling paradigm
        continue;
    end
    
    if ismember(acParadigmNames{iIter},  acAllParadigmNames)
        % Send a message to another paradigm.
        %  Before we can do this, we need to save the current state, set it
        %  to the other paradigm, and then restore it....
        
        if ~g_abParadigmInitialized(iIter)
            % This is a more complicated scenario, in which we want to pass
            % a message to a paradigm that has not been initialized yet.
            % There are two options. Either to initialize the paradigm
            % properly, pass the message, then restore everything, or just
            % not to pass the message....
            
            if bInitCalled == false
                % First time we encounter this scenario. Instruct the
                % calling paradigm to close all textures and stuff....as if
                % we switched to another paradigm...
                g_iCurrParadigm = iCallingParadigmIndex;
                g_strctParadigm = g_astrctAllParadigms{g_iCurrParadigm};
                feval(g_strctParadigm.m_strParadigmSwitch,'Close');
            end
            
            % Set New state
            g_iCurrParadigm = iIter;
            g_strctParadigm = g_astrctAllParadigms{g_iCurrParadigm};
            
            
            feval(g_strctParadigm.m_strInit);
            feval(g_strctParadigm.m_strGUI);
            g_abParadigmInitialized(g_iCurrParadigm) = 1;
            bInitCalled = true;
        end
        
        feval(g_strctParadigm.m_strCallbacks, varargin{:});
        % Store the updated state
        g_astrctAllParadigms{g_iCurrParadigm} = g_strctParadigm;
        
        
    end
end

g_iCurrParadigm = iCallingParadigmIndex;
g_strctParadigm = g_astrctAllParadigms{g_iCurrParadigm};

if bInitCalled
    % Some paradigm had to be initialized. This means that PTB stuff might
    % have changed. We need to call paradigm switch to make sure everything
    % is still ok..... (just to be on the safe side...)
    feval(g_strctParadigm.m_strParadigmSwitch,'Init');
end

return;
