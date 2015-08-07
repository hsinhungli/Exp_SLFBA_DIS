function initExp

global expPar trialInfo scr const

%% Timing Parameters
expPar.fixDur = 50/1000; %Fixation Duration
expPar.fcDur  = 150/1000;
expPar.ISI    = 200/1000; %This is the blank interval between fc offset and sc onset
expPar.ITI    = [500 1000]/1000;
expPar.stimDur = 3/85;
expPar.prepostCueDur    = 0/1000; %Blank Interval after stimulus offset and before postcue
expPar.ResponsePauseDur = 50/1000; %Blank between response keypress and feedback tone
expPar.PostCuePauseDur  = 0/1000; %Blank Interval before response
expPar.npracticeTrial = 0;
expPar.maxSaccadeDur = 400/1000;
expPar.ResponseDur = 2.2;
expPar.fcvalidity  = 1;
%% Set Up Parameters for this exp session
if const.TITRATION == 1
    expPar.nfactor_ibk=3; %n factor within block
    expPar.nfactor_ibk_rand=3; %nfactor within bloc: random variable
    expPar.nfactor_bbk=2; %n factor between block
    expPar.factorList_ibk={'none','targetloc','rep'};
    expPar.ncond_factor_ibk=[1 2 20];
    expPar.factorvalueMatrix_ibk={1, [1 2], 1:20};
    %{left, right, neutral| left, right| VH| Pre/Abs|OnsetTime}
    expPar.factorList_ibk_rand={'distype', 'OnsetTime','targettype'};
    expPar.ncond_factor_ibk_rand=[4 19 2];
    expPar.factorvalueMatrix_ibk_rand={[1 2 0 0]', (1:19)', [-1 1]'};
    expPar.factorList_bbk={'prefc','saccade'}; %saccade: 1:Neutral 2:Saccade 3:Attention
    expPar.ncond_factor_bbk=[1 1];
    expPar.factorvalueMatrix_bbk={1,1};
    expPar.ntrialPSI = 40; %This is for PSI Titration
    expPar.nblockPSI = 2;  %This is for PSI Titration: How many staircase to measure for averaging
elseif const.VALIDATION == 1

else
    expPar.nfactor_ibk=3; %n factor within block
    expPar.nfactor_ibk_rand=3; %nfactor within bloc: random variable
    expPar.nfactor_bbk=2; %n factor between block
    expPar.factorList_ibk={'none','targetloc','rep'};
    expPar.ncond_factor_ibk=[1 2 35];
    expPar.factorvalueMatrix_ibk={1, [1 2], 1:35};
    %{left, right, neutral| left, right| VH| Pre/Abs|OnsetTime}
    expPar.factorList_ibk_rand={'distype', 'OnsetTime','targetOri'};
    expPar.ncond_factor_ibk_rand=[4 19 2];
    expPar.factorvalueMatrix_ibk_rand={[1 2 0 0]', (1:18)', [-1 1]'}; %+43/+68 for endo attention
    expPar.factorList_bbk={'prefc','saccade'}; %saccade: 1:Neutral 2:Saccade 3:Attention
    expPar.ncond_factor_bbk=[1 4];
    expPar.factorvalueMatrix_bbk={1,[1 1 2 2]};
end
%%
expPar.ncond_combined_ibk=prod(expPar.ncond_factor_ibk);
expPar.ncond_combined_bbk=prod(expPar.ncond_factor_bbk);
%expPar.levelfactor_Index=max(expPar.nfactor_ibk); %the last factor is the factor ploted in x-axis on psyFunc
if const.TITRATION == 1
    expPar.nEst_point=expPar.nblockPSI; %nEstimation per point cond
    expPar.nrep_cond_block=1;
elseif const.VALIDATION == 1
    expPar.nEst_point=expPar.nblockPSI; %nEstimation per point cond
    expPar.nrep_cond_block=1;
else
    expPar.nEst_point=1; %nEstimation per point cond
    expPar.nrep_cond_block=1;
end
expPar.nTrial_Block= expPar.ncond_combined_ibk*expPar.nrep_cond_block;
expPar.nBlock      = expPar.ncond_combined_bbk*(expPar.nEst_point/expPar.nrep_cond_block);

%Decide between-block condition for each block
[expPar.blockList, numBlock]=getTrialList(expPar.factorvalueMatrix_bbk{1},expPar.factorvalueMatrix_bbk{2},...
    expPar.nEst_point/expPar.nrep_cond_block);
assert(numBlock==expPar.nBlock);

%%
for i = 1:numBlock
    %Generate trial by trial list for this block
    [A,B,C] = ndgrid(expPar.factorvalueMatrix_ibk{1}, expPar.factorvalueMatrix_ibk{2},...
        expPar.factorvalueMatrix_ibk{3});
    ComList = [A(:) B(:) C(:)];
    ComList = ComList(randperm(size(ComList,1)),:);
    if const.TITRATION == 1
        temp_ntrial = size(ComList,1);
        if temp_ntrial > expPar.ntrialPSI
            ComList = ComList(1:expPar.ntrialPSI,:);
        elseif temp_ntrial < expPar.ntrialPSI
            ComList = ComList(randi(temp_ntrial,[1 expPar.ntrialPSI]),:);
        end
    end
    expPar.block(i).targetloc   = ComList(:,2);
    expPar.block(i).trialNumber = 1:length(expPar.block(i).targetloc);
    expPar.block(i).numTrial    = length(expPar.block(i).trialNumber);
    
    %Random Variables within a block
    expPar.block(i).onsetTime = expPar.factorvalueMatrix_ibk_rand{2}...
        (randi(length(expPar.factorvalueMatrix_ibk_rand{2}),[expPar.block(i).numTrial,1]))/85;
    expPar.block(i).targetOri = expPar.factorvalueMatrix_ibk_rand{3}...
        (randi(length(expPar.factorvalueMatrix_ibk_rand{3}),[expPar.block(i).numTrial,1]));
    
    %---Deal with blocked conditions---
    %Neutral/Saccade/Attention
    expPar.block(i).blockNumber = i;
    expPar.block(i).blockCond = expPar.blockList(i,:);
    expPar.block(i).saccade   = expPar.block(i).blockCond(2) * ones(expPar.block(i).numTrial, 1);
    
    %Generate post fc
    if ismember(expPar.block(i).blockCond(1), [1 2])
        expPar.block(i).prefc         = expPar.block(i).blockCond(1) * ones(expPar.block(i).numTrial, 1);
        expPar.block(i).postfc        = rand(expPar.block(i).numTrial,1);
        vidx = expPar.block(i).postfc <= expPar.fcvalidity;
        iidx = expPar.block(i).postfc > expPar.fcvalidity;
        expPar.block(i).postfc(vidx)  = expPar.block(i).blockCond(1);
        expPar.block(i).postfc(iidx)  = 3-expPar.block(i).blockCond(1);
    elseif ismember(expPar.block(i).blockCond(1), 3)
        expPar.block(i).prefc         = expPar.block(i).blockCond(1) * ones(expPar.block(i).numTrial, 1);
        expPar.block(i).postfc = rand(expPar.block(i).numTrial,1);
        vidx = expPar.block(i).postfc <= .5 ;
        iidx = expPar.block(i).postfc > .5 ;
        expPar.block(i).postfc(vidx)  = 1;
        expPar.block(i).postfc(iidx)  = 2;
    end
    
    expPar.block(i).vfc = double(expPar.block(i).prefc == expPar.block(i).postfc);
end
trialInfo = expPar.block;
expPar = rmfield(expPar,'block');
%% Seperate Blocks
