function pf = dprime(a, b, x, pcorr)

k=erfinv((pcorr-0.5)*2);
pf=erf(k*10..^((x-a)*b));
   
