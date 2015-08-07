function [tD, exit]=PresentStimulus(trial,Idx,block)
global const scr stimulus stiPar expPar timing

%% Testing Parameter;
% expPar.fcDur=.1;
% trial.onsetTime = ones(1,20)*1/85;
% trial.prefc=2;
% trial.presc=1;
% trial.targettype=1;
% trial.postfc=1;
% trial.distype=0;
%trial.postsc=ones(1,20)*2;
% Idx=1;
% block=1;

% trial.prefc(Idx)
% trial.presc(Idx)
% trial.postfc(Idx)
% trial.postsc(Idx)
% trial.targettype(Idx)

%% TITRATION: PSI
if const.TITRATION == 1
%get recommended test contrast
stiPar.PSI.ContrastIndex=PsiPlace(stiPar.PSI.PSIpar);
stiPar.PSI.testC(stiPar.trialCount)=stiPar.PSI.PSIpar.contRange(stiPar.PSI.ContrastIndex);
stiPar.PSI.testC(stiPar.trialCount)=10^stiPar.PSI.testC(stiPar.trialCount);
stiPar.target_contrast = stiPar.PSI.testC(stiPar.trialCount);
disp(['contrast for this trial ' num2str(stiPar.target_contrast)])
end
%% Prepare Some parameters
FlushEvents('keyDown');
framecount = 0;
keyIsDown  = 0;
response   = 99;
correct    = 99;
breakIt    = 0;
fixBreak   = 0;
exit       = 0;

eyePhase   = 1;
fixWasOn   = 0;
prefcWasOn = 0;
ISIWasOn   = 0;
prescWasOn = 0;
stimWasOn  = 0;
stimWasOFF = 0;
waitWasEnd = 0;
saccade    = 0;
tSac       = NaN;
tLand      = NaN;
responsehand = NaN;
%% predefine boundary information
cxm = scr.center(1);
cym = scr.center(2);
switch trial.targetloc(Idx)
    case 1 %saccade to left
        sxm = stiPar.gaborPosition(1,1);
        sym = stiPar.gaborPosition(1,2);
    case 2 %saccade to right
        sxm = stiPar.gaborPosition(2,1);
        sym = stiPar.gaborPosition(2,2);
    case 3
        sxm = stiPar.gaborPosition(2,1);
        sym = stiPar.gaborPosition(2,2);
end
rad = stiPar.stRad;
chk = stiPar.fixRad;

% draw trial information on operator screen
Eyelink('command','draw_box %d %d %d %d 15', sxm-rad, sym-rad, sxm+rad, sym+rad);
Eyelink('command','draw_box %d %d %d %d 15', cxm-chk, cym-chk, cxm+chk, cym+chk);
Eyelink('command','draw_box %d %d %d %d 15', sxm-5, sym-5, sxm+5, sym+5);
%Eyelink('command','draw_filled_box %d %d %d %d 15', td.stan(s).loc(1)-10, td.stan(s).loc(2)-10, td.stan(s).loc(1)+10, td.stan(s).loc(2)+10);

%% Define target/distractor contrast and orientation
% if trial.postfc(Idx) == 1 %Target Orientation: 1:lefttilt/2:righttilt/3:This is for target absent
%     targetOri = 0;
% elseif trial.postfc(Idx) == 2
%     targetOri = 90;
% end
if trial.targetOri(Idx) == -1 %Target presence or absence
    targetOri = 0 - stiPar.delta_angle;
elseif trial.targetOri(Idx) == 1
    targetOri = 0 + stiPar.delta_angle;
end
if trial.targetloc(Idx) == 1 %Target at Left
    targetloc= 1;
elseif trial.targetloc(Idx) == 2 %Target at right
    targetloc = 2;
end
if ismember(trial.saccade(Idx), [2 3]) %trial.saccade(Idx): 1:Neutral 2:Saccade 3:Attention
    prescIdx = targetloc;
elseif ismember(trial.saccade(Idx), 1)
    prescIdx = 3; %Neutral cue
end
targetContrast = stiPar.target_contrast;
%% Draw Stimuli
% Draw Target
ramp = [1 1 1];

stimulus(block).phase(targetloc,Idx) = rand*2*pi;
gabor  = CreateGabor(scr, stiPar.apersiz, stiPar.gaborstd,stiPar.gaborf,...
     stimulus(block).phase(targetloc,Idx),targetContrast,targetOri);
noise  = CreateFilteredNoise(scr, stiPar.apersiz, stiPar.noise_lf, stiPar.noise_hf, [], [], stiPar.noise_contrast, 0);
display(['noise rmsContrast= ' num2str(std(noise(:))/.5)]);

temp_target = .5+gabor*.5+noise;
stimulus(block).outlier(targetloc,Idx) = sum(temp_target(:)>1 | temp_target(:)<0);
target = min(max(temp_target,0),1);
%mask  = CreateCircularApertureSin(scr, stiPar.gaborsiz, stiPar.sinsiz);
mask  = CreateCircularApertureSin(scr, stiPar.gaborsiz, stiPar.sinsiz, [], stiPar.apersiz);
for j = 1:stiPar.nframe
    targetTex(j) = Screen('MakeTexture',scr.windowPtr,cat(3,target,mask*ramp(j)),[],[],2);
end
stimulus(block).patch{Idx} = target.*mask + .5*(1-mask);

% stim
gaborrct = {
    CenterRectOnPoint([0,0,stiPar.gaborpsiz,stiPar.gaborpsiz],stiPar.gaborPosition(1,1), stiPar.gaborPosition(1,2)), ...
    CenterRectOnPoint([0,0,stiPar.gaborpsiz,stiPar.gaborpsiz],stiPar.gaborPosition(2,1), stiPar.gaborPosition(2,2))};

%% Start Presentation
Snd('Quiet'); 
while ~breakIt
    % Fixation Period
    if fixWasOn == 0
        scr.fix.color{1} = [0 80 0];
        fixON = drawFixation(scr);
        Eyelink('message', 'EVENT_fixON');
        fixWasOn =1;
        
    % PreCue-Feature
    elseif fixWasOn == 1 && prefcWasOn == 0;
        if GetSecs - fixON >= expPar.fixDur-scr.ifi
            %scr.fix.fc = 3;
            prefcON = drawFixation(scr);
            Eyelink('message', 'EVENT_prefcON');
            prefcWasOn = 1;
        end
    
    % ISI %This is the blank interval between fc offset and sc onset
    elseif prefcWasOn == 1 && ISIWasOn == 0 
        if GetSecs - prefcON >= expPar.fcDur
            scr.fix.fc = 0;
            ISION = drawFixation(scr);
            ISItime = expPar.ISI(1);
            Eyelink('message', 'EVENT_ISION');
            ISIWasOn = 1;
        end
        
    % SaccadeCue
    elseif prefcWasOn == 1 && prescWasOn == 0 && ISIWasOn == 1
        if GetSecs - ISION >= ISItime
            scr.fix.sc = prescIdx;
            prescON = drawFixation(scr);
            Eyelink('message', 'EVENT_prescON');
            prescWasOn = 1;
            if trial.saccade(Idx) == 2  %change eyephase if required saccade
            eyePhase = 2; %Set eyePhase =2 if saccade required
            end
        end
        
    % Present Stimulus
    elseif prescWasOn == 1 && framecount < stiPar.nframe
        if GetSecs - prescON > trial.onsetTime(Idx)-scr.ifi
            framecount = framecount+1;
            Screen('BlendFunction', scr.windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            Screen('DrawTexture',scr.windowPtr,targetTex(framecount),[],gaborrct{targetloc});
            %Screen('DrawTexture',scr.windowPtr,disTex(framecount),[],gaborrct{disIdx});
            if framecount == 1
                stimON = drawFixation(scr); %KbWait(-3);
                Eyelink('message', 'EVENT_stimON');
                stimWasOn = 1; %KbWait;
            else
                drawFixation(scr);
            end
        end
        
    elseif stimWasOn == 1 && stimWasOFF == 0
        if GetSecs - stimON >= expPar.stimDur-scr.ifi
        stimOFF = drawFixation(scr);
        Eyelink('message', 'EVENT_stimOFF');
        stimWasOFF = 1;
        end
    elseif stimWasOFF == 1 && waitWasEnd == 0
        if GetSecs - stimOFF >= expPar.prepostCueDur
            waitWasEnd=1;
        end
    end
 
    % eye position check
    [x,y] = getCoord;
    switch eyePhase
        case 1      % fixation phase
            if sqrt((x-cxm)^2+(y-cym)^2)>chk    % check fixation in a circular area
                fixBreak = 1;
            end
            if prescWasOn && ismember(trial.saccade(Idx),[1 3])     %This is for fixation expeirment (ie. TITRATION: neutral saccade cue)
                saccade = 1;
            end
        case 2      % saccade phase
            if const.EYETRACK == 0 && GetSecs - prescON > .2 %In the dummy mode/Asumeing succesful saccade
                saccade=1; %Succesful saccade landing
                tLand = GetSecs;
            elseif const.EYETRACK == 1
                if sqrt((x-cxm)^2+(y-cym)^2)>chk && isnan(tSac) % check distance to fixation
                    tSac = GetSecs;
                end
                if sqrt((x-sxm)^2+(y-sym)^2)<rad && ~saccade % check whether eye land in saccade target
                    saccade = 1; %Succesful saccade landing
                    tLand = GetSecs;
                end
            end
    end
    if fixBreak %FixationBreak
        breakIt = 1;
    elseif  ~saccade && prescWasOn && GetSecs > prescON + expPar.maxSaccadeDur %TooSLow
        breakIt = 2;
    elseif  saccade && waitWasEnd
        breakIt = 3;
        postcueON = drawFixation(scr);
    end
end
%% Get response
tD.breakIt = breakIt;
switch breakIt
    case 1
        %data = 'fixBreak';
        scr.fix.fc = 0;
        scr.fix.sc = 0;
        drawFixation(scr);
        Eyelink('command','draw_text 100 100 42 Fixation break');
    case 2
        %data = 'tooSlow';
        scr.fix.fc = 0;
        scr.fix.sc = 0;
        drawFixation(scr);
        Eyelink('command','draw_text 100 100 42 Too slow');
    case 3
        [response, sec, responsehand, exit] = getKeyPress(expPar.PostCuePauseDur,expPar.ResponsePauseDur,expPar.ResponseDur);        

        % feedback
        if ismember(response, [-1 1])
            if responsehand ~= targetloc
                correct = 3; %Wrong Hand
                Beeper(400,.2,.1); WaitSecs(.3); Beeper(400,.2,.1);
            elseif response == trial.targetOri(Idx) && responsehand == targetloc
                correct =1;
                Beeper(700,.2,.1);
            elseif response ~= trial.targetOri(Idx)
                correct =0;
                Beeper(400,.2,.15);
            end
        else
            correct = 99;
            Beeper(200,.1,.25)
        end
        
        % Clear the screen
        scr.fix.fc = 0;
        scr.fix.sc = 0;
        scr.fix.postcueOn = 0;
        scr.fix.color{1} = [0 0 0];
        drawFixation(scr);
        Eyelink('message', 'EVENT_ClearScreen');
        
        % Save data for this trial
        timing(block).fixON(Idx)        = fixON;
        timing(block).prefcON(Idx)      = prefcON;
        timing(block).ISION(Idx)        = ISION;
        timing(block).prescON(Idx)      = prescON;
        timing(block).stimOn(Idx)       = stimON;
        timing(block).stimOFF(Idx)      = stimOFF;
        timing(block).tSac(Idx)         = tSac;
        timing(block).tLand(Idx)        = tLand;
        timing(block).postcueON(Idx)    = postcueON;
        timing(block).sec(Idx)          = sec;
        timing(block).RT(Idx)           = sec - postcueON;
        tD.response = response;
        tD.correct = correct;
        tD.fixBreak=0;
        tD.targetContrast = targetContrast;
        tD.targetOri = targetOri;
        tD.targetloc = targetloc;
        tD.responsehand = responsehand;
end
%%
Screen('Close',targetTex);
[keyIsDown, sec, keyCode] = KbCheck(-3);
keyName=KbName(keyCode);
if ~isempty(keyName)
    if iscell(keyName)
        keyName=keyName{1};
    end
else
    keyName='-';
end
keyName=keyName(1);
if keyName=='E'
    responsehand = 2;
    exit=1;
    response=99;
end
