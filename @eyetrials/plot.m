function [obj, varargout] = plot(obj,varargin)
%@eyetrials/plot Plot function for eyetrials object.
%   OBJ = plot(OBJ) creates a raster plot of the neuronal
%   response.

Args = struct('LabelsOff',0,'GroupPlots',1,'GroupPlotIndex',1,'Color','b', ...
		  'ReturnVars',{''}, 'ArgsOnly',0,'TrialLevel',0,'ReactionTime',0);
Args.flags = {'LabelsOff','ArgsOnly','TrialLevel','ReactionTime'};
[Args,varargin2] = getOptArgs(varargin,Args);

% if user select 'ArgsOnly', return only Args structure for an empty object
if Args.ArgsOnly
    Args = rmfield (Args, 'ArgsOnly');
    varargout{1} = {'Args',Args};
    return;
end

if ~isempty(Args.NumericArguments)
	% plot one data set at a time
	n = Args.NumericArguments{1};
	if ~Args.TrialLevel
		tidx = find(obj.data.setIndex == n);
	else
		tidx = n;
	end
else
	% plot all data
	tidx = 1:length(obj.data.trials);
end

% add code for plot options here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ntrials = length(tidx);
ff = fieldnames(obj.data.trials);
fidx = [];
%get rid of eye fields since we don't want to plot those here
for fi=1:length(ff)
	if strcmpi(ff{fi},'gazex') | strcmpi(ff{fi},'gazey') | strcmpi(ff{fi}, 'pupil')
		continue
	else
		fidx = [fidx fi];
	end
end
%get the session directory
nd = nptdata(obj);
session_idx = unique(obj.data.setIndex(tidx));
session_dir = nd.SessionDirs{session_idx};
session_name = getDataOrder('ShortName','DirString', session_dir);
%create perceptually distinguisable colors for plotting
plot_colors = distinguishable_colors(length(ff));
if Args.TrialLevel
	%plot a single trial
	ax1 = subplot(1, 1, 1);
	cla(ax1);
	hold(ax1, 'on')
	plot(ax1, obj.data.trials(tidx).gazex)
	plot(ax1, obj.data.trials(tidx).gazey)
	%plot triggers
	t0 = obj.data.trials(tidx).start;
	k = 3; %keep track of legends
	legends = {'gazex', 'gazey'};
	for fi=1:length(fidx)
		if strcmpi(ff{fidx(fi)},'saccade')
			continue %ksip saccade
		end
		if ~isempty(obj.data.trials(tidx).(ff{fidx(fi)}))
			xx = obj.data.trials(tidx).(ff{fidx(fi)});
			if isstruct(xx)
				t = double(xx.onset - t0);
			else
				t = double(xx-t0);
			end
			plot(ax1, [t t], ylim, 'color',plot_colors(fi,:),...
				   'linewidth', 2.0)
			legends{k} = strrep(ff{fidx(fi)}, '_','');
			k = k + 1;
		end
	end
	legend(ax1, legends)
	hold(ax1, 'off')
elseif Args.ReactionTime
	cwd = pwd;
	cd(session_dir);
	dlist = nptDir('*_results.txt');
	if length(dlist) >= 1
		dd = readtable(dlist(1).name);
		delta_t = dd.response_on - dd.target_on;
		%get only correct trials
		idx = find((dd.response_on > 0)&(dd.reward_on > 0));
		saccade_time = get(obj, 'EventTiming', 'saccade');
		target_time = get(obj, 'EventTiming', 'target');
		scatter(delta_t(idx), (saccade_time(idx) - target_time(idx))/1000);
		hold on
		mii = min(delta_t(idx));
		mx = max(delta_t(idx));
		plot([mii mx], [mii mx]);
		xlabel('Response cue time [s]')
		ylabel('Reaction time [s]')
		hold off
	end
	cd(cwd);
else
	ydata = nan(ntrials,length(fidx));
	for t = 1:ntrials
		t0 = obj.data.trials(tidx(t)).start;
		ydata(t,1) = double(t0)/1000.0;
		for fi=1:length(fidx)
			if strcmpi(ff{fidx(fi)},'saccade')
				continue %ksip saccade
			end
			if ~isempty(obj.data.trials(tidx(t)).(ff{fidx(fi)}))
				xx = obj.data.trials(tidx(t)).(ff{fidx(fi)});
				if isstruct(xx)
					ydata(t,fi) = double(xx.onset-t0)/1000.0;
				else
					ydata(t,fi) = double(xx-t0)/1000.0;
				end
			end
		end
	end
	marker_size = 10.0;
	ax1 = subplot(1,2,1);
	ax2 = subplot(1,2,2);
	y = 1:ntrials;
	cla(ax1)
	hold(ax1,'on')
	for fi=1:length(fidx)
		plot(ax1,ydata(:,fidx(fi)), y, '.', 'color', plot_colors(fi,:),...
					'markersize', marker_size);
	end
	%reformat legends
	legends = {};
	for fi=1:length(fidx)
		legends{fi} = strrep(ff{fidx(fi)},'_','');
	end
	legend(ax1, legends)
	hold(ax1, 'off')

	% @eyetrials/PLOT takes 'LabelsOff' as an example
	if(~Args.LabelsOff)
		xlabel(ax1, 'Time [s]')
		ylabel(ax1, 'Trial')
	end

	hold(ax2, 'on')
	for t=1:ntrials
		plot(ax2, obj.data.trials(tidx(t)).gazex, obj.data.trials(tidx(t)).gazey,...
				'color',[0.0,0.749,1.0]);
	end
	xlim(ax2, [0 obj.data.screen_size(1)]);
	ylim(ax2, [0 obj.data.screen_size(2)]);
	hold(ax2, 'off')
	%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

RR = eval('Args.ReturnVars');
RR1 = {};
for i=1:length(RR)
	RR1{i}=eval(RR{i});
end
varargout = getReturnVal(Args.ReturnVars, RR1);
