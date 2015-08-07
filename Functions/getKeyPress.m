function [response, presstime, responsehand, exit] = getKeyPress(PostStiPauseDur,ResponsePauseDur,ResponseDur)

%%
% PostStiPauseDur: Don't receive response within this interval (a blank
% interval between stimulus offset and response
% ResponsePauseDur: insert a blank interval after observer's response
% ResponseDur: The interval that allows for observer's response
%%
if notDefined('t0')
    t0 = GetSecs;
end
if notDefined('PostStiPauseDur')
    PostStiPauseDur = 0;
end
if notDefined('ResponsePauseDur')
    ResponsePauseDur = 0;
end
if notDefined('ResponseDur')
    ResponseDur = Inf;
end
FlushEvents('keyDown')
keyIsDown = 0;
exit      = 0;
response  = 99;
responsehand = nan;
while (GetSecs-t0 < ResponseDur) && keyIsDown == 0;
    if GetSecs-t0 < PostStiPauseDur
        %Dont get response in this interval
    else
        [keyIsDown, presstime, keyCode] = KbCheck;
        if keyIsDown == 1
            keyName=KbName(keyCode);
            if ~isempty(keyName)
                if iscell(keyName)
                    keyName=keyName{1};
                end
            else
                keyName='-';
            end
            keyName=keyName(1);
            if ismember(keyName, {'z','x'})
                responsehand = 1;
                if keyName=='z'
                    response=-1;
                elseif keyName=='x'
                    response=1;
                end
            elseif ismember(keyName, {'.','/'})
                responsehand = 2;
                if keyName =='.'
                    response=-1;
                elseif keyName =='/'
                    response=1;
                end
            elseif keyName=='E'
                responsehand = 2;
                exit=1;
                response=99;
            end
            WaitSecs(ResponsePauseDur);
        end
    end
end
if GetSecs-t0 > ResponseDur && keyIsDown == 0
    response = 99;
    presstime = nan;
end
