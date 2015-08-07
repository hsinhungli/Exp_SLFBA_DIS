function   [visualOnsetTime] = drawFixation(varargin)
global stiPar
%3/26/09 Written by G.M. Boynton at the University of Washington
%2/19/12 modified by Hsin-Hung Li
% three input parameter:
% 1.scr
% 2. vbl: the reference time point
% 3. waitframes: the program will wait this number of frames (relative to vbl)
% and then do flip
% if there's only scr input, the program set vbl as the timing entering
% this function and set waitframes as 1;

if nargin==1; %use this script as the simple drawfixation
    scr=varargin{1};
    vbl=GetSecs;
    waitframes=0;
end
if nargin>1;
    scr=varargin{1};
    if varargin{2} == []
        vbl=GetSecs;
    else
        vbl=varargin{2};
    end
end
if nargin>2
    waitframes=varargin{3};
end
%Deal with default values
if ~isfield(scr,'fix')
    scr.fix = [];
end
%OuterSize
if ~isfield(scr.fix,'out_size')
    scr.fix.out_size = .5; %degrees
end
%InnerSize
if ~isfield(scr.fix,'in_size')
    scr.fix.in_size = .4;  %degrees
end
%Color
if ~isfield(scr.fix,'color')
    scr.fix.color = {[255,255,255,1],[0,0,0,1]};
end
%Flip
if ~isfield(scr.fix,'flip')
    scr.fix.flip = 1;  %flip by default
end
%Cue related
if ~isfield(scr.fix,'fc')
    scr.fix.fc = 0;  %flip by default
end
if ~isfield(scr.fix,'sc')
    scr.fix.sc = 0;  %flip by default
end
if ~isfield(scr.fix,'postcueOn')
    scr.fix.postcueOn = 0;  %flip by default
end
if ~isfield(scr.fix,'ITI')
    scr.fix.ITI = 0;  %flip by default
end

center = scr.center; %in pixel value on the screen


%% Draw Oval
Screen('DrawDots', scr.windowPtr, scr.center',scr.fix.out_size,scr.fix.color{1},[],1);
Screen('DrawDots', scr.windowPtr, scr.center',scr.fix.in_size,128,[],1);
%% Draw Line
sz = scr.fix.out_size/2;
tempsz = sz/sqrt(2);
Vbarpos = [center(1) center(1);...
    center(2)-tempsz center(2)+tempsz];
Hbarpos = [center(1)+tempsz center(1)-tempsz;...
    center(2) center(2)];
switch scr.fix.fc
    case 0
        Lcolor = [0,0,0]';
        Rcolor = [0,0,0]';
        %Screen('DrawLines',scr.windowPtr,Lbarpos,scr.fix.barWidth,Lcolor,[],1);
        %Screen('DrawLines',scr.windowPtr,Rbarpos,scr.fix.barWidth,Rcolor,[],1);
    case 1
        Lcolor = stiPar.green';
        %Rcolor = [0,0,0]';
        Screen('DrawLines',scr.windowPtr,Vbarpos,scr.fix.barWidth,Lcolor,[],1);
        %Screen('DrawLines',scr.windowPtr,Rbarpos,scr.fix.barWidth,Rcolor,[],1);
    case 2
        %Lcolor = [0,0,0]';
        Rcolor = stiPar.green';
        %Screen('DrawLines',scr.windowPtr,Lbarpos,scr.fix.barWidth,Lcolor,[],1);
        Screen('DrawLines',scr.windowPtr,Hbarpos,scr.fix.barWidth,Rcolor,[],1);
    case 3
        Lcolor = stiPar.green';
        Rcolor = stiPar.green';
        Screen('DrawLines',scr.windowPtr,Vbarpos,scr.fix.barWidth,Lcolor,[],1);
        Screen('DrawLines',scr.windowPtr,Hbarpos,scr.fix.barWidth,Rcolor,[],1);
end
%% Draw Aperture
% if scr.fix.ITI == 0
% placerct = [ ...
%     CenterRectOnPoint([0,0,stiPar.gaborpsiz,stiPar.gaborpsiz]*1.1,stiPar.gaborPosition(1,1), stiPar.gaborPosition(1,2)); ...
%     CenterRectOnPoint([0,0,stiPar.gaborpsiz,stiPar.gaborpsiz]*1.1,stiPar.gaborPosition(2,1), stiPar.gaborPosition(2,2))];
% Screen('FrameOval', scr.windowPtr, stiPar.pink, placerct(1,:), 3);
% Screen('FrameOval', scr.windowPtr, stiPar.blue, placerct(2,:), 3);
% end

for targetIdx = 1:2
    if targetIdx == 1
        color = stiPar.pink;
    elseif targetIdx ==2
        color = stiPar.blue;
    end
    xymatrix = [stiPar.gaborPosition(targetIdx,1)+angle2pix(scr,1) stiPar.gaborPosition(targetIdx,2)+angle2pix(scr,1.4);
        stiPar.gaborPosition(targetIdx,1)+angle2pix(scr,1) stiPar.gaborPosition(targetIdx,2)-angle2pix(scr,1.4);
        stiPar.gaborPosition(targetIdx,1)-angle2pix(scr,1) stiPar.gaborPosition(targetIdx,2)-angle2pix(scr,1.4);
        stiPar.gaborPosition(targetIdx,1)-angle2pix(scr,1) stiPar.gaborPosition(targetIdx,2)+angle2pix(scr,1.4)];
    Screen('DrawDots', scr.windowPtr, xymatrix(1:2,:)', 8, color,[],1);
    Screen('DrawDots', scr.windowPtr, xymatrix(3:4,:)', 8, color,[],1);
end
%% Draw Saccade Target
% if scr.fix.ITI == 0
% if scr.fix.postcueOn == 0
% strct = [ ...
%     CenterRectOnPoint([0,0,scr.st.size,scr.st.size],stiPar.gaborPosition(1,1), stiPar.gaborPosition(1,2)); ...
%     CenterRectOnPoint([0,0,scr.st.size,scr.st.size],stiPar.gaborPosition(2,1), stiPar.gaborPosition(2,2))];
% Screen('FrameOval', scr.windowPtr, [0 0 0], strct(2,:),scr.st.Width);
% Screen('FrameOval', scr.windowPtr, [0 0 0], strct(1,:),scr.st.Width);
% end
% end
%% Draw Saccade Cue
if scr.fix.sc ==1
    scpos = [-sz(1)+center(1),-angle2pix(scr,stiPar.scLength)-sz(1)+center(1); center(2), center(2)];
    Screen('DrawLine',scr.windowPtr,[0 0 0],scpos(1,1),scpos(2,1),scpos(1,2),scpos(2,2),4);
elseif scr.fix.sc ==2
    scpos = [sz(1)+center(1),angle2pix(scr,stiPar.scLength)+sz(1)+center(1); center(2), center(2)];
    Screen('DrawLine',scr.windowPtr,[0 0 0],scpos(1,1),scpos(2,1),scpos(1,2),scpos(2,2),4);
elseif scr.fix.sc ==3
    scpos = [sz(1)+center(1),angle2pix(scr,stiPar.scLength)+sz(1)+center(1); center(2), center(2)];
    Screen('DrawLine',scr.windowPtr,[0 0 0],scpos(1,1),scpos(2,1),scpos(1,2),scpos(2,2),4);
    scpos = [-sz(1)+center(1),-angle2pix(scr,stiPar.scLength)-sz(1)+center(1); center(2), center(2)];
    Screen('DrawLine',scr.windowPtr,[0 0 0],scpos(1,1),scpos(2,1),scpos(1,2),scpos(2,2),4);
end
%% Draw Post Cue
if scr.fix.postcueOn ==1
    %     if scr.fix.postcuePos == 1;
    %         center = stiPar.gaborPosition(1,:);
    %     elseif  scr.fix.postcuePos == 2;
    %         center = stiPar.gaborPosition(2,:);
    %     end
    if scr.fix.postsc == 1;
        center = stiPar.gaborPosition(1,:);
    elseif scr.fix.postsc == 2;
        center = stiPar.gaborPosition(2,:);
    elseif scr.fix.postsc == 3;
        center = scr.center;
    end
    if scr.fix.postsccol == 1
        cueColor = stiPar.pink;
    elseif scr.fix.postsccol == 2
        cueColor = stiPar.blue;
    end
    sz = scr.st.size/2;
    rect = [-sz+center(1),-sz+center(2),sz+center(1),sz+center(2)];
    Screen('FillOval', scr.windowPtr, cueColor, rect);
    
    sz = scr.fix.out_size/2;
    tempsz = sz*1.4;
    Vbarpos = [center(1) center(1);...
        center(2)-tempsz center(2)+tempsz];
    Hbarpos = [center(1)+tempsz center(1)-tempsz;...
        center(2) center(2)];
    
    if scr.fix.postfc == 1
        %Screen('DrawLine',scr.windowPtr,[0 0 0],Lbarpos(1,1),Lbarpos(2,1),Lbarpos(1,2),Lbarpos(2,2),4);
        Screen('DrawLines',scr.windowPtr,Vbarpos,scr.fix.barWidth,0,[],1);
        %disp('DrawL');
    elseif scr.fix.postfc == 2
        %Screen('DrawLine',scr.windowPtr,[0 0 0],Rbarpos(1,1),Rbarpos(2,1),Rbarpos(1,2),Rbarpos(2,2),4);
        Screen('DrawLines',scr.windowPtr,Hbarpos,scr.fix.barWidth,0,[],1);
        %disp('DrawR');
    end
end
%%
OnsetTime=vbl + (waitframes - 0.5) * scr.ifi;
if scr.fix.flip
    visualOnsetTime = Screen('Flip',scr.windowPtr, OnsetTime);
end
%img=Screen('GetImage', scr.windowPtr,[0 0 250 320]);