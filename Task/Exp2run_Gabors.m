% gaborirl
% Participants must locate the target Gabor, and move the mouse to click it.




clear all;



% ----------------------------------------------------------------- %

% EXPERIMENTAL STUFF

PN = input('Participant Number: ')

expNo = 2;
nReps = 10;
angle1 = 45;
angle2 = 315;
circSize = 270;

% ----------------------------------------------------------------- %

% INPUT SET UP

folderName = ['/Users/rrm9/Documents/GitHub/Gabor-VST/StimulusGenerator/Exp',num2str(expNo),'/P',num2str(PN)];
addpath(folderName);
format long g

% trial matrix just for this specific experiment:
tMatSingle = [
    1,0,0,0,1
    0,1,0,0,1
    0,2,0,0,1
    0,0,1,1,1
    0,0,1,2,1
    0,0,2,1,1
    0,0,2,2,1
    0,1,1,1,1
    0,2,2,1,1
    ];
% col1 = control; logical, 0 = experimental trial and 1 = control trial
% col2 = nDistsNearTarg; how many distractors generated near the target?
% col3 = nDistsNearBacks; how many distractors generated near each selected background gabor
% col4 = nBacksWithDists; how many background gabors selected for distractor generation

nTrials = size(tMatSingle,1);
tMat = tMatSingle;
for j = 2:nReps
    tMatSingle(:,5) = j;
    tMat = [tMat;tMatSingle];
end
tMat = [tMat,zeros(nTrials*nReps,4)];


% ----------------------------------------------------------------- %

% PSYCHTOOLBOX JAZZ

% screen set-up
Screen('Preference', 'SkipSyncTests', 1); % don't care about timing, so skipping sync tests is fine for now
screenMax = max(Screen('Screens')); % set screen to be external display if applicable
% set up for alpha blending - allows overlapping gabors and removes square edges
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
PsychImaging('AddTask', 'General', 'UseRetinaResolution'); % also use entire display pixel capactiy
% more screen set-up
[w,rect] = PsychImaging('OpenWindow', screenMax, cur2lin(128));
[xCenter,yCenter]=RectCenter(rect); % screen center co-ordinates
[width, height] = RectSize(rect); % window size for easy referral


% ----------------------------------------------------------------- %

% deg45 = imread('45.png');
% deg315 = imread('315.png');


% EXPERIMENT

for i = 1:1
    
    switch i
        case 1
            angle = angle1;
            trialBreak = ['one quarter '];
        case 2
            angle = angle2;
            trialBreak = ['three quarters '];
    end
    imName = [num2str(angle),'.png'];
    image = imread(imName);
    Screen('PutImage',w,image);
    Screen('TextSize',w,100);
    DrawFormattedText(w,['Find the patch with this orientation:'],'center',(rect(4)/2)-300);
    DrawFormattedText(w,['Press any key to continue.'],'center',(rect(4)/2)+400);
    Screen('Flip',w);
    KbWait;
    
    shuffle = randperm(size(tMat,1));
    shuffleMat = tMat(shuffle,:);
    shuffleMat(:,6) = angle;
    
    for j = 1:size(shuffleMat,1)
        
        %load in stuff
        fileName = ['expNo',num2str(expNo),'_PN',num2str(PN),'_tOri',num2str(shuffleMat(j,6)),'_',num2str(shuffleMat(j,2)),num2str(shuffleMat(j,3)),num2str(shuffleMat(j,4)),'_rep',num2str(shuffleMat(j,5))];
        saveData = importdata([fileName,'.csv']);
        load(fileName);
        
        % set up circle texture for later
        for k = 1:size(saveData,2)
            circleRects(:,k) = [saveData(1,k)-(circSize/2),saveData(2,k)-(circSize/2),saveData(1,k)+(circSize/2),saveData(2,k)+(circSize/2)];
            borderRects(:,k) = [saveData(1,k)-(circSize/2)-10,saveData(2,k)-(circSize/2)-10,saveData(1,k)+(circSize/2)+10,saveData(2,k)+(circSize/2)+10];
        end
        
        %display fixation scross for 75ms
        HideCursor;
        Screen('TextSize',w,300);
        fixCross = '+';
        DrawFormattedText(w,fixCross,'center','center');
        fixCrossOnset = Screen('Flip',w);
        
        % draw trial
        gabortex = Screen('MakeTexture', w, gabormat);
        Screen('DrawTexture', w, gabortex);
        
        % flip and record
        SetMouse(width/4,height/4,w);
        targetOnset = Screen('Flip',w,fixCrossOnset+0.75);
        t0 = GetSecs;
        
        % wait for enter press
        [keyIsDown,secs,keyCode] = KbCheck;
        while keyCode(KbName('return')) == 0;
            [keyIsDown,secs,keyCode] = KbCheck;
        end
        t1 = GetSecs;
        
        % flip circles
        Screen('FrameOval',w,0,borderRects,10,10);
        Screen('FillOval',w,210,circleRects);
        Screen('Flip',w);
        
        % hide mouse until it's moved
        [x,y,buttons] = GetMouse(w);
        while (x == width/4) && (y == height/4)
            [x,y,buttons] = GetMouse(w);
        end
        ShowCursor(0);
        
        % record click co-ordinates
        [clicks,x,y] = GetClicks(w);
        while clicks == 0
            [clicks,x,y] = GetClicks(w);
        end
        x = x*2;
        y = y*2;
        
        %outputs
        RT = t1-t0;
        acc = tooClose(1,saveData(1:2,1),(circSize/2)-62,0,x,y);
        
        distMat = find(saveData(5,:)); % find which patches are distractors
        for hitDist = 1:size(distMat,2)
            distAcc = tooClose(1,saveData(1:2,distMat(hitDist)),(circSize/2)-62,0,x,y);
            if distAcc == 1
                shuffleMat(j,9) = distMat(hitDist);
            end
        end
        
        
        shuffleMat(j,7:8) = [RT,acc];
        
        % take a break
        if j == floor(size(shuffleMat,1)/2)
            Screen('TextSize',w,100);
            DrawFormattedText(w,['You have completed ',trialBreak,'of the trials.\nTake a break, then press any key to continue.'],'center','center');
            Screen('Flip',w);
            KbWait;
        end
        
        
    end
    
    fileName = [num2str(angle),'_PN',num2str(PN)];
    csvwrite([fileName,'.csv'],shuffleMat);
    
end


% ----------------------------------------------------------------- %

% close psychtoolbox
Priority(0);
sca;
