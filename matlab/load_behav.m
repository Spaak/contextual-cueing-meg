function [stim,rts,responses,start_times] = load_behav(id)

subjects = datainfo();
warning('off', 'MATLAB:dispatcher:UnresolvedFunctionHandle');
load(subjects(id).behav, 'stim', 'rts', 'responses', 'start_times');
warning('on', 'MATLAB:dispatcher:UnresolvedFunctionHandle');

end