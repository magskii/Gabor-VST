

function gaborScreen = drawGabors(nGabs,freq,sigma,contrast,angle,patchSize,gabRects,circle,height,width);


theta = deg2rad(angle);
gaborScreen = ones(height,width)*128;

for gab = 1:nGabs
    
    gabRect = gabRects(:,gab);
    cFreq = freq(gab);
    cSigma = sigma(gab);
    cContrast = contrast(gab);
    cTheta = theta(gab);
    
    for i = 1:patchSize % y
        for j = 1:patchSize % x
            cy = (i - (patchSize/2))/60;
            cx = (j - (patchSize/2))/60;
            y_theta = -cx*sin(cTheta)+cy*cos(cTheta);
            x_theta = cx*cos(cTheta)+cy*sin(cTheta);
            sincomp = cos(2*pi*cFreq*x_theta);
            gausscomp = exp(-.5*(x_theta.^2/cSigma^2+y_theta.^2/cSigma^2));
            gabor(i,j) = (sincomp*gausscomp)*cContrast;
            gabortex(i,j) = round((((gabor(i,j)+1)/2)*255)+0.5);
            if gabortex(i,j) > 255
                gabortex(i,j) = 255;
            end
            % draw to screen mat
            if circle(i,j) == 1
                gaborScreen(i+gabRect(2),j+gabRect(1)) = gabortex(i,j);
            end
        end
    end
end

gaborScreen = cur2lin(gaborScreen);

end


