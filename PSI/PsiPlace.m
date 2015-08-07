function contIndex=PsiPlace(PSIpar)% function toTest=PsiPlace(pab,pr1ax,pr0ax,contRange)% This function places the next target contrast value % This is part of PSI procedure see Kontsevich & Tyler (in press)% %	??/??/97	LLK Wrote it%	3/2/98		CCC	Update for MATLAB 5.x %Get parameterspab=PSIpar.pab;pr1ax=PSIpar.pr1ax;pr0ax=PSIpar.pr0ax;contRange=PSIpar.contRange;% 1		p(r|x)    pr0x = pab' * pr0ax;    pr1x = 1 - pr0x;% 2		p(ab|x,r)	nx=length(contRange);    paxr0 = (pab*ones(1,nx)) .* pr0ax+0.0000000001;    paxr0 = paxr0 ./ (ones(size(pab))*sum(paxr0));    paxr1 = (pab*ones(1,nx)).*pr1ax+0.0000000001;    paxr1 = paxr1 ./ (ones(size(pab))*sum(paxr1));% 3		entropy    exr0 = -sum(paxr0 .* log(paxr0+0.0000000001));    exr1 = -sum(paxr1 .* log(paxr1+0.0000000001));% 4		expected entropy							    ex = pr0x .* exr0 + pr1x .* exr1;% 5		placing the new trial %		What we do here is to find the index that have the minimal %		expected entropy.    [NULL contIndex] = min(ex);