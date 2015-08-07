InitializePsychSound;
scr.Snd = PsychPortaudio('Open', [], [], 0, 44100, 2);

PsychPortaudio('FillBuffer', scr.Snd, stiPar.cSnd'*.5);
t1 = PsychPortaudio('Start', scr.Snd, 1, 0, 1);
%%
%Set Up auditory Environment/Parameter
AssertOpenGL;

% Perform basic initialization of the sound driver:
%InitializeMatlabOpenAL(2);
InitializePsychSound;
PsychPortAudio('Verbosity', 10);

%Setting Portaudio Parameters
au.fre=44100;
au.reqlatencyclass=1;
au.nrchannels=2;

au.pahandle = PsychPortAudio('Open', [], [], au.reqlatencyclass, au.fre, au.nrchannels);
bufferhandle = PsychPortAudio('FillBuffer', au.pahandle ,stiPar.iSnd'*.8);
PsychPortAudio('Start',au.pahandle);