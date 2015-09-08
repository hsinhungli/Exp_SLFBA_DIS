function [beta] = getglmSensitivityFunction(X,y,condIdx)

nChannel     = size(X,2);
nObservation = size(X,1);
assert(nObservation == length(y));

X = X(condIdx==1,:);
y = y(condIdx==1,:);
beta = nan(1,nChannel);

for i = 1:nChannel;
[b,~,~] = glmfit(X(:,i),y,'binomial','link','probit');
beta(i) = b(2);
end