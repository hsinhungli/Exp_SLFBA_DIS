function PresentBlockInitiation(block)
global const scr stimulus stiPar expPar timing

%%
mytext = ['This is block no.' num2str(block.blockNumber)];
Screen(scr.windowPtr,'DrawText',mytext, 0.3 * scr.xres, 0.35 * scr.yres, [0 0 0]);

if block.saccade == 1
    mytext = 'NEUTRAL condition.';
elseif block.saccade == 2
    mytext = 'SACCADE condition.';
elseif block.saccade == 3
    mytext = 'COVERT ATTENTION condition.';
end
Screen(scr.windowPtr,'DrawText',mytext, 0.3 * scr.xres, 0.4 * scr.yres, [0 0 0]);

if block.prefc(1) == 1
    mytext = 'Attend to VERTICAL Grating';
elseif block.prefc(1) == 2
    mytext = 'Attend to HORIZONTAL Grating';
elseif block.prefc(1) == 3
    mytext = 'Attend to VERTICAL and HORIZONTAL Grating';
end

demotext = 'Examples of the Gratings are demonstrated in high contrast here';
Screen(scr.windowPtr,'DrawText',mytext, 0.3 * scr.xres, 0.5 * scr.yres, [0 0 0]);
Screen(scr.windowPtr,'DrawText',demotext, 0.3 * scr.xres, 0.55 * scr.yres, [0 0 0]);
%% Testing Parameter;
targetIdx = 1;
disIdx = 2;
targetContrast = .5;
disContrast = .5;
if rand>.5
    targetOri = 0;
    disOri = 0;
else
    targetOri = 0;
    disOri = 0;
end
%% Draw Stimuli
% Draw Target
gabor = CreateGabor(scr, stiPar.apersiz, stiPar.gaborstd,stiPar.gaborf,...
     rand*2*pi,targetContrast,targetOri);
noise  = CreateFilteredNoise(scr, stiPar.apersiz, stiPar.noise_lf, stiPar.noise_hf, [], [], stiPar.noise_contrast, 0);
display(['noise rmsContrast= ' num2str(std(noise(:))/.5)]);

target = min(max(.5+gabor*.5+noise,0),1);
mask  = CreateCircularApertureSin(scr, stiPar.gaborsiz, stiPar.sinsiz, [], stiPar.apersiz);
targetTex = Screen('MakeTexture',scr.windowPtr,cat(3,target,mask),[],[],2);

% Draw Distractor
gabor = CreateGabor(scr, stiPar.apersiz, stiPar.gaborstd,stiPar.gaborf,...
     rand*2*pi,disContrast,disOri);
noise = CreateFilteredNoise(scr, stiPar.apersiz, stiPar.noise_lf, stiPar.noise_hf, [], [], stiPar.noise_contrast, 0);
display(['noise rmsContrast= ' num2str(std(noise(:))/.5)]);

dis = min(max(.5+gabor*.5+noise,0),1);
mask  = CreateCircularApertureSin(scr, stiPar.gaborsiz, stiPar.sinsiz, [], stiPar.apersiz);
disTex = Screen('MakeTexture',scr.windowPtr,cat(3,dis,mask),[],[],2);

% Draw additional noise
% noise = CreateFilteredNoise(scr, stiPar.gaborsiz, stiPar.noise_lf, stiPar.noise_hf, [], [], stiPar.noise_contrast, 0)*stiPar.addnoise;
% noise = min(max(.5+noise,0),1);
% noiseTex1 = Screen('MakeTexture',scr.windowPtr,cat(3,noise,mask),[],[],2);
% noise = CreateFilteredNoise(scr, stiPar.gaborsiz, stiPar.noise_lf, stiPar.noise_hf, [], [], stiPar.noise_contrast, 0)*stiPar.addnoise;
% noise = min(max(.5+noise,0),1);
% noiseTex2 = Screen('MakeTexture',scr.windowPtr,cat(3,noise,mask),[],[],2);

% stim
gaborrct = {
    CenterRectOnPoint([0,0,stiPar.gaborpsiz,stiPar.gaborpsiz],stiPar.gaborPosition(1,1), stiPar.gaborPosition(1,2)), ...
    CenterRectOnPoint([0,0,stiPar.gaborpsiz,stiPar.gaborpsiz],stiPar.gaborPosition(2,1), stiPar.gaborPosition(2,2)), ...
    CenterRectOnPoint([0,0,stiPar.gaborpsiz,stiPar.gaborpsiz],stiPar.gaborPosition(3,1), stiPar.gaborPosition(3,2)), ...
    CenterRectOnPoint([0,0,stiPar.gaborpsiz,stiPar.gaborpsiz],stiPar.gaborPosition(4,1), stiPar.gaborPosition(4,2))};

%%
Screen('BlendFunction', scr.windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Screen('DrawTexture',scr.windowPtr,targetTex,[],gaborrct{targetIdx});
Screen('DrawTexture',scr.windowPtr,disTex,[],gaborrct{disIdx});
%Screen('DrawTexture',scr.windowPtr,noiseTex1,[],gaborrct{3});
%Screen('DrawTexture',scr.windowPtr,noiseTex2,[],gaborrct{4});
%%

drawFixation(scr); WaitSecs(1); KbWait(-3);
drawFixation(scr); WaitSecs(.5);