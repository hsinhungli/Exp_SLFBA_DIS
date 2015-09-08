function [sse, tuning] = myFunc_TuningGaussian(ori, par, y)
%fit a raised Guassian to the tuning function

center = par(1);
gain   = par(2);
sigma  = par(3);
p      = par(4);
baseline = par(5);

tuning = gain * (exp(-(ori-center).^2 / (2*sigma^2))).^p + baseline;

sse = (y-tuning)*(y-tuning)';
end

