clear all;
close all;
folderName   = 'LH'; %Usually this is the subject ID
expIdx       = 'LH_EXP_';    %The initial of the experiment data file
readSacInfo  = 1;           %Use the eye-tracking timing from eyelink
readStim     = 1;
selectIdx    = ':';              %Analyze a subset of files
getAllInfo;
fcIdx = prefc == postfc;
fileName     = sprintf('%s/filterResponse',folderName);
poolRT= (sec - stimOFF)*1000;

loadResponse = 0;
saveResponse = 0;
savemData    = 0;
if savemData == 1
    mData_CI.name = folderName;
    mDataFileName = sprintf('./%s/%s_mData_CI',folderName,folderName);
end
%% Get filterRespeonse
if loadResponse == 1 %Load the filterResponse if it is computed and save before.
    
%     load(fileName);
%     
%     X = filterResponse;
%     nFre  = length(freStep);
%     nOri  = length(OriStep);
%     nImg  = size(filterResponse,3);
%     
%     figure;
%     subplot(1,2,1)
%     imagesc(OriStep,freStep,mean(X(:,:,targettype==1),3),[min(X(:)) max(X(:))]/2);
%     subplot(1,2,2)
%     imagesc(OriStep,freStep,mean(X(:,:,targettype==0),3),[min(X(:)) max(X(:))]/2);
%     drawnow;
%     
else
    % filters to study
    %freStep          = .25:.25:3.5;   % Spatial frequency tuning of the filters
    freStep          = 1.5;
    OriStep          = -90:5:85; % Orientation tuning of the filters
    temp_patch       = patch;
    
    [filterResponse, PhaseValue] = GetFilterEnergy(freStep, OriStep, temp_patch, stiPar, scr);
    
    X     = filterResponse;
    nFre  = length(freStep);
    nOri  = length(OriStep);
    nImg  = size(filterResponse,3);
    %X     = squeeze(X); %fre x ori x nimg
    
    figure;
    subplot(1,2,1)
    imagesc(OriStep,freStep,mean(X(:,:,targetOri==-5),3),[min(X(:)) max(X(:))]/2);
    subplot(1,2,2)
    imagesc(OriStep,freStep,mean(X(:,:,targetOri==5),3),[min(X(:)) max(X(:))]/2);
    drawnow;
    
    if saveResponse==1
        fprintf('saving filterResponse\n')
        save(fileName, 'filterResponse','freStep','OriStep','nImg','nOri','nFre')
    end
end
%% Preprocessing
% fix spatial frequency and look at orientation tuning;
% Some preprocessing on the noise

dX = squeeze(X(freStep == stiPar.gaborf, :,:))';
figure;
plot(OriStep,dX');

ContrastLevel = unique(targetContrast);
for c = 1:length(ContrastLevel)
    Idx = targetContrast == ContrastLevel(c);
    dX(targetOri == -5 & Idx, :) = bsxfun(@minus,dX(targetOri == -5 & Idx, :),mean(dX(targetOri == -5 & Idx, :),1));
    dX(targetOri == 5 & Idx, :) = bsxfun(@minus,dX(targetOri == 5 & Idx, :),mean(dX(targetOri == 5 & Idx, :),1));
end

Noise = std(dX(:,:),1);
dX = dX ./ repmat(Noise, size(dX,1),1);

figure; hold on;
plot(OriStep,dX');
plot(OriStep, mean(dX),'-w','LineWidth',2);
plot(OriStep, std(dX),'-r','LineWidth',2);
xlim([-90 90]);
drawnow;
%%
% Get Classification Image
timStamp   =[-200 -100; -100 -50;-50 0;-100 0;0 100];
%timStamp  =[-150 -125;-125 -100; -100 -75;-75 -50; -50 -25;-25 0;0 30;30 55];
nt         = size(timStamp,1);
xansession = 1:10;
selectIdx  = ismember(sessionNumber, xansession);
goodIdx    = goodtrial == 1 & responsehand == targetloc & ismember(response,[1 -1]) & selectIdx;
condRun    = unique(saccade);

if ismember(2, condRun);
    for t = 1:nt
        %Saccade
        timeIdx = Latency >= timStamp(t,1) & Latency < timStamp(t,2) & SLatency > 100;
        condIdx = saccade==2 & timeIdx & goodIdx & fcIdx; %& correct==0;
        Idx_L   = response == -1 & condIdx == 1;
        Idx_R   = response == 1 & condIdx == 1;
        
        CI_D.s(t,:) = mean(dX(Idx_L,:)) - mean(dX(Idx_R,:));
        %CI_D.s(t,:) = mean(dX(Idx_F,:)) - mean(dX(Idx_M,:));
        CI_glm.s(t,:) = getglmSensitivityFunction(dX,response==-1,condIdx);
        nT.s(t) = sum(Idx_L)+sum(Idx_R);
    end
end

%Neutral
if ismember(1, condRun)
    t=1;
    
    timeIdx = goodtrial == 1;
    condIdx = saccade==1 & timeIdx & goodIdx & fcIdx;% & correct==0;
    Idx_L   = response == -1 & condIdx == 1;
    Idx_R   = response == 1 & condIdx == 1;
    
    CI_D.n(t,:) = mean(dX(Idx_L,:)) - mean(dX(Idx_R,:));
    CI_glm.n(t,:) = getglmSensitivityFunction(dX,response==-1,condIdx);
    nT.n(t) = sum(Idx_L)+sum(Idx_R);
end

%Attention
if ismember(3,condRun)
    t=1;
    
    timeIdx = goodtrial == 1;
    condIdx = saccade==3 & timeIdx & goodIdx & fcIdx;% & correct==0;
    Idx_L   = response == -1 & condIdx == 1;
    Idx_R   = response == 1 & condIdx == 1;
    
    CI_D.a(t,:) = mean(dX(Idx_L,:)) - mean(dX(Idx_R,:));
    CI_glm.a(t,:) = getglmSensitivityFunction(dX,response==-1,condIdx);
    nT.a(t) = sum(Idx_L)+sum(Idx_R);
end

if savemData==1
    mData_CI.CI_D   = CI_D;
    mData_CI.CI_glm = CI_glm;
    mData_CI.CI_nT  = nT;
    mData_CI.tStamp = timStamp;
    mData_CI.OriStep = OriStep;
    
    fprintf('saving meta Data file\n')
    save(mDataFileName, 'mData_CI')
end

cpsFigure(1.9, 1);
for t = 1:nt
    subplot(2,nt,t); hold on;
    %myerrorbar(OriStep,CI_D(t,:), CI_D_bootstd(t,:),[.7 .7 1]);
    plot(OriStep,CI_D.s(t,:),'b-');
    plot(OriStep,CI_D.n(1,:),'k-');
    %plot(OriStep,CI_D.a(1,:),'r-');
    plot(OriStep,zeros(1, nOri),'k.','MarkerSize',.2);
    text(-90,-1, num2str(nT.s(t)),'FontSize',14);
    ylim([-1.5 2])
    %xlim([-90 87])
    title(num2str(timStamp(t,:)));
    
    subplot(2,nt,t+nt)
    plot(OriStep,CI_glm.s(t,:),'b-'); hold on;
    plot(OriStep,CI_glm.n(1,:),'k-');
    %plot(OriStep,CI_glm.a(1,:),'r-');
    plot(OriStep,zeros(1, nOri),'k.','MarkerSize',.2);
    text(-90,-.1, num2str(nT.s(t)),'FontSize',14);
    xlim([-90 87])
    ylim([-0.6 .6])
    title(num2str(timStamp(t,:)));
end
legend({'Saccade','Neutral'})
tightfig;
%%
cpsFigure(.4, .4); hold on;
plot(OriStep,CI_D.n(1,:),'k-');
plot(OriStep,CI_D.a(1,:),'r-');
plot(OriStep,zeros(1, nOri),'k.','MarkerSize',.2);
text(-90,-1, num2str(nT.a(1)),'FontSize',14);
ylim([-1.5 2])
xlim([-90 87])
cpsFigure(.4, .4); hold on;
plot(OriStep,CI_glm.n(1,:),'k-');
plot(OriStep,CI_glm.a(1,:),'r-');
plot(OriStep,zeros(1, nOri),'k.','MarkerSize',.2);
text(-90,-.1, num2str(nT.a(1)),'FontSize',14);
xlim([-90 87])

%% Subtraction
cpsFigure(.7, .7); hold on;
cool = cool;
color = cool(1:64/3:64,:);
for t = 1:3
    temp = CI_D.s(t,:);% - min(CI_D.s(t,:));
    plot(OriStep,temp,'color',color(t,:),'LineWidth',2)
end
temp = CI_D.n(1,:);% - min(CI_D.n(1,:));
plot(OriStep,temp ,'k', OriStep, zeros(size(OriStep)),'--k')
ylim([-1 2])
title('Tuning curve - sub','FontSize',13)
xlabel('Orientation','FontSize',13)
legend({'pre -100ms','-100 ~ -50ms','-50 ~ 0ms','Neutral'},'FontSize',13)
tightfig;

cpsFigure(.7, .7); hold on;
temp = CI_D.s(t,:) - CI_D.n(1,:);
plot(OriStep,temp,'color',color(t,:),'LineWidth',2)
plot(OriStep, zeros(size(OriStep)),'--k')
ylim([-1.5 1.5])
xlabel('Orientation','FontSize',13)
legend('Presaccade - Neutral','FontSize',13)

cpsFigure(.7, .7); hold on;
temp = CI_D.a(1,:);% - min(CI_D.a(1,:));
plot(OriStep,temp,'color','r','LineWidth',2)
temp = CI_D.n(1,:);% - min(CI_D.n(1,:));
plot(OriStep,temp ,'k', OriStep, zeros(size(OriStep)),'--k')
ylim([-1 2])
xlabel('Orientation')
title('Tuning curve - sub','FontSize',13)
legend({'Attention','Neutral'})
tightfig;

cpsFigure(.7, .7); hold on;
temp = CI_D.a(1,:) - CI_D.n(1,:);
plot(OriStep,temp,'color','r','LineWidth',2)
plot(OriStep, zeros(size(OriStep)),'--k')
ylim([-1.5 1.5])
xlabel('Orientation','FontSize',13)
legend('Attention - Neutral')

%% GLM
cpsFigure(.7, .7); hold on;
cool = cool;
color = cool(1:64/3:64,:);
for t = 1:3
    temp = CI_glm.s(t,:);% - min(CI_D.s(t,:));
    plot(OriStep,temp,'color',color(t,:),'LineWidth',2)
end
temp = CI_glm.n(1,:);% - min(CI_D.n(1,:));
plot(OriStep,temp ,'k', OriStep, zeros(size(OriStep)),'--k')
ylim([-.3 .7])
xlabel('Orientation')
title('Tuning curve - GLM','FontSize',13)
legend({'pre -100ms','-100 ~ -50ms','-50 ~ 0ms','Neutral'},'FontSize',13)
tightfig;

cpsFigure(.7, .7); hold on;
temp = CI_glm.s(t,:) - CI_glm.n(1,:);
plot(OriStep,temp,'color',color(t,:),'LineWidth',2)
plot(OriStep, zeros(size(OriStep)),'--k')
ylim([-.4 .4])
xlabel('Orientation','FontSize',13)
legend('Presaccade - Neutral')

cpsFigure(.7, .7); hold on;
temp = CI_glm.a(1,:);% - min(CI_D.a(1,:));
plot(OriStep,temp,'color','r','LineWidth',2)
temp = CI_glm.n(1,:);% - min(CI_D.n(1,:));
plot(OriStep,temp ,'k', OriStep, zeros(size(OriStep)),'--k')
ylim([-.3 .7])
xlabel('Orientation')
title('Tuning curve - GLM','FontSize',13)
legend({'Attention','Neutral'})
tightfig;

cpsFigure(.7, .7); hold on;
temp = CI_glm.a(1,:) - CI_glm.n(1,:);
plot(OriStep,temp,'color','r','LineWidth',2)
plot(OriStep, zeros(size(OriStep)),'--k')
ylim([-.4 .4])
xlabel('Orientation','FontSize',13)
legend('Attention - Neutral','FontSize',13)

%%
filterResponse = squeeze(filterResponse);
SignalEn.all   = filterResponse(10,:);
SignalEn.pre   = filterResponse(10,targettype==1);
SignalEn.abs   = filterResponse(10,targettype==0);
nbin           = 3;
quantilestep   = linspace(0,1,nbin+1);
enbound.pre    = quantile(SignalEn.pre, quantilestep);
enbound.abs    = quantile(SignalEn.abs, quantilestep);

timStamp =[-300 -100;-100 -50;-50 0];
nInt     = size(timStamp,1);
for Int = 1:nInt
    for bin = 1:nbin
        
        
        timeIdx = Latency >= timStamp(Int,1) & Latency < timStamp(Int,2) & goodtrial==1 & response~=99  & SLatency > 100;
        EnIdx_pre   = SignalEn.all >= enbound.pre(bin) & SignalEn.all < enbound.pre(bin+1);
        EnIdx_abs   = SignalEn.all >= enbound.abs(bin) & SignalEn.all < enbound.abs(bin+1);
        
        %Saccade
        condIdx = saccade==2 & fcIdx==1 & timeIdx & EnIdx_pre';
        hit.s(Int,bin) = sum(response == 1 & targettype == 1 & condIdx) /  sum(targettype == 1 & condIdx);
        condIdx = saccade==2 & fcIdx==1 & timeIdx & EnIdx_abs';
        fa.s(Int,bin)  = sum(response == 1 & targettype == 0 & condIdx) /  sum(targettype == 0 & condIdx);
        ntrial.s(Int,bin) = sum(condIdx);
        
        %Neutral
        timeIdx = goodtrial==1 & response~=99;
        
        condIdx = saccade==1 & fcIdx==1 & timeIdx & EnIdx_pre';
        hit.n(Int,bin) = sum(response == 1 & targettype == 1 & condIdx) /  sum(targettype == 1 & condIdx);
        condIdx = saccade==1 & fcIdx==1 & timeIdx & EnIdx_abs';
        fa.n(Int,bin) = sum(response == 1 & targettype == 0 & condIdx) /  sum(targettype == 0 & condIdx);
        ntrial.n(Int,bin) = sum(condIdx);
        
        %Attention
        condIdx = saccade==3 & fcIdx==1 & timeIdx & EnIdx_pre';
        hit.a(Int,bin) = sum(response == 1 & targettype == 1 & condIdx) /  sum(targettype == 1 & condIdx);
        condIdx = saccade==3 & fcIdx==1 & timeIdx & EnIdx_abs';
        fa.a(Int,bin) = sum(response == 1 & targettype == 0 & condIdx) /  sum(targettype == 0 & condIdx);
        ntrial.a(Int,bin) = sum(condIdx);
    end
end
for bin = 1:nbin
    EnIdx_pre   = SignalEn.all >= enbound.pre(bin) & SignalEn.all < enbound.pre(bin+1);
    EnIdx_abs   = SignalEn.all >= enbound.abs(bin) & SignalEn.all < enbound.abs(bin+1);
    en_pre(bin) = mean(SignalEn.all(EnIdx_pre' & targettype==1));
    en_abs(bin) = mean(SignalEn.all(EnIdx_abs' & targettype==1));
end

cpsFigure(1,.5);
subplot(1,2,2)
plot(en_pre, hit.s','-o')
ylabel('hit')
ylim([0 1])
subplot(1,2,1)
plot(en_abs,fa.s','-o')
ylabel('fa')
ylim([0 1])
legend({'1','2','3'},'Location','Northwest','FontSize',14)

cpsFigure(1,.5);
subplot(1,2,2); hold on;
plot(en_pre,hit.n(1,:)','-ko')
plot(en_pre,hit.a(1,:)','-ro')
plot(en_pre,hit.s(3,:)','-bo')
ylabel('hit','FontSize',14)
ylim([0 1])
subplot(1,2,1); hold on;
plot(en_abs,fa.n(1,:)','-ko')
plot(en_abs,fa.a(1,:)','-ro')
plot(en_abs,fa.s(3,:)','-bo')
ylabel('fa','FontSize',14)
ylim([0 1])
legend({'Neu','Att','Sac'},'FontSize',14)





