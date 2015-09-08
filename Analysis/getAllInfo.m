addpath('./Functions');
tempfileName =loadfiles(expIdx,folderName);
disp(tempfileName);
if folderName == '.'
    fileName = tempfileName(selectIdx);
else
    count = 0;
    if selectIdx == ':';
        fileName = tempfileName;
    else
        for i = selectIdx
            count = count+1;
            fileName{count} = sprintf('%s',tempfileName{i});
        end
    end
end
disp(fileName);
fprintf('%d sessions\n', length(fileName))

% Concatenate all block across session. numel(struct) = number of block
trialInfo = [];
timing    = [];
stimulus  = [];
count     = 0;
for i = 1:numel(fileName)
    count = count+1;
    temp = load([folderName '/' fileName{i}],'trialInfo','timing','stimulus');
    for j = 1:length(temp.trialInfo)
        temp.trialInfo(j).sessionNumber = ones(temp.trialInfo(j).numTrial,1)*count;
        temp.trialInfo(j).blockNumber   = ones(temp.trialInfo(j).numTrial,1)*temp.trialInfo(j).blockNumber;
    end
    trialInfo = [trialInfo, temp.trialInfo];
    timing = [timing, temp.timing];
    stimulus = [stimulus, temp.stimulus];
end

%Extract all varialbes across block.
varName = fieldnames(trialInfo);
nVar = length(varName);
Output = catField(trialInfo);
for v = 1:nVar
    myCommand = [varName{v} '=Output{' num2str(v) '};'];
    eval(myCommand)
end

varName = fieldnames(timing);
nVar = length(varName);
Output = catField(timing);
for v = 1:nVar
    myCommand = [varName{v} '=Output{' num2str(v) '};'];
    eval(myCommand)
end

if readStim == 1
    varName = fieldnames(stimulus);
    nVar = length(varName);
    Output = catField(stimulus);
    for v = 1:nVar
        myCommand = [varName{v} '=Output{' num2str(v) '};'];
        eval(myCommand)
    end
end

myCommand = sprintf('load %s/%s stiPar scr',folderName,fileName{end});
eval(myCommand);
%%
if readSacInfo
    folderIdx = [folderName '/sacInfo'];
    fileName = loadfiles(expIdx,folderIdx);
    fileName = fileName(selectIdx);
    sacInfo = [];
    for i = 1:numel(fileName)
        temp = load([folderIdx '/' fileName{i}],'sacInfo');
        sacInfo = [sacInfo, temp.sacInfo];
    end
    varName = fieldnames(sacInfo);
    nVar = length(varName);
    Output = catField(sacInfo);
    for v = 1:nVar
        myCommand = [varName{v} '=Output{' num2str(v) '};'];
        eval(myCommand)
    end
end
%%
tUnique = unique(onsetTime);
if readSacInfo == 1
    Latency = stiOff-sacOnset;
    LandingLatency = stiOff-sacOffset;
    SLatency = sacRT;
elseif readSacInfo == 0
%     Latency = (stimOFF - tSac)*1000;
%     SLatency = (tSac-prescON)*1000;
%     goodtrial = ones(size(prescON));
end

clear Output noise
