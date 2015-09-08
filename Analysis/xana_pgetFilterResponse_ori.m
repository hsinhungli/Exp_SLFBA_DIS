sublist = {'LH','HK','NM','EN'};
nsub    = numel(sublist);

for sub = 1:nsub
    subId = sublist{sub};
    fileName = sprintf('./%s/%s_mData_CI.mat',subId,subId);
    load(fileName)
    pData(sub) = mData_CI;
end

CI_D.s = [];
CI_D.n = [];
CI_D.a = [];
CI_glm.s = [];
CI_glm.n = [];
CI_glm.a = [];
CI_nT.s = [];
CI_nT.n = [];
CI_nT.a = [];
tStamp = mData_CI.tStamp;
OriStep = mData_CI.OriStep;
nOri = length(OriStep);
for sub = 1:nsub
    CI_D.s(:,:,sub) = pData(sub).CI_D.s;
    CI_D.n(:,:,sub) = pData(sub).CI_D.n;
    CI_D.a(:,:,sub) = pData(sub).CI_D.a;
    CI_glm.s(:,:,sub) = pData(sub).CI_glm.s;
    CI_glm.n(:,:,sub) = pData(sub).CI_glm.n;
    CI_glm.a(:,:,sub) = pData(sub).CI_glm.a;
    CI_nT.s = [CI_nT.s; pData(sub).CI_nT.s];
    CI_nT.a = [CI_nT.a; pData(sub).CI_nT.a];
    CI_nT.n = [CI_nT.n; pData(sub).CI_nT.n];
end

myColor = cool(4);

%%
cpsFigure(1.9, 1);
nt = size(tStamp,1);

for t = 1:nt
    subplot(2,nt,t); hold on;
    tempMatrix    = squeeze(CI_D.s(t,:,:))';
    temp_tuning_a = mean(tempMatrix);
    temp_std_a    = std(tempMatrix)/sqrt(nsub);
    tempMatrix    = squeeze(CI_D.n(1,:,:))';
    temp_tuning_n = mean(tempMatrix);
    temp_std_n    = std(tempMatrix)/sqrt(nsub);
    
    %myerrorbar(OriStep,temp_tuning, temp_std, [.7 .7 1]);
    lineProps.col      = {[1 .5 0],'k'};
    lineProps.width    = .2;
    lineProps.plotEdge = 0;
    mseb(OriStep,[temp_tuning_a; temp_tuning_n],[temp_std_a;temp_std_n],lineProps);
    
    plot(OriStep,zeros(1, nOri),'k.','MarkerSize',.2);
    %text(-90,-1, num2str(nT.s(t)),'FontSize',14);
    ylim([-1 2])
    xlim([-90 87])
    title(num2str(tStamp(t,:)));
    
    subplot(2,nt,t+nt); hold on;
    tempMatrix    = squeeze(CI_glm.s(t,:,:))';
    temp_tuning_a = mean(tempMatrix);
    temp_std_a    = std(tempMatrix)/sqrt(nsub);
    tempMatrix    = squeeze(CI_glm.n(1,:,:))';
    temp_tuning_n = mean(tempMatrix);
    temp_std_n    = std(tempMatrix)/sqrt(nsub);
    
    %myerrorbar(OriStep,temp_tuning, temp_std, [.7 .7 1]);
    lineProps.col      = {[1 .5 0],'k'};
    lineProps.width    = .2;
    lineProps.plotEdge = 0;
    mseb(OriStep,[temp_tuning_a; temp_tuning_n],[temp_std_a;temp_std_n],lineProps);
    
    plot(OriStep,zeros(1, nOri),'k.','MarkerSize',.2);
    %text(-90,-1, num2str(nT.s(t)),'FontSize',14);
    %ylim([-1 2])
    %xlim([-90 87])
    title(num2str(tStamp(t,:)));
    
    if t == nt
        legend({'Saccade','Neutral'},'FontSize',14)
    end
end
tightfig;

%% Plot endo exp
cpsFigure(.4, 1);

t  = 1;
nt = 1;
subplot(2,nt,t); hold on;
tempMatrix    = squeeze(CI_D.a(t,:,:))';
temp_tuning_a = mean(tempMatrix);
temp_std_a    = std(tempMatrix)/sqrt(nsub);
tempMatrix    = squeeze(CI_D.n(1,:,:))';
temp_tuning_n = mean(tempMatrix);
temp_std_n    = std(tempMatrix)/sqrt(nsub);

%myerrorbar(OriStep,temp_tuning, temp_std, [.7 .7 1]);
lineProps.col      = {[1 0 0],'k'};
lineProps.width    = .2;
lineProps.plotEdge = 0;
mseb(OriStep,[temp_tuning_a; temp_tuning_n],[temp_std_a;temp_std_n],lineProps);

plot(OriStep,zeros(1, nOri),'k.','MarkerSize',.2);
%text(-90,-1, num2str(nT.s(t)),'FontSize',14);
ylim([-1 2])
xlim([-90 87])

subplot(2,nt,t+nt); hold on;
tempMatrix    = squeeze(CI_glm.a(t,:,:))';
temp_tuning_a = mean(tempMatrix);
temp_std_a    = std(tempMatrix)/sqrt(nsub);
tempMatrix    = squeeze(CI_glm.n(1,:,:))';
temp_tuning_n = mean(tempMatrix);
temp_std_n    = std(tempMatrix)/sqrt(nsub);

%myerrorbar(OriStep,temp_tuning, temp_std, [.7 .7 1]);
lineProps.col      = {[1 0 0],'k'};
lineProps.width    = .2;
lineProps.plotEdge = 0;
mseb(OriStep,[temp_tuning_a; temp_tuning_n],[temp_std_a;temp_std_n],lineProps);

plot(OriStep,zeros(1, nOri),'k.','MarkerSize',.2);
%text(-90,-1, num2str(nT.s(t)),'FontSize',14);
%ylim([-1 2])
%xlim([-90 87])

if t == nt
    legend({'EndAtt','Neutral'},'FontSize',14)
end

tightfig;

%% fit
CI_glm.s(:,:,5) = mean(CI_glm.s,3);
CI_glm.n(:,:,5) = mean(CI_glm.n,3);
for sub = 1:5
    for t = 1:5
        
        temp_tuning = CI_glm.s(t,:,sub);
        temp_tuning(2:end) = (temp_tuning(2:end) + fliplr(temp_tuning(2:end)))/2;
        %temp_tuning = Scale(temp_tuning);
        f = @(x)myFunc_TuningGaussian(OriStep, x, temp_tuning);
        opt = optimoptions('fmincon','Algorithm','interior-point','Display','iter','MaxIter',5000);
        ub = [90, Inf, 60, 10, Inf]; %center; gain; sigma; power; baseline
        lb = [-90, 0, 0, .1, -Inf]; %center; gain; sigma; power; baseline
        x0 = [0, 1, 30, 1, 0];
        [x,fval,exitflag,output,grad,hessian] = fmincon(f,x0,[],[],[],[],lb,ub,[],opt);
        par.s(t,:,sub) = x;
        [~,fitCI_glm.s(t,:,sub)] = myFunc_TuningGaussian(OriStep, x, temp_tuning);
        
        if t==1
            temp_tuning = CI_glm.n(t,:,sub);
            temp_tuning(2:end) = (temp_tuning(2:end) + fliplr(temp_tuning(2:end)))/2;
            %temp_tuning = Scale(temp_tuning);
            f = @(x)myFunc_TuningGaussian(OriStep, x, temp_tuning);
            opt = optimoptions('fmincon','Algorithm','interior-point','Display','iter','MaxIter',5000);
            ub = [90, Inf, 60, 10, Inf]; %center; gain; sigma; power; baseline
            lb = [-90, 0, 0, .1, -Inf]; %center; gain; sigma; power; baseline
            x0 = [0, 1, 30, 1, 0];
            [x,fval,exitflag,output,grad,hessian] = fmincon(f,x0,[],[],[],[],lb,ub,[],opt);
            par.n(t,:,sub) = x;
            [~,fitCI_glm.n(t,:,sub)] = myFunc_TuningGaussian(OriStep, x, temp_tuning);
        end
    end
end
par.s(:,:,6) = mean(par.s(:,:,1:4),3);
par.n(:,:,6) = mean(par.n(:,:,1:4),3);

%%
gain.s = squeeze(par.s(:,2,:)); %t x sub
gain.n = squeeze(par.n(:,2,:));
sigma.s =squeeze(par.s(:,3,:));
sigma.n = squeeze(par.n(:,3,:));
peakness.s = squeeze(par.s(:,4,:));
peakness.n = squeeze(par.n(:,4,:));
baseline.s = squeeze(par.s(:,5,:));
baseline.n = squeeze(par.n(:,5,:));

%%
t = 3;

figure; hold on;
plot(gain.s(t,:),'o')
plot(1:6,gain.n,'-')
title('Gain')

figure; hold on;
plot(sigma.s(t,:),'-o')
plot(1:6,sigma.n,'-')
title('Width')

figure; hold on;
plot(peakness.s(t,:),'-o')
plot(1:6,peakness.n,'-')
title('Peakness')

figure; hold on;
plot(baseline.s(t,:),'-o')
plot(1:6,baseline.n,'-')
title('Baseline')

%disp(squeeze(par.s(3,:,5)));
%disp(squeeze(par.n(1,:,5)));
%plot(OriStep,squeeze(mean(CI_D.s(4,:,:),3)),'o',OriStep,squeeze(fitCI_D.s(4,:,5)),'-');