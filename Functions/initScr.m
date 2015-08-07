function initScr

global scr

%Experimental Environment
scr.dist =57;	%viewing distance in cm
scr.width = 39;
scr.height = 30;
initx = 0;
inity = 0;
%Setting up Screen
AssertOpenGL;
screens=Screen('Screens');
screenNumber=max(screens);
scr.white=WhiteIndex(screenNumber);
scr.black=BlackIndex(screenNumber);
scr.gray=round((scr.white+scr.black)/2);
scr.inc=scr.white-scr.gray;
scr.bgColor=scr.gray;

[w, scr.windowRect]=Screen(screenNumber,'OpenWindow',scr.bgColor);
[center(1), center(2)] = RectCenter(scr.windowRect);
scr.center=center;
scr.frameRate=FrameRate(w);
scr.windowPtr=w;
scr.controlwinRect=[1920 1080];
priorityLevel=MaxPriority(w);
Priority(priorityLevel);
scr.ifi=Screen('GetFlipInterval', w);
scr.colDept = 8;
Screen('BlendFunction', scr.windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Caculating additional monitor parameters
scr.resolution=[scr.windowRect(3) scr.windowRect(4)];
scr.xres = scr.resolution(1);
scr.yres = scr.resolution(2);
scr.midx=(scr.resolution(1)-initx)/2;										% Center of monitor
scr.midy=(scr.resolution(2)-inity)/2;
scr.dppx=atan(scr.width*.5/scr.dist)/pi*180/(scr.resolution(1)/2);
scr.dppy=atan(scr.height*.5/scr.dist)/pi*180/(scr.resolution(2)/2);

%fixation parameter
scr.fix.out_size =angle2pix(scr,.6); % diameter in visual angle
scr.fix.in_size  =angle2pix(scr,.43);
scr.fix.dot_size =angle2pix(scr,.1);
scr.fix.barWidth =3;
scr.fix.deltaY=0; %relative to the center of the screen
scr.fix.deltaX=0; %relative to the center of the screen
scr.fix.positionshift=angle2pix(scr,[scr.fix.deltaX scr.fix.deltaY scr.fix.deltaX scr.fix.deltaY]);
scr.fix.center=[scr.center(1)+scr.fix.positionshift(1) ...
    scr.center(2)+scr.fix.positionshift(2)];
scr.fix.color= {[0,0,0],[scr.bgColor,scr.bgColor,scr.bgColor]};
%scr.fix.postcueOn= 0; %Default: no postcue on screen

scr.st.size =angle2pix(scr,.4);
scr.st.Width =angle2pix(scr,.09);
%assert(scr.frameRate < 61);

fprintf(1,'The resolution is %sx%s\n',num2str(scr.resolution(1)),num2str(scr.resolution(2)));
fprintf(1,'Refreshing rate is %s\n',num2str(scr.frameRate));
KbWait; (.5);
%%
load calibTableGray10714;
%Check CLUT
Screen('LoadNormalizedGammaTable', w, kron([1 1 1],linspace(0,1,256)'));
Screen('FillRect', w, 200, [1 1 500 500] );
Screen('Flip',w);
pause(.3); KbWait(-3);
Screen('LoadNormalizedGammaTable', w, calibTableGray10714);
Screen('FillRect', w, 200, [1 1 500 500] );
Screen('Flip',w);
pause(.3); KbWait(-3);