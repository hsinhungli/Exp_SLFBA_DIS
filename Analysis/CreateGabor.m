function gabor = CreateGabor(scr, gaborsiz, gaborstd, gaborf, phase, theta, contrast)
%%
% scr: Screen parameters
% gaborsize: gabor width in visual angle
% gaborstd: std of the Gaussian modulator
% gaborf: gabor frequency: cycle per degree
% phase: phase
% contrast: contrast of the gabor
% There is no orientation parameter here. Rotate the texture when put on the scree.
%%
theta = -theta/180*pi;
visiblesize=angle2pix(scr, [gaborsiz gaborsiz]);
%[x,y]=meshgrid(-1*visiblesize/2:visiblesize/2, -1*visiblesize/2:1*visiblesize/2);
[x,y]=meshgrid(1:visiblesize, 1:visiblesize);
x = x-mean(x(:));
y = y-mean(y(:));
x = Scale(x)*gaborsiz-gaborsiz/2;
y = Scale(y)*gaborsiz-gaborsiz/2;

newx = cos(theta)*x - sin(theta)*y;
newy = sin(theta)*x + cos(theta)*y;

carrier      =cos(newx*gaborf*2*pi+phase);
modulator    =exp(-((newx/gaborstd).^2)-((newy/gaborstd).^2));
gabor        = carrier.*modulator*contrast;