% set this to 1 when doing actual experiment
IS_LIVE = 0;
EYELINK_LIVE = 0;

% clear screens and connect to projector if needed
if IS_LIVE
    commandwindow();
    sca();
    HideCursor();
end

% get subject ID from experimenter and make filename based on it
subj_id = input('Please enter a subject ID: ');
sess_id = input('Please enter a session ID: ');
nowtime = clock();
filename = sprintf('results/subj%02d_sess%02d_%04d-%02d-%02dT%02d-%02d-%02d.mat',...
    subj_id, sess_id, nowtime(1:5), round(nowtime(6)));

% setup psychtoolbox and get some parameters about the screen etc.,
% these are used by the presentation subroutines
ptb = InitPsychtoolbox(IS_LIVE);

% stimuli configuration
stim = InitStimParameters(ptb);

% make stimuli and load textures
stim = InitStimuli(ptb, stim);
tex = MakeStimTextures(ptb);

% initialize bitsibox (to send and receive triggers)
if IS_LIVE
    btsi = Bitsi('COM1'); % or whichever COM-port used by the PC
    % in behavioural cubicles (when using only left button box):
%     stim.RESP_RIGHT = 'e';
%     stim.RESP_LEFT = 'h';

    % in MEG lab for blue buttons on right/left response boxes:
    % or in behav cubicles when using both button boxes (recommended)
    stim.RESP_RIGHT = 'a';
    stim.RESP_LEFT = 'e';
else
    btsi = Bitsi('');
    stim.RESP_RIGHT = KbName('m');
    stim.RESP_LEFT = KbName('c');
end

btsi.validResponses = [stim.RESP_RIGHT, stim.RESP_LEFT];

% initialize the eye tracker
if IS_LIVE
    ptb.eye = EyelinkInitDefaults(ptb.win);
    EyelinkInit(~EYELINK_LIVE, 1);
    
    Eyelink('command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
    Eyelink('openfile', sprintf('essub%03d.edf', subj_id));
    EyelinkDoTrackerSetup(ptb.eye);
    
    WaitSecs(0.1);
    Eyelink('StartRecording');
    
end

btsi.ptb = ptb;

% use this stim structure for the instructions and practice round
stim_practice = InitStimParameters(ptb);
stim_practice = InitStimuli(ptb, stim_practice);
stim_practice.RESP_RIGHT = stim.RESP_RIGHT;
stim_practice.RESP_LEFT = stim.RESP_LEFT;

PresentInstructionsAndPractice(stim_practice, ptb, tex, btsi);

RunTrials(stim, ptb, tex, btsi, filename);

txt = 'Done! You''re awesome. Please contact the experimenter.';
PresentTextAndWait(ptb, btsi, txt);

Screen('CloseAll');

if IS_LIVE
    Eyelink('CloseFile');
    WaitSecs(0.5);
    Eyelink('ReceiveFile');
    Eyelink('ShutDown');
end

ShowCursor();
