function [resp, rt] = PresentTextAndWait(ptb, btsi, txt)

DrawFormattedText(ptb.win, WrapString(txt, 50), ptb.win_w/2-250, 'center',...
    255, [], [], [], 1.5);
Screen('Flip', ptb.win);
WaitSecs(0.5);
[resp, rt] = btsi.getResponse(inf, true);

end