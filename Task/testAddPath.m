% test add path


folderName = ['/Users/rrm9/Documents/GitProjects/Gabor-VST/StimulusGenerator/Exp1/P1'];
addpath(folderName);

format long g
    fileName = ['expNo',num2str(expNo),'_PN',num2str(PN),'_tOri',num2str(shuffleMat(i,6)),'_',num2str(shuffleMat(i,2:4)),'_rep',num2str(shuffleMat(i,5))];
    saveData = importdata([fileName,'.csv']);