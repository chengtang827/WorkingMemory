function [obj, varargout] = plot(obj,varargin)
%@dirfiles/plot Plot function for dirfiles object.
%   OBJ = plot(OBJ) creates a raster plot of the neuronal
%   response.

Args = struct('LabelsOff',0,'GroupPlots',1,'GroupPlotIndex',1,'Color','b', ...
		  'TrialLevel', 0, 'ReturnVars',{''}, 'ArgsOnly',0,'ReactionTime', 0,...
			'WindowSize',10,'EyetrialsObj',[]);
Args.flags = {'LabelsOff','ArgsOnly','TrialLevel','ReactionTime'};
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
    if ~Args.TrialLevel
        tidx = find(obj.data.setIndex == n);
    else
        tidx = n;
    end
else
	% plot all data
	n = 1;
    tidx = 1:size(obj.data.density,2);
end

if length(tidx) == 1
    plot(obj.data.xi, obj.data.density(:,tidx))
		hold on
		idx = logical(obj.data.counts(:,tidx));
		plot(obj.data.xi(idx),obj.data.density(idx,tidx),'.')
		hold off
else
	nd = nptdata(obj);
	celldir = nd.SessionDirs{n};
	cellname = getDataOrder('ShortName','DirString',celldir);
	if Args.ReactionTime
		q = get(obj, 'ReactionTimeDependence',struct('WindowSize',Args.WindowSize,...
																									'SetIndex',tidx,...
																									'EyetrialsObj', Args.EyetrialsObj));
		rtime = q.rtime;

		mm = median(rtime);
		scounts = q.scounts;
		regions = q.sig_window;

		upper_idx = find(rtime > mm);
		lower_idx = find(rtime < mm);
		binsize = mean(diff(obj.data.xi(n,:)));
		ml = mean(scounts(:,lower_idx),2)./binsize;
		mu = mean(scounts(:,upper_idx),2)./binsize;
		cla

		l1 = plot(obj.data.xi(n,1:end-1), mu);
		hold on
		l2 = plot(obj.data.xi(n,1:end-1), ml);

		mlp = nan(size(ml));
		mup = nan(size(mu));
		for j = 1:size(regions,1)
			idx = regions(j,1):regions(j,2);
			mlp(idx) = ml(idx);
			mup(idx) = mu(idx);
		end
		plot(obj.data.xi(n,1:end-1), mlp,'linewidth',2.0, 'color', l2.Color);
		plot(obj.data.xi(n,1:end-1), mup,'linewidth',2.0,'color',l1.Color);

		legend([l1,l2], {'Long reaction time','Short reaction time'});
		title(cellname);

	else
    %use only trials with non-zeros density
    zidx = find(max(obj.data.density(:,tidx))>0);
    mu = mean(obj.data.density(:,tidx(zidx)),2);
    sigma = std(obj.data.density(:,tidx(zidx))')';
    lower = mu - sigma;
    upper = mu + sigma;
    cla
    patch('XData',[obj.data.xi(n,:) obj.data.xi(n,end:-1:1)],'YData',[lower' upper(end:-1:1)'],...
             'FaceColor',[0.3, 0.1, 0.5]);
    hold on
    plot(obj.data.xi(n,:), mu)
    hold off
	end
end


% add code for plot options here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% @dirfiles/PLOT takes 'LabelsOff' as an example
if(~Args.LabelsOff)
	xlabel('Time [s]')
	ylabel('Firing rate [Hz]')
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

RR = eval('Args.ReturnVars');
RR1 = {};
for i=1:length(RR) RR1{i}=eval(RR{i}); end
varargout = getReturnVal(Args.ReturnVars, RR1);
