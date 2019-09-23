% Takes 'desired' linear luminance matrix (or vector / single value) (e.g. 0-255), compares to measured
% screen luminance curve, and outputs actual linear luminance you need to
% input.

% Must run program 'lightMeasure.m' first, which outputs workspace
% 'lumLevels.mat'. Contains variable 'stepVect', which is just a column of
% linear luminance values (1), and a column of corresponding measured
% values (2).

% Output:
%   linLum = actual value (0-255) you need to input to get desired
%   luminance. E.g. if you want mid-grey (128), it works out mid-grey in
%   terms of measured cd/m2, then converts back to a 0-255 scale.

%load('test');
%curLum = imageLum;

function linLum = cur2lin(curLum)

load('lumLevels');

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

end