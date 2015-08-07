for i = 1:4
[pc, d, ntrial] = getPerf(trialInfo(i).correct,trialInfo(i).response,trialInfo(i).targettype);
fprintf('pc: %2.2f   dprime: %2.2f  ntrial: %1.0f \n', pc, d, ntrial)
end
