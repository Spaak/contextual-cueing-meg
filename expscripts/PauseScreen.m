function PauseScreen(ptb)

while true
    [keydown, ~, keycode] = KbCheck();
    if keydown && keycode(82) % button r - resume
        return;
    elseif keydown && keycode(27) % button ESC - escape, quit experiment
        Screen('CloseAll');
        error('experiment aborted by pressing ESC key');
    elseif keydown && keycode(69) % button e - eyelink
        EyelinkDoTrackerSetup(ptb.eye);
    
        WaitSecs(0.1);
        Eyelink('StartRecording');
    end
    DrawFormattedText(ptb.win, 'One moment please...', ptb.win_w/2-250,...
        ptb.win_h/2-250, 255);
    DrawFixationDot(ptb, 1);
    WaitSecs(0.01);
end

end