%
%PAL_AMPM_Demo  Demonstrates use of Palamedes routines to implement a
%'Psi Method' adaptive procedure. Program completes a run of 50 total
%trials. Halfway (after 25 trials) run is interrupted, intermediate results
%are stored to disk, RAM memory is cleared, intermediate results are
%reloaded from disk, and run continues (as if observer runs 2 sessions on
%separate occassions). The posterior from first session serves as the prior
%to second session.
%
%Demonstrates usage of Palamedes functions:
%-PAL_AMPM_setupPM
%-PAL_AMPM_updatePM
%secondary:
%PAL_Gumbel
%PAL_pdfNormal
%
%More information on any of these functions may be found by typing
%help followed by the name of the function. e.g., help PAL_AMPM_setupPM
%
%NP (September 2009)

clear all;  %Clear all existing variables from memory

if exist('OCTAVE_VERSION');
    fprintf('\nUnder Octave, Figure does not render exactly as intended. Visit\n');
    fprintf('www.palamedestoolbox.org/demosfiguregallery.html to see figure\n');
    fprintf('as intended.\n\n');
end

%Simulated observer's characteristics
PFsimul = @PAL_Gumbel;
trueParams = [0 2 .5 .01];

%Set up Psi Method procedure:

%Define prior
priorAlphaRange = -2:.02:2; %values of alpha to include in prior
priorBetaRange = -1:.02:1;  %values of log_10(beta) to include in prior

%Stimulus values to select from (need not be equally spaced)
stimRange = [-.5:.05:.5];   
                            
%2-D Gaussian prior
prior = repmat(PAL_pdfNormal(priorAlphaRange,0,1), ...
    [length(priorBetaRange) 1]).* repmat(PAL_pdfNormal...
    (priorBetaRange',0,1),[1 length(priorAlphaRange)]);

prior = prior./sum(sum(prior)); %prior should sum to 1

%Function to be fitted during procedure
PFfit = @PAL_Gumbel;    %Shape to be assumed
gamma = 0.5;            %Guess rate to be assumed
lambda = .01;           %Lapse Rate to be assumed

%set up procedure
PM = PAL_AMPM_setupPM('priorAlphaRange',priorAlphaRange,...
    'priorBetaRange',priorBetaRange, 'numtrials',25, 'PF' , PFfit,...
    'prior',prior,'stimRange',stimRange,'gamma',gamma,'lambda',lambda);

%Show contour plot of posterior
figure('name','Psi Method Adaptive Procedure');
subplot(2,1,1)
contour(PM.pdf,15)  %PM.pdf stores the posterior (which at this point 
                    %is the prior)
h1 = gca;
set(h1,'FontSize',16, 'Xtick',[1:50:201], 'XtickLabel', {'-2','-1','0',...
    '1','2'}, 'Ytick',[1:25:101], 'YtickLabel', {'-1','-.5','0','.5','1'});
xlabel('Alpha');
ylabel('Log(Beta)');
drawnow

%Trial loop

while PM.stop ~= 1

    %Present trial here at stimulus intensity UD.xCurrent and collect
    %response
    %Here we simulate a response instead (0: incorrect, 1: correct)    

    response = rand(1) < PFsimul(trueParams, PM.xCurrent);
    PM = PAL_AMPM_updatePM(PM,response);

    %Update plot
    contour(h1,PM.pdf,15);
    set(gca,'FontSize',16, 'Xtick',[1:50:201], 'XtickLabel', {'-2','-1',...
        '0','1','2'}, 'Ytick',[1:25:101], 'YtickLabel', {'-1','-.5','0',...
        '.5','1'});
    xlabel('Alpha');
    ylabel('Log(Beta)');
    drawnow
end

save savedPM PM     %by saving PM structure all data are saved
clear all           %this clears all variables from memory (as if you were 
                    %to shut down Matlab).
load savedPM        %load PM structure to pick up where you left off

%Simulated observer's characteristics (these were deleted by 'clear all')
PFsimul = @PAL_Gumbel;
trueParams = [0 2 .5 .01];

%Change stop rule to 50 trials (total) and set PM.stop back to 0.
%In effect, this uses posterior of previous session as prior for new
%session.

PM = PAL_AMPM_setupPM(PM,'numtrials',50);
PM.stop = 0;

%Trial loop

while PM.stop ~= 1
    response = rand(1) < PFsimul(trueParams, PM.xCurrent);
    PM = PAL_AMPM_updatePM(PM,response);
    contour(PM.pdf,15);
    set(gca,'FontSize',16, 'Xtick',[1:50:201], 'XtickLabel', {'-2','-1',...
        '0','1','2'}, 'Ytick',[1:25:101], 'YtickLabel', {'-1','-.5','0',...
        '.5','1'});
    xlabel('Alpha');
    ylabel('Log(Beta)');
    drawnow
end

%Print summary of results to screen
message = sprintf('\rThreshold estimate as marginal mean of posterior');
message = strcat(message, sprintf(': %6.4f',...
    PM.threshold(length(PM.threshold))));
disp(message);
message = sprintf('Slope estimate as marginal mean of posterior (Log units)');
message = strcat(message, sprintf(': %6.4f',...
    PM.slope(length(PM.slope))));
disp(message);
message = sprintf('Threshold standard error as marginal sd of posterior');
message = strcat(message, sprintf(': %6.4f',...
    PM.seThreshold(length(PM.seThreshold))));
disp(message);
message = sprintf('Slope standard error as marginal sd of posterior (Log units)');
message = strcat(message, sprintf(': %6.4f',...
    PM.seSlope(length(PM.seSlope))));
disp(message);

message = sprintf('\rThreshold estimate as marginal mean of posterior us');
message = strcat(message, sprintf('ing uniform prior: %6.4f',...
    PM.thresholdUniformPrior(length(PM.thresholdUniformPrior))));
disp(message);
message = sprintf('Slope estimate as marginal mean of posterior (Log units)');
message = strcat(message, sprintf(': %6.4f',...
    PM.slopeUniformPrior(length(PM.slopeUniformPrior))));
disp(message);
message = sprintf('Threshold standard error as marginal sd of posterio');
message = strcat(message, sprintf('r using uniform prior: %6.4f',...
    PM.seThresholdUniformPrior(length(PM.seThresholdUniformPrior))));
disp(message);
message = sprintf('Slope standard error as marginal sd of posterior us');
message = strcat(message, sprintf('ing uniform prior (Log units): %6.4f',...
    PM.seSlopeUniformPrior(length(PM.seSlopeUniformPrior))));
disp(message);

%Create simple plot of trial sequence:
subplot(2,1,2)
t = 1:length(PM.x)-1;
plot(t,PM.x(1:length(t)),'k');
hold on;
plot(1:length(t),PM.threshold,'b-','LineWidth',2)
plot(t(PM.response == 1),PM.x(PM.response == 1),'ko', ...
    'MarkerFaceColor','k');
plot(t(PM.response == 0),PM.x(PM.response == 0),'ko', ...
    'MarkerFaceColor','w');
set(gca,'FontSize',16);
maxinplot = max(max(PM.x),max(PM.threshold));
mininplot = min(min(PM.x),min(PM.threshold));
axis([0 max(t)+1 mininplot-(maxinplot-mininplot)/10 ...
    maxinplot+(maxinplot-mininplot)/10]);
line([1 length(PM.x)], [trueParams(1) trueParams(1)],'linewidth', 2,...
    'linestyle', '--', 'color','k');
xlabel('Trial');
ylabel('Stimulus Intensity');