function [FilterResponse, PhaseValue] = GetFilterEnergy(freStep, OriStep, patch, stiPar, scr)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

nFre = length(freStep);
nOri = length(OriStep);
nImg = length(patch);
FilterResponse = nan(nFre, nOri, nImg);
PhaseValue     = nan(nFre, nOri, nImg);
lumibg = patch{1}(1,1);

for i = 1:nFre
    fre = freStep(i);
    for j = 1:nOri
        ori = OriStep(j);
        
        disp([i j])
        phase = 0;
        filter1 = CreateGabor(scr, stiPar.apersiz, stiPar.gaborstd, fre, phase, ori, 1);
        phase = pi/2;
        filter2 = CreateGabor(scr, stiPar.apersiz, stiPar.gaborstd, fre, phase, ori, 1);
        
        mask  = CreateCircularAperture(scr, stiPar.apersiz);
        filter1 = filter1.*mask;
        filter2 = filter2.*mask;
        filter1 = filter1/sqrt(sum(filter1(:).^2));
        filter2 = filter2/sqrt(sum(filter2(:).^2));
        
        for k = 1:nImg
            %fresp(i) = sum((patch(:)-lumibg).*templ(:))/sum(templ(:).^2)/min(2*lumibg,2*(1-lumibg));
            tempImg = patch{k}-lumibg;
            sinImg = tempImg(:)'*filter1(:);
            cosImg = tempImg(:)'*filter2(:);
            FilterResponse(i,j,k) = sqrt((sinImg)^2 + (cosImg)^2);
            PhaseValue(i,j,k)     = atan2(cosImg, sinImg);
        end
    end
end
end

