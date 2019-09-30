function DrawFixationDot(ptb, doflip, color)

if nargin < 3
    color = 255;
end

Screen('FillOval', ptb.win, color,...
    [ptb.win_w/2-4, ptb.win_h/2-4, ptb.win_w/2+4, ptb.win_h/2+4]);
Screen('FillOval', ptb.win, 0,...
    [ptb.win_w/2-2, ptb.win_h/2-2, ptb.win_w/2+2, ptb.win_h/2+2]);

if doflip
    Screen('Flip', ptb.win);
end

end