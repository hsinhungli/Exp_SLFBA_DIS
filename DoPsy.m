sca;
clear all;
global const scr obs trialInfo expPar stiPar stimulus timing

const.initial_time=GetSecs;
const.EXPNAME    = 'SLFBA_dis';
const.TITRATION  = 0;
const.VALIDATION = 0;
const.TESTMODE   = 1; %In a test mode or not
const.EYETRACK   = 0; %Set zero if treat eye-tracking as dummy mode
const.calibInt   = 250;

addpath(genpath('../myFunc'))
addpath('./PSI')
addpath('./Functions')
%% Prompt for user initials and experiment number
obs.identifier = input('Enter subject initials [test]: ','s');
if (isempty(obs.identifier))  
    obs.identifier = 'test';
end
if const.TITRATION == 1
    expCode = 'TIT';
elseif const.VALIDATION == 1
    expCode = 'VAL';
else 
    expCode = 'EXP';
end
obs.RunName = [obs.identifier,'_',expCode,'_',datestr(now,'yymmddHHMM')];
obs.EyelinkFileNum_r = obs.RunName;
obs.EyelinkFileNum = datestr(now,'mmddHHMM');
obs.gender = 'M';
obs.handedness = 'R';
const.datafolder=['Data_SLFBA_dis/' obs.identifier];
checkfolder = exist(const.datafolder,'dir');
if checkfolder ~= 7
    mkdir(const.datafolder)
end
%%
initScr;
initExp;
initStim;
drawFixation(scr)
%% initialize eyelink-connection
[el, err]=initEyeLink(obs.EyelinkFileNum);
if err==el.TERMINATE_KEY
    return
end
%%
disp('Start RunPsy');
RunPsy(el);

%%
Screen('LoadNormalizedGammaTable', scr.windowPtr, kron([1 1 1],linspace(0,1,256)'));
Screen('Flip',scr.windowPtr);
ShowCursor;
reddUp(obs.EyelinkFileNum);
if const.EYETRACK == 1
movefile(['./' obs.EyelinkFileNum '.edf'],['./' const.datafolder '/' obs.EyelinkFileNum_r '.edf']);
end
disp(fprintf('Exp Duration: %s',num2str((const.end_time - const.initial_time)/60)));
%PsychPortAudio('Close', scr.Snd);

% %% save data
% duration=GetSecs-initial_time;
% dataFileName = [subInitString num2str(expNum) '_dat.mat'];
% [saveIdx,newfileName]=checkfile(datafolder, dataFileName);
% if saveIdx==1
%     savedata=['save ' datafolder '/' dataFileName ' dataPar expPar stiPar scr duration'];
%     eval(savedata);
% elseif saveIdx==0
%     savedata=['save ' datafolder '/' newfileName ' dataPar expPar stiPar scr duration'];
%     eval(savedata);
% end
% fclose('all');
