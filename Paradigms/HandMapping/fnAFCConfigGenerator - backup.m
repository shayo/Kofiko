function fnAFCConfigGenerator(xpos, ypos, theta, length, width, blur, blurSteps, expName, listOfConditions, neuronPeakColor, experimentColorFile)

% Set this variable to zero if you will be generating stimulus for an actual experiment
testing = 0 ;

% Stimulus and config generator for the Kofiko AFC task
% Operates much the same way the passive fixation generator does
% produces a template image with a bar at the selected coordinates, saves that template with a color lookup table with the appropriate colors
% for the choices, takes the input neuronPeakColor and selects the appropriate color from the selected saturation, as well as the 'wrong' 
% choices that accompany it, and saves a color lookup table with a blank image
% if neuronPeakColor has only 1 color, format {color number, 'saturation'}, then the wrong choices are chosen based on the experiment type (yet to be implemented)
% otherwise, wrong choices are generated based on how many elements are given in that variable, E.G. neuronPeakColor {:, 1:2, [1]} are correct choices
% {:,1:2, [0]} are wrong choices

% Filename for the kofiko config file
 xmlFileName = 'AFCimList.xml';
 
 Stimulating = 1;
% variables for determining trial types
experimentStimulusVars = [];
experimentStimulusVars.numChoicesPerTrial = 2;
experimentStimulusVars.choiceLocations = {'down','up';'left','right'};
experimentStimulusVars.cueAttr = 'Cue';
experimentStimulusVars.choiceAttr = 'Choice';
experimentStimulusVars.defaultChoiceSize = 80;
experimentStimulusVars.trialOrderVars.NumTrials = 1000;
experimentStimulusVars.trialOrderVars.RepeatIncorrect = 0;

% Stimulation stuff
experimentStimulusVars.microStim.Stimulation = '1';
experimentStimulusVars.microStim.StimChannels = '1';
experimentStimulusVars.microStim.stimEpoch = 'Cue';


% Coordinates of choices in pixels
% Must match with cell coordinates for choiceLocations
% I.E. choiceLocations{1,1} must be the indicator for choiceCoordinates{1,1}
% Coordinate are given relative to screen center, positive numbers denote up or right, depending on x or y dimension.
experimentStimulusVars.choiceCoordinates = {[0,-200],[0, 200];[-200,0],[200,0]};

% Don't repeat choices in the same trial? Don't use two (or more) correct
% answers per trial?
experimentStimulusVars.dont_repeat_choices_in_same_trial = 1;
experimentStimulusVars.only_one_correct_answer = 1;
% Load base trial parameters and initialize the empty fields
% 
default_trial_params_Loc = 'c:\workingfolder\stimgen\defaultTrialParams';
load(default_trial_params_Loc);
if isfield(default_trial_params,'GlobalVars')
    baseTrialParams.GlobalVars = default_trial_params.GlobalVars;
end
baseTrialParams.Media = [];
%baseTrialParams.TrialOrder = [];

% Judd corrected background color
neutralGray = [48735 48725 49170];

% Add the 'choices' fields to the conditions list
% It will always exist in this paradigm
listOfConditions{end+1} = 'choices';



% Paths for finding folders
beginFolder = pwd;
xmlFileName = 'imList.xml';
backupFolder = strcat('E:\Stimulus Set Backups\',expName);
kofikoExpDir = 'Z:\StimulusSet\AFC\';
analysisDir = strcat('C:\testfolder\session analysis\Pollux\',expName);
warning('Load .mat file with the colors for this experiment')
%experimentColorFile = uigetfile;
%experimentColorFile = load(experimentColorFile);


% End user defined variables
% ==================================================================================================================




if testing
    expDir = strcat('C:\testfolder\CLUTtesting\',expName);
    mkdir(expDir)
    cd(expDir)
else
    mkdir(backupFolder)
    cd(kofikoExpDir)
    controlLocalBackupFolder = strcat('Y:\',expName);
    mkdir(controlLocalBackupFolder)
    % Clear the current experiment folder so we don't have all the old experiment crap lying around
    % =============================================================================================
    % Warning !!!!
    % For anyone modifying this script: the delete command used with the wildcard * is extremely powerful
    % Be very careful changing the target path
    % =============================================================================================
    delete(strcat(kofikoExpDir,'\*'))
    % =============================================================================================
end
tic
% modification because RF3 changed to fullscreen
length = round((length/640)*1024);
width = round((width/480)*768);
warning('Background gray and inter-trial interval gray are set to be the same thing, change this if necessary!')
try
    if ~exist('varargin(1)','var')
        [backGroundColor, ITIGray] = deal(neutralGray);
    end
catch
    [backGroundColor(1:3), ITIGray(1:3)] = deal(varargin{1}(1:3));
end

% Generate the stimulus template
[imTemplate, xpos, ypos, theta, length, width, blur, blurSteps, unrotatedImTemplate, xTransform, yTransform] = stimGen16BitClutTemplate(xpos, ypos, theta, length, width, blur, blurSteps);
%[imTemplate, xpos, ypos, theta, length, width, blur, blurSteps, unrotatedImTemplate, xTransform, yTransform] =  stimGen16BitClutTemplate(xpos, ypos, theta, length, width, blur, blurSteps)
% Get the color values for the experiment
[RGB] = getRGBvalsForAFC(experimentColorFile, listOfConditions, backGroundColor, neuronPeakColor);

% Loop through the color values and generate a stimulus for each one
% The AFC choices do not need an image, but they do need a CLUT
% The Kofiko AFC paradigm will automatically generate choices at the locations
% and fill them in according to the colors fed in with the CLUT
[m,n] = size(RGB);
for i = 1:256
Clut(i,:) = [0 0 0];
Clut(2,:) = backGroundColor;
Clut(256,:) = [65535 65535 65535];
end
for j = 1:m
    

	
	
    % Setup blur for standard bars, ignore the gabor and spatial frequency conditions
    if blur && ~strcmp(listOfConditions{RGB(j,4)},'choices')
        rSteps = double(round(linspace(backGroundColor(1), RGB(j,1), blurSteps+1)));
        gSteps = double(round(linspace(backGroundColor(2), RGB(j,2), blurSteps+1)));
        bSteps = double(round(linspace(backGroundColor(3), RGB(j,3), blurSteps+1)));
        % Index from 3: 1 is the photodiode black, 2 is the background gray, 3
        % is the first step of the bar, or the full bar if blur is not on
        % Index from i-1 for the blursteps: will index outside the array
        % otherwise, but we want to skip the first step (background gray)
        for i = 1:blurSteps
            Clut(i+2,1) = rSteps(i+1);
            Clut(i+2,2) = gSteps(i+1);
            Clut(i+2,3) = bSteps(i+1);
        end
    elseif ~blur || strcmp(listOfConditions{RGB(j,4)},'choices')
        Clut(3,:) = RGB(j,1:3);
    elseif strcmp(listOfConditions{RGB(j,4)},'choices')
        
    end
    
    stimNumber = j;
	experimentStimulusVars.stimOrder(j,1:5) = RGB(j,1:5);
    % Different name for choices
	if strcmp(listOfConditions{RGB(j,4)}, 'choices')
		filename = strcat('choice',num2str(RGB(j,5)),'.mat');
	else
		filename = strcat('c',num2str(j),'.mat');
	end
    RGBvals = RGB(j,1:3);
    conditionName = listOfConditions{RGB(j,4)};
    colorNumber = RGB(j,5);

	% Handle config file stuff
	baseTrialParams.Media.Image(j).Name = filename;
	baseTrialParams.Media.Image(j).FileName = [kofikoExpDir, filename];
	if strcmp(listOfConditions{RGB(j,4)}, 'choices')
		baseTrialParams.Media.Image(j).Attr = experimentStimulusVars.choiceAttr;
	else
		baseTrialParams.Media.Image(j).Attr = experimentStimulusVars.cueAttr;
	end
	
	
    if strcmp(listOfConditions{RGB(j,4)},'choices')
        % save a placeholder image instead of the stimulus image
        im = zeros(10,10,3);
		neuronPeakColor{RGB(j,5),4} = filename;
        save(filename,'im','Clut','experimentStimulusVars','RGBvals','stimNumber','conditionName','colorNumber')
    else
		im = imTemplate;
        save(filename,'im','Clut','experimentStimulusVars','RGBvals','stimNumber','conditionName','colorNumber') %,'condition')
		
    end
    
    %image = make_config_node(docNode, filename, [kofikoExpDir '\' filename '.mat'], conditionName); % Currently puts all images in one block
    %media.appendChild(image);
end

% Generate the choice structure
[baseTrialParams] = generate_choice_structure(baseTrialParams, experimentStimulusVars, neuronPeakColor, default_trial_params, Stimulating);

% Generate the block order list
[baseTrialParams] = generate_block_order(baseTrialParams, experimentStimulusVars, neuronPeakColor, default_trial_params);

% Add base trial parameters to the experiment file
% We need to keep these separate, as one will be used by the analysis functions
% and one will be used by the xml config file generator
AFC_config_gen(baseTrialParams, xmlFileName);
experimentStimulusVars.baseTrialParams = baseTrialParams;

%imwrite(exampleIm,'Stimulus example.tif','tif')
% Generate experiment file name and write
experimentStimFileName = strcat(expName,'- Stimulus Variables');
save(experimentStimFileName,'experimentStimulusVars')
save('Colors used in this experiment','experimentColorFile')
if ~testing
    
    warning('Kofiko may now be started')
    
    % Copy all the files to the backup directories and copy the experiment file
    % to the analysis folder
    
    copyfile(strcat(kofikoExpDir,'\','Stimulus example.tif'),controlLocalBackupFolder)
    copyfile(strcat(kofikoExpDir,'\','imList.xml'),controlLocalBackupFolder)
    copyfile(strcat(kofikoExpDir,'\','*.mat'),controlLocalBackupFolder)
    copyfile(strcat(kofikoExpDir,'\','Stimulus example.tif'),backupFolder)
    copyfile(strcat(kofikoExpDir,'\','imList.xml'),backupFolder)
    copyfile(strcat(kofikoExpDir,'\','*.mat'),backupFolder)
    mkdir(analysisDir)
    copyfile(strcat(kofikoExpDir,'\','*-*'),analysisDir)
    
    % Go back to the starting folder
    
end

% =================================================================================================================================
% Subfunctions

function AFC_config_gen(struct_in, xmlFileName)


%generated_config = [];

docNode = com.mathworks.xml.XMLUtils.createDocument('Config');
root = docNode.getDocumentElement;
base_fields = fieldnames(struct_in);
for iStruct = 1:numel(base_fields)
    element_to_add = docNode.createElement(base_fields{iStruct});
    [docNode, element_to_add] = recursive_structure_loop(struct_in.(base_fields{iStruct}), base_fields{iStruct}, element_to_add, docNode);
    root.appendChild(element_to_add);
    
end

xmlwrite(xmlFileName, docNode);

		
function [docNode, current_element] = recursive_structure_loop(input, name_of_input, current_element, docNode)


% Handle special cases, I.E. structs with more than one dimension
[x, y] = size(input);
if x > 1 || y > 1 
	for iX = 1 : x
		for iY = 1 : y
			sub_element_to_add = docNode.createElement(name_of_input);
			[docNode, element_to_add] = recursive_structure_loop(input(iX , iY), name_of_input, sub_element_to_add, docNode);
			current_element.appendChild(element_to_add);
		end
	end
else
    [fields, is_struct, is_terminal_struct] = check_if_structure(input);
	if is_struct && ~is_terminal_struct
		
		for i = 1:numel(fields)
			% Handle special cases, don't make new element if next
			% structure to process is multidimensional
            [xSub, ySub] = size(input.(fields{i}));
            if xSub > 1 || ySub > 1
                [docNode, element_to_add] = recursive_structure_loop(input.(fields{i}), fields{i}, current_element, docNode);
            else
                sub_element_to_add = docNode.createElement(fields{i});	
                [docNode, element_to_add] = recursive_structure_loop(input.(fields{i}), fields{i}, sub_element_to_add, docNode);
                current_element.appendChild(element_to_add);
            end
		end
		
	elseif is_struct && is_terminal_struct
		for i = 1:numel(fields)  
			current_element.setAttribute(fields{i},input.(fields{i}));
		end
		
	elseif ~is_struct
		current_element.appendChild(element_to_add);
	end
end

function [value, is_struct, is_terminal_struct] = check_if_structure(input)
% Check if input is a structure, and whether it has substructures
if isstruct(input)
	value = fieldnames(input);
	is_struct = 1;
	is_terminal_struct = check_terminal_struct(input, fieldnames(input));
else
    value = input;
	is_struct = 0;
    is_terminal_struct = 1;
end

function is_terminal_struct = check_terminal_struct(input, fields_in_input)
% Check if structure has any further substructures
	is_terminal_struct = 1;
	for i = 1:numel(fields_in_input)
		if isstruct(input.(fields_in_input{i}))
			is_terminal_struct = 0;
		end
    end
	
	
function [baseTrialParams] = generate_choice_structure(baseTrialParams, experimentStimulusVars, neuronPeakColor, default_trial_params, Stimulating)

% define the trial types and choice locations
num_conditions = size(neuronPeakColor,2);
num_trialTypes = size(experimentStimulusVars.choiceLocations,1);

numBlocks = 1;
% Find the indices for correct and incorrect choices
correctChoiceIds = find([neuronPeakColor{:,3}] == 1);
incorrectChoiceIds = find([neuronPeakColor{:,3}] == 0);


% Calculate all permutations of stimulus combinations
choiceLocationHolder = npermutek(1:size(neuronPeakColor,1),size(experimentStimulusVars.choiceLocations,2));

% Make sure we have a correct choice in every trial



% Find Choice indexes in media



% Get indices to use for generating choices
if experimentStimulusVars.dont_repeat_choices_in_same_trial
    [choice_index, correct_choice_index] = find_repeat_values(choiceLocationHolder, correctChoiceIds, experimentStimulusVars);
    choice_indices_to_use = choice_index & correct_choice_index;
    choiceLocationHolder = choiceLocationHolder(choice_indices_to_use,:);

else
	choice_indices_to_use = find(choiceLocationHolder(:,:) == neuronPeakColor{neuronPeakColor(:,3) == 1}); % <----- doesnt work
    choiceLocationHolder = choiceLocationHolder(choice_indices_to_use,:);

end
% Seed the trials with the base parameters. If stimulating, seed that too while we're here
sizeToUse = size(choiceLocationHolder,1)*size(experimentStimulusVars.choiceCoordinates,2);
if Stimulating
	for i = 1:sizeToUse*2;
		baseTrialParams.TrialTypes.Trial(i) = default_trial_params.trialTypes.block1;
		if i > size(choiceLocationHolder,1)*size(experimentStimulusVars.choiceCoordinates,2)
			baseTrialParams.TrialTypes.Trial(i).(experimentStimulusVars.microStim.stimEpoch).Stimulation = experimentStimulusVars.microStim.Stimulation;
			baseTrialParams.TrialTypes.Trial(i).(experimentStimulusVars.microStim.stimEpoch).StimChannels = experimentStimulusVars.microStim.StimChannels;
		end
	end
			
else
	for i = 1:sizeToUse
		baseTrialParams.TrialTypes.Trial(i) = default_trial_params.trialTypes.block1;
	end
end



% Generate the choices

sizeChoiceCoords = size(experimentStimulusVars.choiceCoordinates,2);
sizeLocHolder = size(choiceLocationHolder,1);
for iLocations = 1:sizeChoiceCoords
	for iConditions = 1:sizeLocHolder

      
        correct_answer = find(ismember(choiceLocationHolder(iConditions,:) ,correctChoiceIds));
        % Name this trial; block # + which direction is correct
		
			trial_name = strcat('block',num2str(numBlocks),'_',experimentStimulusVars.choiceLocations{iLocations, correct_answer},'_correct');
            
                
        
        baseTrialParams.TrialTypes.Trial(numBlocks).Cue.CueValidAttributes = experimentStimulusVars.cueAttr;
		for iChoices = 1:size(choiceLocationHolder,2)
			baseTrialParams.TrialTypes.Trial(numBlocks).Choices.Choice(iChoices).Position = ...
				num2str(experimentStimulusVars.choiceCoordinates{iLocations,iChoices});
			
			baseTrialParams.TrialTypes.Trial(numBlocks).Choices.Choice(iChoices).SizePix =  ...
				num2str(experimentStimulusVars.defaultChoiceSize);
				
			baseTrialParams.TrialTypes.Trial(numBlocks).Choices.Choice(iChoices).JuiceReward = ...
				num2str(neuronPeakColor{choiceLocationHolder(iConditions,iChoices),3});
				
			baseTrialParams.TrialTypes.Trial(numBlocks).Choices.Choice(iChoices).Media = ...
				neuronPeakColor{choiceLocationHolder(iConditions,iChoices),4};
            if Stimulating
                blockID = numBlocks+(sizeLocHolder*sizeChoiceCoords);
				
				baseTrialParams.TrialTypes.Trial(blockID).Cue.CueValidAttributes = experimentStimulusVars.cueAttr;
                
                baseTrialParams.TrialTypes.Trial(blockID).Choices.Choice(iChoices).Position = ...
                num2str(experimentStimulusVars.choiceCoordinates{iLocations,iChoices});
            
                baseTrialParams.TrialTypes.Trial(blockID).Choices.Choice(iChoices).SizePix = ...
                num2str(experimentStimulusVars.defaultChoiceSize);
            
                baseTrialParams.TrialTypes.Trial(blockID).Choices.Choice(iChoices).JuiceReward = ...
                num2str(neuronPeakColor{choiceLocationHolder(iConditions,iChoices),3});
            
                baseTrialParams.TrialTypes.Trial(blockID).Choices.Choice(iChoices).Media = ...
                neuronPeakColor{choiceLocationHolder(iConditions,iChoices),4};
            
                baseTrialParams.TrialTypes.Trial(blockID).TrialParams.Name = ... 
                strcat('STIM-block',num2str(blockID),'_',experimentStimulusVars.choiceLocations{iLocations, correct_answer},'_correct');
            end
        end
      
       baseTrialParams.TrialTypes.Trial(numBlocks).TrialParams.Name = trial_name;
       numBlocks = numBlocks + 1;
    end
    
end

function [choice_index, correct_choice_index] = find_repeat_values(choiceLocationHolder, correctChoiceIds, experimentStimulusVars)
choice_index = ones(size(choiceLocationHolder,1),1);
correct_choice_index = zeros(size(choiceLocationHolder,1),1);

for x = 1:size(choiceLocationHolder,1)
    for i = 1:size(choiceLocationHolder,2)
        for z = 1:size(choiceLocationHolder,2)
            if i == z 
                continue
            else
                
                if choiceLocationHolder(x,i) == choiceLocationHolder(x,z)
                    choice_index(x) = 0;
                end
                if ismember(choiceLocationHolder(x,i),correctChoiceIds)
                    correct_choice_index(x) = 1;
                end
                if experimentStimulusVars.only_one_correct_answer && ismember(choiceLocationHolder(x,i),correctChoiceIds) && ismember(choiceLocationHolder(x,z),correctChoiceIds)
                  choice_index(x) = 0;
                end
            end
        end
    end
end
choice_index = logical(choice_index);
correct_choice_index = logical(correct_choice_index);


function [baseTrialParams] = generate_block_order(baseTrialParams, experimentStimulusVars, neuronPeakColor, default_trial_params);

if size(baseTrialParams.TrialTypes,2) == 1 && size(baseTrialParams.TrialTypes.Trial,2) == 1
    baseTrialParams.TrialOrder.Block.Types = baseTrialParams.TrialTypes.Trial(1).TrialParams.Name;
    return
end


allNames = baseTrialParams.TrialTypes(1).Trial(1).TrialParams.Name;
baseTrialParams.TrialOrder.Block(2).Types = baseTrialParams.TrialTypes.Trial(1).TrialParams.Name;
baseTrialParams.TrialOrder.Block(2).NumTrials = num2str(experimentStimulusVars.trialOrderVars.NumTrials);
baseTrialParams.TrialOrder.Block(2).RepeatIncorrect = num2str(experimentStimulusVars.trialOrderVars.RepeatIncorrect);
	for i = 2:size(baseTrialParams.TrialTypes.Trial,2)
		allNames = [allNames ';' baseTrialParams.TrialTypes.Trial(i).TrialParams.Name];
		baseTrialParams.TrialOrder.Block(i+1).Types = baseTrialParams.TrialTypes.Trial(i).TrialParams.Name;
		baseTrialParams.TrialOrder.Block(i+1).NumTrials = num2str(experimentStimulusVars.trialOrderVars.NumTrials);
		baseTrialParams.TrialOrder.Block(i+1).RepeatIncorrect = num2str(experimentStimulusVars.trialOrderVars.RepeatIncorrect);
	end
baseTrialParams.TrialOrder.Block(1).Types = allNames;
baseTrialParams.TrialOrder.Block(1).NumTrials = num2str(experimentStimulusVars.trialOrderVars.NumTrials);
baseTrialParams.TrialOrder.Block(1).RepeatIncorrect = num2str(experimentStimulusVars.trialOrderVars.RepeatIncorrect);























