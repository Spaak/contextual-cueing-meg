function stim = PresentRecognitionInstructions(stim, ptb, btsi)

btsi.clearResponses();

txt = 'Done with the main task! Take a short break if you want, then press a button to continue to answering a few questions.';
PresentTextAndWait(ptb, btsi, txt);

txt = 'Did you have the feeling that some of the search displays occurred multiple times over the course of the experiment? Press the LEFT BUTTON for YES and the RIGHT BUTTON for NO.';
[stim.resp_recogyesno, ~] = PresentTextAndWait(ptb, btsi, txt);

txt = 'How sure are you about your answer to the previous question? Press the LEFT BUTTON for VERY SURE and the RIGHT BUTTON for NOT VERY SURE.';
[stim.resp_recogconfidence, ~] = PresentTextAndWait(ptb, btsi, txt);

txt = 'Now please perform one final (extra short) block, but the task is now different! Some of the search displays occurred multiple times in the experiment. We now want to test your memory for these. Press a button to continue and read the new instructions carefully.';
PresentTextAndWait(ptb, btsi, txt);

txt = 'Instead of searching for a T, please indicate whether you think you saw the search display during the main task. Press the LEFT BUTTON for YES and the RIGHT BOTTON for NO. You can take your time with each display, there is no timeout anymore. Feel free to ask questions now if you have them. Press a button to start the final block.';
PresentTextAndWait(ptb, btsi, txt);

end