function DrawFeedback(stim, ptb, tex, trial_id, resp)

if resp == stim.RESP_RIGHT
    if stim.rotation(trial_id,1) == 90
        % right button, correct response
        color_center = [0 255 0];
    else
        % right button, incorrect response (so left was correct)
        color_center = [255 0 0];
    end
elseif resp == stim.RESP_LEFT
    if stim.rotation(trial_id,1) == -90
        % left button, correct response
        color_center = [0 255 0];
    else
        % left button, incorrect response (so right was correct)
        color_center = [255 0 0];
    end
elseif resp == 0
    % timeout
    color_center = [255 0 0];
end

DrawFixationDot(ptb, 0, color_center);

end