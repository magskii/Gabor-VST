
function obCrash = obComp(index,obCoords,obSize,gap)

% Takes index of an object in an existing matrix and checks if it crashes into other things in the matrix.

% Inputs:
%       index = of object to check, from obLocs
%       obLocs = location matrix of centre points of all objects to check against
%       obSize = radius of objects
%       gap = desired gap between objects (pixels)
% Output:
%       obCrash = matrix, logical output; 0 = no crash, 1 = crash.
%           NB: object will not be compared with itself, so will remain zero


obCrash = zeros(1,size(obCoords,2));

for j = 1:size(obCoords,2)  % compare the potential co-ordinate to each co-ordinate already generated
    
    if j ~= index %&& j ~= 1
        
        c = hypot(obCoords(1,j)-obCoords(1,index),obCoords(2,j)-obCoords(2,index)); % just pythagoras
        
        if c < ((obSize*2)+gap) % if the hypotenuse is shorter than 2*object diameter (plus however much of a gap you want), the objects will crash...
            
            obCrash(j) = 1; % ...so input true value
            
        end
        
    end
    
end

end