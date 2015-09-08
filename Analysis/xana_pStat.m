sublist = {'LH','HK','NM','EN'};
nsub    = numel(sublist);

for sub = 1:nsub
    subId = sublist{sub};
    fileName = sprintf('./%s/%s_mData.mat',subId,subId);
    load(fileName)
    pData(sub) = mData;
end

latencycount  = [];
Slatencycount = [];
dprime.s = [];
dprime.n = [];
dprime.a = [];
pc.s = [];
pc.n = [];
pc.a = [];
bias.s = [];
bias.n = [];
bias.a = [];
dprime_SOA.s = [];
dprime_SOA.n = [];
dprime_SOA.a = [];
RT.s = [];
RT.n = [];
RT.a = [];

for sub = 1:nsub
    latencycount  = [latencycount; pData(sub).latencycount];
    Slatencycount = [Slatencycount; pData(sub).Slatencycount];
    dprime.s = [dprime.s; pData(sub).dprime.s];
    dprime.n = [dprime.n; pData(sub).dprime.n];
    dprime.a = [dprime.a; pData(sub).dprime.a];
    bias.s = [bias.s; pData(sub).bias.s];
    bias.n = [bias.n; pData(sub).bias.n];
    bias.a = [bias.a; pData(sub).bias.a];
    pc.s = [pc.s; pData(sub).pc.s];
    pc.n = [pc.n; pData(sub).pc.n];
    pc.a = [pc.a; pData(sub).pc.a];
    dprime_SOA.s = [dprime_SOA.s; pData(sub).dprime_SOA.s];
    dprime_SOA.n = [dprime_SOA.n; pData(sub).dprime_SOA.n];
    dprime_SOA.a = [dprime_SOA.a; pData(sub).dprime_SOA.a];
    RT.s = [RT.s; pData(sub).RT.s];
    RT.a = [RT.a; pData(sub).RT.a];
    RT.n = [RT.n; pData(sub).RT.n];
end

myColor = cool(4);
%% Plot Saccade-related distribution
%Get latency between stimulus offset and saccade onset
latencyInt = mData.latencyInt;
cpsFigure(.8,.6);
H = area(latencyInt(1:end-1), latencycount');
set(H,'EdgeColor','none');
H(1).FaceColor =myColor(1,:);
H(2).FaceColor =myColor(2,:);
H(3).FaceColor =myColor(3,:);
H(4).FaceColor =myColor(4,:);
xlim([-300 200])
set(gca,'box','off')
xlabel('StiOffset - sacOnset (ms)')
ylabel('Count')

SlatencyInt = mData.SlatencyInt;
cpsFigure(.8,.6);
H = area(SlatencyInt(1:end-1),Slatencycount');
set(H,'EdgeColor','none');
H(1).FaceColor =myColor(1,:);
H(2).FaceColor =myColor(2,:);
H(3).FaceColor =myColor(3,:);
H(4).FaceColor =myColor(4,:);
xlim([0 400])
set(gca,'box','off')
xlabel('saccade latency (ms)')
legend(sublist,'FontSize',14);
ylabel('Count')

%% Plot dprime 
tStamp = mData.tStamp;
tlist = mean(mData.tStamp,2)';

cpsFigure(1,.8);hold on %plot dprime
tempstd = std(dprime.n)/2;
lineProps.col      = {'k'};
lineProps.width    = .1;
lineProps.plotEdge = 0;
H = mseb(tlist,mean(dprime.n),tempstd,lineProps);

tempu   = mean(dprime.s);
tempstd = std(dprime.s)/2;
h = myerrorbar(tlist,tempu, tempstd, 'b');
set(h,'LineWidth',1.5)
plot(tlist,mean(dprime.s),'-bo', tlist, mean(dprime.n), '-k', tlist, mean(dprime.a), '-g',...
    'LineWidth',2,'MarkerSize',8);

tmark = unique(tStamp(:));
for i = 1:numel(tmark);
    plot([tmark(i) tmark(i)]', [-2 3.5]',':k');
end
xlim([-150 ,max(tStamp(:))]);
ylim([.25 1.75]);
set(gca,'box','off')
xlabel('StiOffset - sacOnset (ms)','Fontsize',18)
ylabel('dprime','Fontsize',18)
drawnow;

%% Plot bias
cpsFigure(1,.8);hold on %plot dprime
tempstd = std(bias.n)/2;
lineProps.col      = {'k'};
lineProps.width    = .1;
lineProps.plotEdge = 0;
mseb(tlist,mean(bias.n),tempstd,lineProps);

tempu   = mean(bias.s);
tempstd = std(bias.s)/2;
h = myerrorbar(tlist,tempu, tempstd, 'b');
set(h,'LineWidth',1.5)
h = plot(tlist,mean(bias.s),'-bo', tlist, mean(bias.n), '-k', tlist, mean(bias.a), '-g',...
    'LineWidth',2,'MarkerSize',8);

tmark = unique(tStamp(:));
for i = 1:numel(tmark);
    plot([tmark(i) tmark(i)]', [-2 3.5]',':k');
end
xlim([-150 ,max(tStamp(:))]);
ylim([-.5 1]);
set(gca,'box','off')
xlabel('StiOffset - sacOnset (ms)','Fontsize',18)
ylabel('bias','Fontsize',18)
legend(h,{'Saccade','Neutral','Attention'},'FontSize',14)
drawnow;

%% Plot RT
cpsFigure(1,.8);hold on %plot dprime

tempu   = mean(RT.s);
tempstd = std(RT.s)/2;
h = myerrorbar(tlist,tempu, tempstd, 'b');
set(h,'LineWidth',1.5)
h = plot(tlist,mean(RT.s),'-bo', tlist, mean(RT.n), '-k', tlist, mean(RT.a), '-g',...
    'LineWidth',2,'MarkerSize',8);
tmark = unique(tStamp(:));
for i = 1:numel(tmark);
    plot([tmark(i) tmark(i)]', [0 1000]',':k');
end
xlim([-150 ,max(tStamp(:))]);
ylim([100 800]);
set(gca,'box','off')
xlabel('StiOffset - sacOnset (ms)','Fontsize',18)
ylabel('RT','Fontsize',18)
legend(h,{'Saccade','Neutral','Attention'},'FontSize',14)
drawnow;
%%
SOAstep = [3 8 13 18]./85 * 1000;

cpsFigure(1,.8); hold on;
tempu   = mean(dprime_SOA.s);
tempstd = std(dprime_SOA.s)/2;
h = myerrorbar(SOAstep,tempu, tempstd, 'b');
tempu   = mean(dprime_SOA.n);
tempstd = std(dprime_SOA.n)/2;
h = myerrorbar(SOAstep,tempu, tempstd, 'k');
tempu   = mean(dprime_SOA.a);
tempstd = std(dprime_SOA.a)/2;
h = myerrorbar(SOAstep,tempu, tempstd, 'g');
h = plot(SOAstep,mean(dprime_SOA.s),'-bo', SOAstep, mean(dprime_SOA.n), '-ko', SOAstep, mean(dprime_SOA.a), '-go',...
    'LineWidth',2,'MarkerSize',8);
ylim([.25 1.75]);
xlabel('ISI','Fontsize',18)
ylabel('dprime','Fontsize',18)
legend(h,{'Saccade','Neutral','Attention'},14)