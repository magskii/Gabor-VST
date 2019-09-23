% gabor test


nGabs = 1;
freq = 1;
sigma = 1;
contrast = 0.25;
patchSize = 360;
angle = 45;



% screen set-up:
Screen('Preference', 'SkipSyncTests', 1);
screenMax = max(Screen('Screens'));
% set up for alpha blending - allows overlapping gabors and removes square edges:
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
PsychImaging('AddTask', 'General', 'UseRetinaResolution'); % also use entire display pixel capactiy
% more screen set-up:
[w,rect] = PsychImaging('OpenWindow', screenMax, cur2lin(128));
[xCenter,yCenter]=RectCenter(rect);
[width, height] = RectSize(rect);



cutD = 360;
framecirc = [0,0,cutD,cutD];
patchRect = [0,0,patchSize,patchSize];
framecirc = CenterRectOnPoint(framecirc,xCenter,yCenter);
patchRect = CenterRectOnPoint(patchRect,xCenter,yCenter);
Screen('FillOval',w,1,framecirc);
circle = Screen('GetImage',w,[],'drawBuffer');
circle = circle(patchRect(2):patchRect(4),patchRect(1):patchRect(3));


gabormat = drawGabors(nGabs,freq,sigma,contrast,angle,patchSize,patchRect',circle,height,width);
gabor = gabormat(patchRect(2):patchRect(4),patchRect(1):patchRect(3));
gabortex = Screen('MakeTexture', w, gabor);
Screen('DrawTexture', w, gabortex);
imageRGB = Screen('GetImage',w,[],'drawBuffer');
imwrite(imageRGB,['45.png']);

Screen('Flip',w);
KbWait;

Priority(0);
sca;


