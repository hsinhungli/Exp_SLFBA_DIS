clear all; close all;
folderName   = 'LH'; %Usually this is the subject ID
expIdx       = 'LH_EXP_';    %The initial of the experiment data file
readSacInfo  = 1;          %Use the eye-tracking timing from eyelink
readStim     = 1;
selectIdx    = ':';              %Analyze a subset of files
getAllInfo;
fcIdx = prefc == postfc;
poolRT= (sec - stimOFF)*1000;

savemData  = 0;
if savemData == 1
    mData.name = folderName;
    mDataFileName = sprintf('./%s/%s_mData',folderName,folderName);
end
%% Plot Saccade-related distribution
%Get latency between stimulus offset and saccade onset
condIdx = saccade ==2;
mData.latencyInt   = -400:10:200;
mData.latencycount = histcounts(Latency(condIdx), mData.latencyInt);
cpsFigure(.6,.4);
H = area(mData.latencyInt(1:end-1), mData.latencycount);
set(H,'EdgeColor','none', 'FaceColor',[1 .5 .5])
xlim([-350 300])
text(-300, 50, [num2str(nanmedian(Latency(condIdx))) ' msec']);
text(-300, 10, ['%goodtrial ' num2str(mean(goodtrial(condIdx)))]);
xlabel('StiOffset - sacOnset (ms)')
ylabel('Count')

mData.SlatencyInt   = 0:10:400;
mData.Slatencycount = histcounts(SLatency(condIdx), mData.SlatencyInt);
cpsFigure(.6,.4)
H = area(mData.SlatencyInt(1:end-1),mData.Slatencycount);
set(H,'EdgeColor','none', 'FaceColor',[1 .5 .5]);
text(10, 5, [num2str(nanmedian(SLatency(condIdx))) ' msec']);
xlabel('saccade latency (ms)')
ylabel('Count')
%% Analysis based on Saccade onset time
xansession = 1:6;
tStamp     =[-150 -100; -100 -50;-50 0;0 36;36 86];
%tStamp     =[-150  -100; -100 -75;-75 -50; -50 -25;-25 0;0 30;30 55];
%timStamp   = [-200 -100; -100 0; 0 30; 30 130];

nInt       = size(tStamp,1);
hit        = [];
fa         = [];
dprime     = [];
pc         = [];
bias       = [];
ntrial     = [];
selectIdx  = ismember(sessionNumber, xansession);% & ~(sessionNumber==6 & blockNumber==1);
goodIdx    = goodtrial == 1 & responsehand == targetloc & ismember(response,[1 -1]);

for Int = 1:nInt
    %saccade trials
    timeIdx       = Latency >= tStamp(Int,1) & Latency < tStamp(Int,2) & SLatency > 100;
    condIdx       = saccade==2 & timeIdx & selectIdx & goodIdx & fcIdx;
    ntrial.s(Int) = sum(condIdx);
    pc.s(Int)     = sum(condIdx & correct==1) / ntrial.s(Int);
    dprime.s(Int) = sqrt(2)*pc.s(Int);
    RT.s(Int)     = median(poolRT(condIdx));
    
    %neutral trials
    timeIdx       = goodtrial==1;
    condIdx       = saccade==1 & timeIdx & selectIdx & goodIdx & fcIdx;
    ntrial.n(Int) = sum(condIdx);
    pc.n(Int)     = sum(condIdx & correct==1) / ntrial.n(Int);
    dprime.n(Int) = sqrt(2)*pc.n(Int);
    RT.n(Int)     = median(poolRT(condIdx));
    
    %attention trials
    timeIdx       = goodtrial==1;
    condIdx       = saccade==3 & timeIdx & selectIdx & goodIdx & fcIdx;
    ntrial.a(Int) = sum(condIdx);
    pc.a(Int)     = sum(condIdx & correct==1) / ntrial.a(Int);
    dprime.a(Int) = sqrt(2)*pc.a(Int);
    RT.a(Int)     = median(poolRT(condIdx)); 
end

if savemData == 1
    mData.tStamp = tStamp;
    mData.ntrial = ntrial;
    mData.hit    = hit;
    mData.fa     = fa;
    mData.pc     = pc;
    mData.dprime = dprime;
    mData.bias   = bias;
    mData.RT     = RT;
end
%%
%Plot dprime
cpsFigure(.5,.5);
tlist = mean(tStamp,2);
plot(tlist, dprime.s,'-bo', tlist, dprime.n, '-k', tlist, dprime.a, '-g');hold on
text(tlist, ones(1,length(tlist))*1.9, num2cell(ntrial.s), 'Color','b');
%legend({'Saccade trials','Neutral trials','Attention trials'},'FontSize',18,'Location','southwest');
tmark = unique(tStamp(:));
for i = 1:numel(tmark);
    plot([tmark(i) tmark(i)]', [-2 3.5]',':k');
end
xlim([-150 100]);
ylim([-0 2]);
xlabel('StiOffset - sacOnset (ms)')
ylabel('dprime','Fontsize',18)
drawnow;

%plotRT
cpsFigure(.6,.5);
tlist = mean(tStamp,2);
plot(tlist, RT.s,'-bo', tlist, RT.n, '-k', tlist, RT.a, '-g');hold on
tmark = unique(tStamp(:));
for i = 1:numel(tmark);
    plot([tmark(i) tmark(i)]', [0 1000]',':k');
end
xlim([-150 100]);
ylim([200 700]);
xlabel('StiOffset - sacOnset (ms)')
ylabel('RT','Fontsize',18)
drawnow;

%Plot accuracy
% cpsFigure(1,.7);
% tlist = mean(timStamp,2);
% plot(tlist, pc.s,'-bo', tlist, pc.n, '-ko', tlist, pc.a, '-go');hold on
% text(tlist, ones(1,length(tlist))*.95, num2cell(ntrial.s), 'Color','b');
% text(tlist, ones(1,length(tlist))*.90, num2cell(ntrial.n), 'Color','k');
% text(tlist, ones(1,length(tlist))*.85, num2cell(ntrial.a), 'Color','g');
% legend({'Saccade trials','Neutral trials','Attention trials'},'FontSize',18,'Location','southwest');
% tmark = unique(timStamp(:));
% for i = 1:numel(tmark);
%     plot([tmark(i) tmark(i)]', [0 1]',':k');
% end
% xlim([-150 100]);
% ylim([.4 1]);
% xlabel('StiOffset - sacOnset (ms)','Fontsize',18)
% ylabel('percentage correct','Fontsize',18)
% drawnow;
%%
clear temp*
condIdx = saccade == 2;
onsetTimeLevel  = unique(onsetTime);
onsetFrameLevel = onsetTimeLevel*4;
for i = 1:length(onsetTimeLevel)
    
    temp_latency(i)      = nanmean(Latency(condIdx & onsetTime == onsetTimeLevel(i)));
    tempdist_latency{i}  = Latency(condIdx & onsetTime == onsetTimeLevel(i));
    if isempty(tempdist_latency{i})
        tempdist_latency{i} = 0;
    end
    
    temp_Slatency(i)     = nanmedian(SLatency(condIdx & onsetTime == onsetTimeLevel(i)));
    tempdist_Slatency{i} = SLatency(condIdx & onsetTime == onsetTimeLevel(i));
    if isempty(tempdist_Slatency{i})
        tempdist_Slatency{i} = 0;
    end
    
end

figure;
for i = 1:length(onsetTimeLevel)
    plot(onsetTimeLevel(i),tempdist_latency{i},'o'); hold on;
end
ylabel('StiOffset - sacOnset (ms)','FontSIze',14)
xlabel('onsetTime','FontSIze',14)

figure;
plot(onsetTimeLevel,temp_Slatency,'-o')
ylim([150 300])
ylabel('Saccade Latency (ms)','FontSIze',14)
xlabel('onsetTime','FontSIze',14)
figure;
for i = 1:length(onsetTimeLevel)
    plot(onsetTimeLevel(i),tempdist_Slatency{i},'o'); hold on;
end
ylabel('Saccade Latency (ms)','FontSIze',14)
xlabel('onsetTime','FontSIze',14)

%timStamp =[-200 -150;-150 -100; -100 -50;-50 0;0 40;40 90];
figure;
for Int = 1:nInt
    timeIdx = saccade == 2 & Latency >= tStamp(Int,1) & Latency < tStamp(Int,2) & goodtrial==1;
    subplot(1,nInt,Int)
    hist(round(onsetTime(timeIdx)./(1/85)))
    xlim([1 23])
end

if savemData == 1
    mData.onsetTimeLevel         = onsetTimeLevel;
    mData.onsetTime_Slatency     = temp_Slatency;
    mData.onsetTime_SlatencyDist = tempdist_Slatency;
end
%% Analysis based on ISI
SOA ={1:5,6:10,11:15,16:21};
%SOA ={44:48,49:53,54:58,59:63};
tempIdx = round(onsetTime/(1/85));

nInt_SOA   = numel(SOA);
hit_SOA    = [];
fa_SOA     = [];
dprime_SOA = [];
bias_SOA   = [];
ntrial_SOA = [];

for Int = 1:nInt_SOA
    %neutral trials
    timeIdx       = goodtrial==1;
    condIdx       = saccade==2 & timeIdx & ismember(tempIdx, SOA{Int}) & selectIdx;
    ntrial_SOA.s(Int) = sum(condIdx);
    hit_SOA.s(Int)    = sum(condIdx & targettype==1 & response==1) / sum(condIdx & targettype==1);
    fa_SOA.s(Int)     = sum(condIdx & targettype==0 & response==1) / sum(condIdx & targettype==0);
    pc_SOA.s(Int)         = sum(condIdx & correct==1) / ntrial_SOA.s(Int);
    dprime_SOA.s(Int) = norminv(hit_SOA.s(Int)) - norminv(fa_SOA.s(Int));
    
    %neutral trials
    timeIdx       = goodtrial==1;
    condIdx       = saccade==1 & timeIdx & ismember(tempIdx, SOA{Int}) & selectIdx;
    ntrial_SOA.n(Int) = sum(condIdx);
    hit_SOA.n(Int)    = sum(condIdx & targettype==1 & response==1) / sum(condIdx & targettype==1);
    fa_SOA.n(Int)     = sum(condIdx & targettype==0 & response==1) / sum(condIdx & targettype==0);
    pc_SOA.n(Int)         = sum(condIdx & correct==1) / ntrial_SOA.n(Int);
    dprime_SOA.n(Int) = norminv(hit_SOA.n(Int)) - norminv(fa_SOA.n(Int));
    
    
    %attention trials
    condIdx       = saccade==3 & timeIdx & ismember(tempIdx, SOA{Int}) & selectIdx;
    ntrial_SOA.a(Int) = sum(condIdx);
    hit_SOA.a(Int)    = sum(condIdx & targettype==1 & response==1) / sum(condIdx & targettype==1);
    fa_SOA.a(Int)     = sum(condIdx & targettype==0 & response==1) / sum(condIdx & targettype==0);
    pc_SOA.a(Int)     = sum(condIdx & correct==1) / ntrial_SOA.a(Int);
    dprime_SOA.a(Int) = norminv(hit_SOA.a(Int)) - norminv(fa_SOA.a(Int));
end

if savemData == 1
    mData.ntrial_SOA = ntrial_SOA;
    mData.hit_SOA    = hit_SOA;
    mData.fa_SOA     = fa_SOA;
    mData.pc_SOA     = pc_SOA;
    mData.dprime_SOA = dprime_SOA;
end

cpsFigure(.5,.5);
tlist = 1:nInt_SOA;
plot(tlist, dprime_SOA.s, '-bo', tlist, dprime_SOA.n, '-ko', tlist, dprime_SOA.a, '-go');hold on
% text(tlist, ones(1,length(tlist))*2.4, num2cell(ntrial.n), 'Color','k');
% text(tlist, ones(1,length(tlist))*2.2, num2cell(ntrial.a), 'Color','g');
%legend({'Saccade trials','Neutral trials','Attention trials'},'FontSize',18,'Location','southwest');
xlim([.7 4.3]);
ylim([0 2]);
xlabel('ISI bin','FontSize',18)
ylabel('dprime','FontSize',18)

if savemData == 1
    fprintf('saving meta Data file\n')
    save(mDataFileName, 'mData')
end