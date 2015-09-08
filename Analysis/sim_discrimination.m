ori = -90:1:90;

gain   = 1;
sigma  = 10;
p      = 1;
baseline = 0;

center = -5;
y   = zeros(size(ori));
par = [center,gain,sigma,p,baseline];
[~, tuning_l] = myFunc_TuningGaussian(ori, par, y);

center = 5;
par = [center,gain,sigma,p,baseline];
[~, tuning_r] = myFunc_TuningGaussian(ori, par, y);
[~,idx] = min(tuning_l - tuning_r);
ori(idx);

plot(ori, tuning_l, ori, tuning_r, ori,(tuning_l - tuning_r)');
hold on;