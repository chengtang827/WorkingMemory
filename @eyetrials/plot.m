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

ntrials = length(tidx);
ff = fieldnames(obj.data.trials);
%create perceptually distinguisable colors for plotting
plot_colors = distinguishable_colors(length(ff));
ydata = nan(ntrials,length(ff));

for t = 1:ntrials
	t0 = obj.data.trials(tidx(t)).start;
	ydata(t,1) = double(t0)/1000.0;
	for fi=1:length(ff)
		if ~isempty(obj.data.trials(tidx(t)).(ff{fi}))
			xx = obj.data.trials(tidx(t)).(ff{fi});
			if isstruct(xx)
				ydata(t,fi) = double(xx.timestamp-t0)/1000.0;
			else
				ydata(t,fi) = double(xx-t0)/1000.0;
			end
		end
	end
end
marker_size = 10.0;
y = 1:ntrials;
cla
hold on
for fi=1:length(ff)
	plot(ydata(:,fi), y, '.', 'color', plot_colors(fi,:),...
				'markersize', marker_size);
end
legend(ff)
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
