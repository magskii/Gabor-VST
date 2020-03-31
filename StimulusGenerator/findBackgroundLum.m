% find background lum level

clear all


% contrasts:
low = [96,160]; % 0.25
high = [0,255]; % 1
lowContrast = (low(2) - low(1)) / (low(1) + low(2)); % 'normal' contrast level
highContrast = (high(2) - high(1)) / (high(1) + high(2)); % distractor contrast level


curLum = 255;

load('lumLevels')

curLum = double(curLum); % in case image files in wrong format for feval

% fit curve to input luminance (y) and measured luminance (x)
fitobject = fit(stepVect(:,2),stepVect(:,1),'smoothingspline');

% convert to percentages
curDiff = stepVect(length(stepVect),1)-stepVect(1,1);
cdmDiff = stepVect(length(stepVect),2)-stepVect(1,2);
curLum = curLum/curDiff; % turn curLum into a percentage
cdm = (cdmDiff*curLum)+stepVect(1,2); % get that percentage in terms of cd/m2


% get output
for i = 1:length(curLum)
    
    linLum(:,i) = feval(fitobject,cdm(:,i)); % read off corresponding linear luminance value

end

linLum = round(linLum);

