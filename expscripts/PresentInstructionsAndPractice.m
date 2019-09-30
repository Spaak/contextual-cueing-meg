function PresentInstructionsAndPractice(stim_practice, ptb, tex, btsi)

btsi.clearResponses();

txt = 'Thank you for participating in this experiment! Your will see displays consisting of several L-shaped stimuli and one T-shaped target. Your task is to indicate whether the T is rotated to the left or right. Press a button to see an example of a search display as you will see during the experiment, and press a button again to continue.';
PresentTextAndWait(ptb, btsi, txt);

DrawSearchArray(stim_practice, ptb, tex, 1);
DrawFixationDot(ptb, 1);
WaitSecs(0.5);
btsi.getResponse(inf, true);

txt = 'You will now perform a short practice block. Press the LEFT button to indicate a LEFTWARD ROTATED T, and the RIGHT button to indicate a RIGHTWARD ROTATED T. Feel free to ask any questions if you have them! Press a button to continue.';
PresentTextAndWait(ptb, btsi, txt);

txt = 'Throughout the experiment, please keep looking at the little dot in the center of the screen (so don''t move your eyes), and try to blink as little as possible. When you''re ready, press a button to start the practice block.';
PresentTextAndWait(ptb, btsi, txt);

stim_practice.resp_upright_right(:) = 0;

for k = 1:30
    RunSingleTrial(stim_practice, ptb, tex, btsi, k);
end

txt = 'Very good! Please contact the experimenter.';
PresentTextAndWait(ptb, btsi, txt);

end