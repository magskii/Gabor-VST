function obCrash = tooClose(n,obLocs,obSize,gap,newX,newY)

% Checks a new object doesn't overlap any objects already generated.

% Inputs:
%       n = number of objects so far.
%       obLocs = location matrix of centre points of all objects to check against.
%       obSize = radius of objects
%       gap = gap between objects (pixels)
%       [newY,newX] = centre co-ordinates of potential new object.
% Output:
%       obCrash = logical output; 0 = no crash, 1 = crash.


obCrash = 0;

for j = 1:n  % compare the potential co-ordinate to each co-ordinate already generated
    
    c = hypot(newX-obLocs(1,j),newY-obLocs(2,j)); % just pythagoras
    
    if c < ((obSize*2)+gap) % if the hypotenuse is shorter than 2*object diameter (plus however much of a gap you want), the objects will crash...
        
        obCrash = 1; % ...so input true value
        
    end
    
end


end