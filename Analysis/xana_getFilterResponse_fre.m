clear all; 
close all;
drawnow;
folderName   = 'HK'; %Usually this is the subject ID
expIdx       = 'HK_EXPa_';    %The initial of the experiment data file
readSacInfo  = 1;           %Use the eye-tracking timing from eyelink
readStim     = 1;
selectIdx    = ':';              %Analyze a subset of files
getAllInfo;
fcIdx = prefc == postfc;
fileName      = sprintf('%s/filterResponse_a',folderName);

loadResponse  = 1;
saveResponse  = 0;
%%
if loadResponse == 0
    % filters to study
    freStep          = .25:.25:3.5;   % Spatial frequency tuning of the filters
    OriStep          = -90:10:87; % Orientation tuning of the filters
    nImg             = sum(numTrial);
    temp_patch       = patch;
    
    [filterResponse, PhaseValue] = GetFilterEnergy(freStep, OriStep, temp_patch, stiPar, scr);
    filterResponse(:,:,targetOri==90) = circshift(filterResponse(:,:,targetOri==90),9,2);
    
    X     = filterResponse;
    nFre  = length(freStep);
    nOri  = length(OriStep);
    nImg  = size(filterResponse,3);
    X     = squeeze(X); %fre x ori x nimg
    
    figure;
    subplot(1,2,1)
    imagesc(OriStep,freStep,mean(X(:,:,targettype==1),3),[min(X(:)) max(X(:))]/2);
    subplot(1,2,2)
    imagesc(OriStep,freStep,mean(X(:,:,targettype==0),3),[min(X(:)) max(X(:))]/2);
    drawnow;
    
    if saveResponse==1
        save(fileName, 'filterResponse','freStep','OriStep')
    end
elseif loadResponse == 1
    load(fileName);
    X     = filterResponse;
    nFre  = length(freStep);
    nOri  = length(OriStep);
    nImg  = size(filterResponse,3);
end
%%
dX = squeeze(filterResponse(:,OriStep == 0,:))';

figure;
plot(freStep,dX');
drawnow;

% Some preprocessing on the noise
ContrastLevel = unique(targetContrast);
for c = 1:length(ContrastLevel)
    Idx = targetContrast == ContrastLevel(c);
    dX(Idx, :) = bsxfun(@minus,dX(Idx, :),mean(dX(Idx, :),1));
end
Noise = std(dX(:,:),1);
dX = dX ./ repmat(Noise, size(dX,1),1);

figure; hold on;
plot(freStep,dX');
plot(freStep,mean(dX),'LineWidth',3);
plot(freStep,std(dX,1),'w','LineWidth',3);
drawnow;

%%
% Get Classification Image
timStamp   =[-500 -100; -100 -50;-50 0;0 36;36 200];
%timStamp =[-150 -125;-125 -100; -100 -75;-75 -50; -50 -25;-25 0;0 30;30 55];
nt       = size(timStamp,1);
goodIdx  = goodtrial == 1 & responsehand == targetloc & ismember(response,[1 0]);

for t = 1:nt
    
    %Saccade
    timeIdx = Latency >= timStamp(t,1) & Latency < timStamp(t,2) & SLatency > 100;
    condIdx = saccade==2 & timeIdx & goodIdx & fcIdx;
    Idx_H   = targettype==1 & response == 1 & condIdx == 1;
    Idx_F   = targettype==0 & response == 1 & condIdx == 1;
    Idx_M   = targettype==1 & response == 0 & condIdx == 1;
    Idx_C   = targettype==0 & response == 0 & condIdx == 1;
    
    CI_D.s(t,:) = mean(dX(Idx_H,:)) + mean(dX(Idx_F,:)) - mean(dX(Idx_M,:)) - mean(dX(Idx_C,:));
    %CI_D.s(t,:) = CI_D.s(t,:) - min(CI_D.s(t,:));
    CI_glm.s(t,:) = getglmSensitivityFunction(dX,response,condIdx);
    %CI_glm.s(t,:) = CI_glm.s(t,:) - min(CI_glm.s(t,:));
    nT.s(t) = sum(Idx_H)+sum(Idx_F)+sum(Idx_M)+sum(Idx_C);
end

t=1;
%Neutral
timeIdx = goodtrial == 1;
condIdx = saccade==1 & timeIdx & goodIdx & fcIdx;
Idx_H   = targettype==1 & response == 1 & condIdx == 1;
Idx_F   = targettype==0 & response == 1 & condIdx == 1;
Idx_M   = targettype==1 & response == 0 & condIdx == 1;
Idx_C   = targettype==0 & response == 0 & condIdx == 1;

CI_D.n(t,:) = mean(dX(Idx_H,:)) + mean(dX(Idx_F,:)) - mean(dX(Idx_M,:)) - mean(dX(Idx_C,:));
%CI_D.n(t,:) = CI_D.n(t,:) - min(CI_D.n(t,:));
CI_glm.n(t,:) = getglmSensitivityFunction(dX,response,condIdx);
%CI_glm.n(t,:) = CI_glm.n(t,:) - min(CI_glm.n(t,:));
nT.n(t) = sum(Idx_H)+sum(Idx_F)+sum(Idx_M)+sum(Idx_C);

%Attention
timeIdx = goodtrial == 1;
condIdx = saccade==3 & timeIdx & goodIdx & fcIdx;
Idx_H   = targettype==1 & response == 1 & condIdx == 1;
Idx_F   = targettype==0 & response == 1 & condIdx == 1;
Idx_M   = targettype==1 & response == 0 & condIdx == 1;
Idx_C   = targettype==0 & response == 0 & condIdx == 1;

CI_D.a(t,:) = mean(dX(Idx_H,:)) + mean(dX(Idx_F,:)) - mean(dX(Idx_M,:)) - mean(dX(Idx_C,:));
%CI_D.a(t,:) = CI_D.a(t,:) - min(CI_D.a(t,:));
CI_glm.a(t,:) = getglmSensitivityFunction(dX,response,condIdx);
%CI_glm.a(t,:) = CI_glm.a(t,:) - min(CI_glm.a(t,:));
nT.a(t) = sum(Idx_H)+sum(Idx_F)+sum(Idx_M)+sum(Idx_C);

%%
cpsFigure(1.9, 1);
for t = 1:nt
    subplot(2,nt,t); hold on;
    %myerrorbar(freStep,CI_D(t,:), CI_D_bootstd(t,:),[.7 .7 1]);
    plot(freStep,CI_D.s(t,:),'b-');
    plot(freStep,CI_D.n(1,:),'k-');
    %plot(freStep,CI_D.a(1,:),'r-');
    plot(freStep,zeros(1, nFre),'k.','MarkerSize',.2);
    text(0,-.4, num2str(nT.s(t)),'FontSize',14);
    ylim([-1 2])
    %xlim([-90 87])
    title(num2str(timStamp(t,:)));
    
    subplot(2,nt,t+nt)
    plot(freStep,CI_glm.s(t,:),'b-'); hold on;
    plot(freStep,CI_glm.n(1,:),'k-');
    %plot(freStep,CI_glm.a(1,:),'r-');
    plot(freStep,zeros(1, nFre),'k.','MarkerSize',.2);
    %text(-90,-.1, num2str(nT.s(t)),'FontSize',14);
    %xlim([-90 87])
    ylim([-0.5 1])
    title(num2str(timStamp(t,:)));
end
tightfig;

cpsFigure(.4, .4); hold on;
plot(freStep,CI_D.n(1,:),'k-');
plot(freStep,CI_D.a(1,:),'r-');
plot(freStep,zeros(1, nFre),'k.','MarkerSize',.2);
%text(-90,-1, num2str(nT.a(1)),'FontSize',14);
ylim([-1 2])

cpsFigure(.4, .4); hold on;
plot(freStep,CI_glm.n(1,:),'k-');
plot(freStep,CI_glm.a(1,:),'r-');
plot(freStep,zeros(1, nFre),'k.','MarkerSize',.2);
%ext(-90,-1, num2str(nT.a(1)),'FontSize',14);
ylim([-0.5 1])