function initStim

global stiPar scr
stiPar.gaborstd      = .8;
stiPar.gaborf        = 1.5;
stiPar.apersiz       = 2.1;
stiPar.gaborsiz      = 1.9;
stiPar.gaborpsiz     = angle2pix(scr,stiPar.apersiz);
stiPar.gaborangle    = [0 90];
stiPar.sinsiz        = .8;

stiPar.gaborPosition = [scr.center(1)-angle2pix(scr,10) scr.center(2);
    scr.center(1)+angle2pix(scr,10) scr.center(2);
    scr.center(1)-angle2pix(scr,4) scr.center(2);
    scr.center(1)+angle2pix(scr,4) scr.center(2)];
stiPar.pink          = [0.5 0.0,0.5] * scr.white;
stiPar.blue          = [0.0,0.25,.75]* scr.white;
stiPar.green         = [0 0.4 0]* scr.white;
stiPar.neutral       = [.6 .6 .6]* scr.white;
stiPar.scLength      = .3;
stiPar.nframe        = 3;

stiPar.delta_angle = 5;
stiPar.target_contrast = 0.145;  %.135 HK %0.105 NK  %.105 HL
stiPar.noise_hf = 3;            %high-pass filter for noise
stiPar.noise_lf = .75;          %low-pass filter for noise
stiPar.noise_contrast  = 0.35; 
stiPar.addnoise = 1;

stiPar.stRad = angle2pix(scr,sqrt(1.5^2 + 1.5^2)); %Saccade landing region
stiPar.fixRad = angle2pix(scr,1.5); % fixation check radius
%visual.fixCkCol = [255  0  0];    % fixation check color

% [stiPar.cSnd, stiPar.freSnd] = aiffread('/System/Library/Sounds/Purr.aiff');
% stiPar.cSnd = Scale(double(stiPar.cSnd));
% [stiPar.cSnd, stiPar.freSnd] = aiffread('/System/Library/Sounds/Basso.aiff');
% stiPar.iSnd = Scale(double(stiPar.cSnd));
Screen('TextSize', scr.windowPtr, 22)

% stiPar.gaborexc         = 5*visual.ppd;
% stiPar.gaborsiz         = 4*visual.ppd;
% stiPar.gaborenvelopedev = 1*visual.ppd;
% stiPar.gaborangle       = [180,90];
% stiPar.gaborfrequency   = 2/visual.ppd;
% stiPar.noisekerneldev   = (1/6)/stiPar.gaborfrequency;
% stiPar.noisedev         = 0.1;
% stiPar.gaborexc         = round(stiPar.gaborexc);
% stiPar.gaborsiz         = round(stiPar.gaborsiz/2)*2;
%
% stiPar.color_default =
% [visual.pink;visual.blue;visual.neutral].*visual.white;