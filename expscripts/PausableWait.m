function PausableWait(ptb, secs)

untiltime = GetSecs() + secs;

while GetSecs() < untiltime
    [keydown, ~, keycode] = KbCheck();
    if keydown && keycode(80) % button p - pause
        PauseScreen(ptb);
        
        % re-start the waiting time if we've paused
        untiltime = GetSecs() + secs;
        Screen('Flip', ptb.win); % one blank frame to prompt the subject
        DrawFixationDot(ptb, 1);
    end
    WaitSecs(0.01);
end
    
end