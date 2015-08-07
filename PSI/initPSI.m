function initPSI
%INITPSI Summary of this function goes here
%   Detailed explanation goes here

global stiPar
%%%%%Initialize PSI%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up the range for estimation
% minThres = 0.01;
% maxThres = 0.6;
% thresStep = 0.02;
% minSlope=.5;
% maxSlope=6;
% slopeStep = .25;

minThres = log10(0.01);
maxThres = log10(.5);
thresStep = .04;
minSlope=1;
maxSlope=4;
slopeStep = .25;

% Possible range to be presented in an experimental section
%These parameters are contrain of the monitor in luminence contrast
%experiment, In fact, there're no such constrain for glass pattern exp
% minCoherence = 0.01;
% maxCoherence = 1;
% cohStep = 0.02;
% pcorr=0.75;		% percentage correct at threshold
% miss = 0.04;	% miss level
% gamma = .5;		% Guessing factor. It is 0.5 for 2AFC

minContrast = log10(0.005);
maxContrast = log10(.9);
ContrastStep = 0.04;
pcorr = 0.74;    % percentage correct at threshold
miss  = 0.04;	% miss level
gamma = .5;		% Guessing factor. It is 0.5 for 2AFC

%function to set up PSI parameter structure
stiPar.PSI.PSIpar=PsiInit(minThres,maxThres,thresStep,...
    minSlope,maxSlope,slopeStep,minContrast,maxContrast,ContrastStep,...
    miss, gamma,pcorr);

stiPar.PSI.minThres = minThres;
stiPar.PSI.maxThres = maxThres;
stiPar.PSI.thresStep = thresStep;
stiPar.PSI.minSlope=minSlope;
stiPar.PSI.maxSlope=maxSlope;
stiPar.PSI.slopeStep = slopeStep;
stiPar.PSI.pcorr = pcorr;
stiPar.PSI.miss = miss;
stiPar.PSI.gamma = gamma;
end

