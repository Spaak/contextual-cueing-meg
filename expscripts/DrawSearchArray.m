function DrawSearchArray(stim, ptb, tex, trial_id)

centerx = stim.pix2deg(ptb.win_w/2);
centery = stim.pix2deg(ptb.win_h/2);

for k = 1:stim.num_stimuli
    if k == 1
        drawtex = tex.target;
    else
        drawtex = tex.distractor;
    end
    
    dest_rect = stim.deg2pix([
            centerx + stim.coords(trial_id,k,1) - stim.stim_w/2;
            centery + stim.coords(trial_id,k,2) - stim.stim_h/2;
            centerx + stim.coords(trial_id,k,1) + stim.stim_w/2;
            centery + stim.coords(trial_id,k,2) + stim.stim_h/2]);
    
    Screen('DrawTexture', ptb.win, drawtex, [], dest_rect,...
        stim.rotation(trial_id, k));

end

end