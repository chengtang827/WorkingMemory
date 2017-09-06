function [obj, varargout] = plot(obj,varargin)
%@eyetrials/plot Plot function for eyetrials object.
%   OBJ = plot(OBJ) creates a raster plot of the neuronal
%   response.

Args = struct('LabelsOff',0,'GroupPlots',1,'GroupPlotIndex',1,'Color','b', ...
		  'ReturnVars',{''}, 'ArgsOnly',0);
Args.flags = {'LabelsOff','ArgsOnly'};
[Args,varargin2] = getOptArgs(varargin,Args);

% if user select 'ArgsOnly', return only Args structure for an empty object
if Args.ArgsOnly
    Args = rmfield (Args, 'ArgsOnly');
    varargout{1} = {'Args',Args};
    return;
end

if(~isempty(Args.NumericArguments))
	% plot one data set at a time
	n = Args.NumericArguments{1};
	tidx = find(obj.data.setIndex == n);
else
	% plot all data
	tidx = 1:length(obj.data.trials);
end

% add code for plot options here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
trial_start_color = [0.203922, 0.541176, 0.741176];
trial_end_color = [0.737255, 0.827451, 0.0];
response_cue_color = [0.32549, 0.0, 0.0];
fixation_color = [0.0, 0.282353, 0.0];
marker_size = 10.0;
ntrials = length(tidx);
trial_start = nan(ntrials,1);
fixation_start = nan(ntrials, 1);
response_cue = nan(ntrials,1);
trial_end = nan(ntrials,1);

for t = 1:ntrials
	trial_start(t) =  double(obj.data.trials(tidx(t)).start)/1000.0;
	if ~isempty(obj.data.trials(tidx(t)).fixation_start)
		fixation_start(t) = double(obj.data.trials(tidx(t)).fixation_start)/1000.0;
	end
	if ~isempty(obj.data.trials(tidx(t)).response_cue)
		response_cue(t) = double(obj.data.trials(tidx(t)).response_cue)/1000.0;
	end
	if ~isempty(obj.data.trials(tidx(t)).end)
		trial_end(t) = double(obj.data.trials(tidx(t)).end)/1000.0;
	end
end
y = 1:ntrials;
l1 = plot(zeros(ntrials,1), y,'.','color',trial_start_color,...
				'markersize', marker_size);
hold on
l2 = plot(fixation_start - trial_start, y, '.', 'color', fixation_color,...
				'markersize', marker_size);
l3 = plot(response_cue - trial_start, y, '.', 'color', response_cue_color,...
				'markersize', marker_size);
l4 = plot(trial_end-trial_start, y, '.', 'color', trial_end_color,...
				'markersize', marker_size);
legend([l1,l2,l3,l4], 'Trial start', 'Fixation start', 'Response cue', 'Trial end');
hold off

% @eyetrials/PLOT takes 'LabelsOff' as an example
if(~Args.LabelsOff)
	xlabel('Time [s]')
	ylabel('Trial')
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

RR = eval('Args.ReturnVars');
RR1 = {};
for i=1:length(RR)
	RR1{i}=eval(RR{i});
end
varargout = getReturnVal(Args.ReturnVars, RR1);
