% gaborGen
% Generates textures for a visual search task among Gabor patches.

% Targets:
%       Gabors of a specific orientation.
%       Usually only one target per screen, but this can be varied.
% Background:
%       Filled with x number of Gabors of random orientations.
%       Always differ from target orientation by x degrees.
% Distractors:
%       Either have high luminance contrast with the other Gabors or are similar to target orientation.
%       They can be generated near target Gabors and/or near background Gabors.
%       X number can be generated for each trial, and this can be controlled separately for distractors near targets or in background.

% REQUIRED toolboxes:
%   Curve Fitting Toolbox
% REQUIRED function files:
%   genObCents
%   tooClose
%   cur2lin
%   obComp
% REQUIRED variable files:
%   lumLevels (generated by lightMeasure program)


clear all;

% ----------------------------------------------------------------- %

% EXPERIMENTAL STUFF

nP = 1; % number of participants
nReps = 10; % number of repetitions per trial type
expNo = 2; % 1 = contrast distractors; 2 = orientation distractors

% trial matrix just for this specific experiment:
tMat = [
    1,0,0,0
    0,1,0,0
    0,2,0,0
    0,0,1,1
    0,0,1,2
    0,0,2,1
    0,0,2,2
    0,1,1,1
    0,2,2,1
    ];
% col1 = control; logical, 0 = experimental trial and 1 = control trial
% col2 = nDistsNearTarg; how many distractors generated near the target?
% col3 = nDistsNearBacks; how many distractors generated near each selected background gabor
% col4 = nBacksWithDists; how many background gabors selected for distractor generation

% % can comment out trial matrix loop (below) and just use these for simpler control
% control = 0;
% nDistsNearTarg = 0;
% nDistsNearBacks = 0;
% nBacksWithDists = 0;


% ----------------------------------------------------------------- %

% MAKE FOLDERS

% generate folder specifying which experiment:
EfolderName = ['Exp',num2str(expNo)];
mkdir(EfolderName);
% generate a folder for each participant wihtin experiment folder:
for i = 1:nP
    PfolderName = ['P',num2str(i)];
    mkdir(EfolderName,PfolderName)
end


% ----------------------------------------------------------------- %

% PSYCHTOOLBOX JAZZ

% screen set-up:
Screen('Preference', 'SkipSyncTests', 1);
screenMax = max(Screen('Screens'));
% set up for alpha blending - allows overlapping gabors and removes square edges:
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
PsychImaging('AddTask', 'General', 'UseRetinaResolution'); % also use entire display pixel capactiy
% more screen set-up:
[w,rect] = PsychImaging('OpenWindow', screenMax, 0);
[xCenter,yCenter]=RectCenter(rect);
[width, height] = RectSize(rect);


% ----------------------------------------------------------------- %

% GABOR SPECS

%gabor numbers:
tNum = 1; % targets
bNum = 74; % backgrounds
patchNum = tNum+bNum;
% set size of gabors based on size of screen:
patchSize = round(sqrt((width*height)*0.0088)); % width and height of gabor patch in pixels - arbitrary area of 0.0088% of screen area seems to work
gabSize = 140; % this is actually wrong - diameter will be more like 340
gaborrect = [0,0,patchSize,patchSize];
% gap stuff:
gap = patchSize/10; % minimum gap between gabors
distsGap = patchSize/1.8; % max gap between target/background gabors and distractors
% set up screen ranges so gabors don't go off edge:
borderGap = patchSize/6; % gap around edge of screen
wRange = [0+gabSize+borderGap, width-gabSize-borderGap];
hRange = [0+gabSize+borderGap, height-gabSize-borderGap];
% contrasts:
low = [96,160]; % 0.25
high = [0,255]; % 1
lowContrast = (low(2) - low(1)) / (low(1) + low(2)); % 'normal' contrast level
highContrast = (high(2) - high(1)) / (high(1) + high(2)); % distractor contrast level
% orientations:
tOri = 315; % target orientation, i.e. gabor phase, in degrees
backDiff = 40; % minimum orientation difference (degrees) between background gabors and target
minDistDiff = 20; % minimum orientation difference (degrees) between distractor gabors and target
maxDistDiff = 25; % maximum orientation difference (degrees) between background gabors and target
bOri = datasample(tOri+backDiff:180+tOri-backDiff,bNum); % generate background orientation vector
dOriRange = [tOri-maxDistDiff:tOri-minDistDiff,tOri+minDistDiff:tOri+maxDistDiff]; % matrix of possible orientations for distractor gabors
% boring sin/gauss stuff:
sigma = 1;
freq = 1;


% ----------------------------------------------------------------- %

% Set up circle for cutting out Gabors

cutD = 360;
framecirc = [0,0,cutD,cutD];
patchRect = [0,0,patchSize,patchSize];
framecirc = CenterRectOnPoint(framecirc,xCenter,yCenter);
patchRect = CenterRectOnPoint(patchRect,xCenter,yCenter);
Screen('FillOval',w,1,framecirc);
circle = Screen('GetImage',w,[],'drawBuffer');
circle = circle(patchRect(2):patchRect(4),patchRect(1):patchRect(3));
Screen('Flip',w);


% ----------------------------------------------------------------- %

% GABOR STUFF FOR ALL CONDITIONS

for trialType = 1:size(tMat,1) % trial matrix loop
    
    % set trial type according to tMat
    control = tMat(trialType,1);
    nDistsNearTarg = tMat(trialType,2); % how many distractors near the target
    nDistsNearBacks = tMat(trialType,3); % how many distractors near each selected background gabor
    nBacksWithDists = tMat(trialType,4); % how many background gabors selected for distractor generation
    
    for PN = 1:nP
        
        for rep = 1:nReps
            
            propMat = repmat([freq, sigma, lowContrast]',[1,patchNum]); % combine gabor specifications into matrix for drawing
            propMat = [propMat;tOri,bOri];
            
            targTry = 0;
            while 1 % come back to here for gabor re-generation if the target doesn't have enough potential distractors around it
                gabTry = 0;
                while 1 % come back here if gabors don't fit
                    % create random gabor locations:
                    gabLocs = genObCents(patchNum,gabSize,gap,wRange,hRange);
                    % a catch for if you've tried to input too many Gabors to genObCents:
                    if gabLocs == 0
                        gabTry = gabTry+1;
                        if gabTry > 20 % if tried too many times, get out
                            sca;
                            error('Please reduce number of Gabors!')
                        end
                    else
                        % centre gabors on these random locations:
                        randRects = repmat(gaborrect',[1,patchNum]);
                        randRects = CenterRectOnPoint(randRects,gabLocs(1,:),gabLocs(2,:));
                        break
                    end
                end
                
                if control == 1 % if a control condition, can get out now
                    break
                end
                
                % ----------------------------------------------------------------- %
                
                % EXPERIMENTAL CONDITIONS
                
                % check which background gabors are near the target
                nearTarg = obComp(1,gabLocs,gabSize,distsGap); % if an element of nearTarg is true, it is sufficiently near the target to be a distractor
                if nnz(nearTarg) < nDistsNearTarg % if there aren't enough distractors near target, regenerate gabors... could edit to just pick another existant gabor, but effort
                    targTry = targTry+1;
                    if targTry > 20 % if you've tried too many times, get outta there
                        sca;
                        error('Not enough distractors surrounding target!')
                    end
                else % if we're all good, move on
                    break
                end
            end
            
            distMat = []; % reset distractors
            % generate distractors near target:
            for i = 1:nDistsNearTarg
                dist = datasample(find(nearTarg),1); % choose random gabor near target
                distMat(i) = dist; % index of the distractor co-ordinates in gabLocs
                switch expNo
                    case 1 % increase contrast
                        propMat(3,dist) = highContrast;
                        nearTarg(dist) = 0;
                    case 2 % make orientation more similar to target
                        dOri = datasample(dOriRange,1);
                        propMat(4,dist) = dOri;
                        nearTarg(dist) = 0;
                        % propMat(3,dist) = highContrast; % tester to also make high contrast
                end
            end
            nearTarg(1) = 1; % so doesn't get picked for distractor generation
            
            % generate distractors near background gabors:
            for i = 1:nBacksWithDists
                distTry = 0;
                while 1 % come back to here if the selected background gabor doesn't have enough potential distractors around it
                    dist = datasample(find(~nearTarg(1+tNum:patchNum)),1)+tNum; % pick random background gabor which isn't near the target
                    nearDist = obComp(dist,gabLocs(:,1:patchNum),gabSize,distsGap); % if an element of nearDist is true, it is sufficiently near the distractor to be a distractor
                    nearDist(1) = 0;
                    if nnz(nearDist) < nDistsNearBacks % if there aren't enough gabors surrounding the selected background gabor, go back and pick another one
                        distTry = distTry+1;
                        if distTry > 20 %if you've tried too many times, give up
                            sca;
                            error('Not enough distractors surrounding distractor!')
                        end
                    else % if there are enough surrounding gabors, need to check if any of them are already distractors
                        if ~any(dist == distMat) % if they're not, move on
                            nearTarg(dist) = 1; % make it look like it's near the target so it won't be selected again
                            break % move on, yo
                        end
                    end
                end
                for j = 1:nDistsNearBacks
                    while 1
                        metaDist = datasample(find(nearDist),1); % pick random gabor near selected background gabor
                        % need to check if it's already a distractor
                        if ~any(metaDist == distMat) % if they're not, move on
                            break % move on, yo
                        end
                    end
                    distMat = [distMat,metaDist]; % record distractor index
                    switch expNo
                        case 1 % increase contrast
                            propMat(3,metaDist) = highContrast;
                            nearDist(metaDist) = 0; % can't be selected again
                        case 2  % make orientation more similar to target
                            dOri = datasample(dOriRange,1);
                            propMat(4,metaDist) = dOri;
                            nearDist(metaDist) = 0; % can't be selected again
                            % propMat(3,metaDist) = highContrast; % tester to also make high contrast
                    end
                end
            end
            
            % actually draw stuff:
            gabormat = drawGabors(patchNum,propMat(1,:),propMat(2,:),propMat(3,:),propMat(4,:),patchSize,randRects,circle,height,width);
            gabortex = Screen('MakeTexture', w, gabormat);
            Screen('DrawTexture', w, gabortex);
            imageRGB = Screen('GetImage',w,[],'drawBuffer');
            
            
            % ----------------------------------------------------------------- %
            
            % SAVE STUFF
            
            % names and places:
            folderName = ['Exp',num2str(expNo),'/P',num2str(PN),'/'];
            fileName = ['expNo',num2str(expNo),'_PN',num2str(PN),'_tOri',num2str(tOri),'_',num2str(nDistsNearTarg),num2str(nDistsNearBacks),num2str(nBacksWithDists),'_rep',num2str(rep)];
            % what to save:
            imwrite(imageRGB,[folderName,fileName,'.png']);
            save([folderName,fileName,'.mat'],'gabormat');
            distractors = zeros(1,size(gabLocs,2))
            distractors(distMat) = 1;
            saveData = [gabLocs;propMat(3:4,:);distractors];
            csvwrite([folderName,fileName,'.csv'],saveData);
            
            Screen('Flip', w);
            
        end
        
    end
    
end



% ----------------------------------------------------------------- %

% close psychtoolbox
Priority(0);
sca;