function obLocs = genObCents(obNum,obSize,gap,scrWidth,scrHeight)

% Creates randomly placed midpoints for non-overlapping circular objects.

% Inputs:
%       obNum = number of objects
%       obSize = radius of circles
%       gap = gap between objects (pixels)
%       [scrWidth,scrHeight] = width and height (pixels) of area for object generation
% Outputs:
%       obLocs = Matrix of [x;y] co-ordinates, a new object location in each column.
%       If there are too many objects, the output (obLocs) will default to 0.



% set up object location matrix
obLocs = repmat([0;0],[1,obNum]);

%set up while loop in case you need to start again due to large number of objects
finished = 0;
startAgainCount = 0;

while finished == 0
    
    finished = 1; %if all goes well, this will stay at 1 and the loop will end first time
    
    for i = 1:obNum % do for every new object
        
        errorCount = 0;
        
        while 1 % keep doing this while loop until you get a co-ordinate that doesn't overlap other objects
            
            % generate potential new object centre
            newX = randi([scrWidth(1),scrWidth(2)],[1,1]);
            newY = randi([scrHeight(1),scrHeight(2)],[1,1]);
            
            obCrash = tooClose(i,obLocs,obSize,gap,newX,newY);
            
            if obCrash == 1 % object crashed...
                
                errorCount = errorCount+1; % ...so add it to error count
                
                if errorCount > 100 % if it's crashed too many times
                    
                    finished = 0; % revert finished so have to start again once over
                    startAgainCount = startAgainCount+1;
                    
                    break %get out of this loop
                    
                end
                
            else % object clear...
                
                break % ...so get out of loop without changing anything
                
            end
            
        end
        
        obLocs(:,i) = [newX;newY]; % add new distractor to gabor location matrix
        
    end
    
    if startAgainCount > 50 % if you've had to start again too many times, finish and make obLocs = 0, so code won't work or can add catch
        
        fprintf('\nFNCTgenObCents: Too many objects.\n')
        finished = 1;
        obLocs = 0;
        
    end
    
end


end
