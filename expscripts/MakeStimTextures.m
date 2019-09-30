function tex = MakeStimTextures(ptb)

% we're making the textures using an all-white square and storing the shape
% in the alpha channel, which frees us from having to worry about
% background colour

target_img = zeros(128,128,2,'uint8');
target_img(:,:,1) = 255;
target_img(1:32,:,2) = 255;
target_img(:,48:79,2) = 255;
tex.target = Screen('MakeTexture', ptb.win, target_img);

distractor_img = zeros(128,128,2,'uint8');
distractor_img(:,:,1) = 255;
distractor_img(:,1:32,2) = 255;
distractor_img(96:128,:,2) = 255;
tex.distractor = Screen('MakeTexture', ptb.win, distractor_img);

end