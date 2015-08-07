function PresentBlockEnd(pc)
global const scr stimulus stiPar expPar timing

%%
mytext = ['Block finished. Accuracy: ' num2str(pc) '%'];
Screen(scr.windowPtr,'DrawText',mytext, 0.3 * scr.xres, 0.35 * scr.yres, [0 0 0]);

drawFixation(scr); WaitSecs(.5); KbWait(-3);
drawFixation(scr); WaitSecs(.5);