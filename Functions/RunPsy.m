function  RunPsy(el)
global const scr obs trialInfo expPar stiPar stimulus timing

% unify keynames for different operating systems
KbName('UnifyKeyNames');

% preload important functions
% NOTE: adjusting timer with GetSecsTest
% has become superfluous in OSX
drawFixation(scr);
GetSecs;
WaitSecs(.2);
FlushEvents('keyDown');

% hide cursor if not in dummy mode
if const.TESTMODE
    ShowCursor;
else
    HideCursor;
end
%% Run Exp block by block
for i = 1:expPar.nBlock
    
    %% Run this block
    block = trialInfo(i);
    numTrial = block.numTrial;
    runTrial = block.trialNumber;
    toRunIdx = runTrial';
    realtrialNumber = 0;
    trialDone = 0;
    exitIdx = [];
    
    trialInfo(i).response = nan(block.numTrial,1);
    trialInfo(i).realtrialNumber = nan(block.numTrial,1);
    trialInfo(i).targetContrast = nan(block.numTrial,1);
    trialInfo(i).targetOri = nan(block.numTrial,1);
    trialInfo(i).disContrast = nan(block.numTrial,1);
    trialInfo(i).disOri = nan(block.numTrial,1);
    trialInfo(i).targetIdx = nan(block.numTrial,1);
    trialInfo(i).disIdx = nan(block.numTrial,1);
    trialInfo(i).responsehand = nan(block.numTrial,1);
    trialInfo(i).correct = nan(block.numTrial,1);
    
    %% Start this block, run trial by trial
    while length(toRunIdx) >=1
        runTrial = toRunIdx(1);
        realtrialNumber = realtrialNumber+1
        % clean operator screen
        Eyelink('command','clear_screen');
        
        %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Eyelink Stuff
        if realtrialNumber==1 || ~mod(realtrialNumber,const.calibInt)           % calibration
            if const.EYETRACK
                mytext = ['Calibration for the new block'];
                Screen(scr.windowPtr,'DrawText',mytext, 0.4 * scr.xres, 0.4 * scr.yres, [0 0 0]);
                drawFixation(scr); WaitSecs(.5); KbWait(-3); drawFixation(scr); WaitSecs(1);
                calibresult = EyelinkDoTrackerSetup(el,'c');
                if calibresult==el.TERMINATE_KEY
                    return
                end
            end
        end
        
        if realtrialNumber == 1 %%Instruction at the begining of each block (feature cue here)
            PresentBlockInitiation(block);
            if const.TITRATION == 1
                initPSI;
                stiPar.trialCount = 1;
            end
        end
        
        if const.EYETRACK
            if Eyelink('isconnected')==el.notconnected		% cancel if eyeLink is not connected
                return
            end
        end
        
        % This supplies a title at the bottom of the eyetracker display
        Eyelink('command', 'record_status_message ''Block %d of %d, Trial %d of %d''', i, expPar.nBlock, realtrialNumber, numTrial);
        % this marks the start of the trial
        Eyelink('message', 'TRIALID %d', realtrialNumber);
        
        ncheck = 0;
        fix    = 0;
        record = 0;
        while fix~=1 || ~record
            if ~record
                Eyelink('startrecording');	% start recording
                % You should always start recording 50-100 msec before required
                % otherwise you may lose a few msec of data
                WaitSecs(.1);
                if const.EYETRACK
                    key=1;
                    while key~= 0
                        key = EyelinkGetKey(el);		% dump any pending local keys
                    end
                end
                % Eyelink('flushkeybuttons', 0 );		% reset keys and buttons from tracker
                
                err=Eyelink('checkrecording'); 	% check recording status
                if err==0
                    record = 1;
                    Eyelink('message', 'RECORD_START');
                else
                    record = 0;	% results in repetition of fixation check
                    Eyelink('message', 'RECORD_FAILURE');
                end
            end
            
            if fix~=1 && record
                if const.EYETRACK
                    Eyelink('command','clear_screen 0');
                    Screen(scr.windowPtr,'FillRect',scr.bgColor); % clean screen
                    fix = checkFix;	% fixation is checked
                    ncheck = ncheck + 1;
                else
                    fix = 1;
                end
            end
            
            if fix~=1 && record
                % calibration, if maxCheck drift corrections did not succeed
                %                 if const.EYETRACK
                %                     calibresult = EyelinkDoTrackerSetup(el,'d');
                %                     if calibresult==el.TERMINATE_KEY
                %                         return
                %                     end
                %                 end
                if const.EYETRACK
                    Eyelink('Message', 'DRIFT_CORRECTION');
                    disp('Run DriftCorrect')
                    fix = EyelinkDoDriftCorrect(el, scr.center(1), scr.center(2), 1, 1);
                end
                record = 0;
            end
        end
        
        %% Run one single trial
        Eyelink('message', 'TRIAL_START %d', runTrial);
        Eyelink('message', 'TRIAL_START_REALTRIALNUMBER %d', realtrialNumber);
        Eyelink('message', 'SYNCTIME');		% zero-plot time for EDFVIEW
        [tData,exit]=PresentStimulus(block, runTrial, block.blockNumber);
        Eyelink('message', 'TRIAL_END %d', runTrial);
        Eyelink('message', 'TRIAL_END_REALTRIALNUMBER %d',  realtrialNumber);
        Eyelink('stoprecording');
        
        %% Save this trial if success; move the unsuccessful trial to the end of the bolck
        if tData.breakIt==1 %Trial not completed due to fixation break
            Screen(scr.windowPtr,'DrawText','Fixate Please', 0.46 * scr.xres, 0.46 * scr.yres, [0 0 0]); drawFixation(scr);
            WaitSecs(.3); scr.fix.color{1} = [0 0 0]; drawFixation(scr); WaitSecs(.2);
            toRunIdx = circshift(toRunIdx,-1);
        elseif tData.breakIt==2
            Screen(scr.windowPtr,'DrawText','too slow', 0.46 * scr.xres, 0.46 * scr.yres, [0 0 0]); drawFixation(scr);
            WaitSecs(.3); scr.fix.color{1} = [0 0 0]; drawFixation(scr); WaitSecs(.2);
            toRunIdx = circshift(toRunIdx,-1);
            [keyIsDown, ~, keyCode] = KbCheck(-3);
            if keyIsDown
                keyName = KbName(keyCode);
                if keyName(1) == '0'
                    WaitSecs(2);
                    calibresult = EyelinkDoTrackerSetup(el,'c');
                    if calibresult==el.TERMINATE_KEY
                        return
                    end
                end
            end
        elseif tData.correct==3
            Screen(scr.windowPtr,'DrawText','Wrong Hand', 0.46 * scr.xres, 0.46 * scr.yres, [0 0 0]); drawFixation(scr);
            WaitSecs(.3); drawFixation(scr); WaitSecs(.2);
            toRunIdx = circshift(toRunIdx,-1);
        elseif tData.fixBreak==0 %Trial Complete
            trialDone = trialDone+1;
            trialInfo(i).realtrialNumber(runTrial) = realtrialNumber;
            trialInfo(i).response(runTrial) = tData.response;
            trialInfo(i).targetContrast(runTrial) = tData.targetContrast;
            trialInfo(i).targetOri(runTrial) = tData.targetOri;
            trialInfo(i).responsehand(runTrial) = tData.responsehand;
            trialInfo(i).correct(runTrial) = tData.correct;
            %Eyelink('message', 'TrialData %s', dataStr);    % write data to edfFile
            toRunIdx(1) = [];
            
            %Update PSY according to subjects' response
            if const.TITRATION == 1 && ismember(tData.correct, [1 0])
                [stiPar.PSI.curthresEst, stiPar.PSI.curslopeEst, stiPar.PSI.PSIpar] ...
                    =PsiUpdate(stiPar.PSI.PSIpar, stiPar.PSI.ContrastIndex, tData.correct == 1);
                stiPar.PSI.thresEst(i,stiPar.trialCount)=10^stiPar.PSI.curthresEst;
                stiPar.PSI.slopeEst(i,stiPar.trialCount)=stiPar.PSI.curslopeEst;
                stiPar.PSI.respRecord(i,stiPar.trialCount)= tData.correct == 1;
                disp(['Estimate Threshold: ' num2str(stiPar.PSI.thresEst(stiPar.trialCount))]);
                stiPar.trialCount = stiPar.trialCount+1;
            end
        end
        if exit ==1
            exitIdx.block = i;
            exitIdx.trial = runTrial;
            break;
        end
        %scr.fix.ITI = 1;
        %drawFixation(scr);
        WaitSecs(expPar.ITI(1) + diff(expPar.ITI)*rand);
        %scr.fix.ITI = 0;
    end
    if exit ~= 1
        assert(trialDone == numTrial);
    end
    
    const.end_time = GetSecs;
    const.exit = exit;
    save(['./',const.datafolder,'/',obs.RunName,'.mat'],'obs','const','scr','expPar','stiPar','trialInfo','timing','stimulus','exitIdx');
    if exit == 1
        Screen(scr.windowPtr,'FillRect',scr.bgColor);
        Screen(scr.windowPtr,'Flip');
        break
    end
    
    tempIdx = ismember(trialInfo(i).correct,[1 0]);
    pc = mean(trialInfo(i).correct(tempIdx))*100;
    PresentBlockEnd(pc);
    
end

%% % end eye-movement recording
if const.EYETRACK
    Screen(el.window,'FillRect',el.backgroundcolour);   % hide display
    WaitSecs(0.1);Eyelink('stoprecording');             % record additional 100 msec of data
end

Screen(scr.windowPtr,'FillRect',scr.bgColor);
Screen(scr.windowPtr,'Flip');
if exit ~= 1
    Screen(scr.windowPtr,'DrawText','Thanks, you have finished this part of the experiment.',100,100,0);
    Screen(scr.windowPtr,'Flip');
    WaitSecs(1);
    KbWait(-3);
end
Eyelink('command','clear_screen');
Eyelink('command', 'record_status_message ''ENDE''');
Screen(scr.windowPtr,'FillRect',scr.bgColor);
Screen(scr.windowPtr,'Flip');
%%
