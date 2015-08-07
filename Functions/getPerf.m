function [pc, dprime, ntrial] = getPerf(correct, response, targettype)


dprime = nan;

Idx = ismember(response, [0 1]);
pc  = mean(correct(Idx));
ntrial = sum(Idx);

if nargin ==3
    hit = sum(response(Idx) == 1 & targettype(Idx) == 1) / sum(targettype(Idx)==1);
    fa  = sum(response(Idx) == 1 & targettype(Idx) == 0) / sum(targettype(Idx)==0);
    dprime = norminv(hit) - norminv(fa);
end

