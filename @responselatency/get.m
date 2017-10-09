function [r,varargout] = get(obj,varargin)
%dirfiles/get Get function for dirfiles objects
%dirfiles/GET Returns object properties
%   VALUE = GET(OBJ,PROP_NAME) returns an object
%   property.
%   In dirfiles, PROP_NAME can be one of the following:
%      'ObjectLevel'
%	 'AnalysisLevel'
%
%   Dependencies:

Args = struct('ObjectLevel',0, 'AnalysisLevel',0,'TrialLevel',0, 'Smoothed',0,...
							'ReactionTimeDependence',struct,'glmfit',struct);
Args.flags ={'ObjectLevel','AnalysisLevel','TrialLevel'};
Args = getOptArgs(varargin,Args);

% set variables to default
r = [];

if(Args.ObjectLevel)
	% specifies that the object should be created in the session directory
	r = 'cell';
elseif(Args.AnalysisLevel)
	% specifies that the AnalysisLevel of the object is 'AllIntragroup'
	r = 'Single';
elseif Args.TrialLevel
    r = length(obj.data.setIndex);
elseif Args.Smoothed > 0
	scounts = zeros(size(obj.data.counts));
	for i = 1:size(scounts,2)
		scounts(:,i) = smooth(obj.data.counts(:,i),Args.Smoothed);
	end
	r = scounts;
elseif ~isempty(fieldnames(Args.ReactionTimeDependence))
	et = [];
	if isfield(Args.ReactionTimeDependence,'EyetrialsObj')
		if ~isempty(Args.ReactionTimeDependence.EyetrialsObj)
			et = Args.ReactionTimeDependence.EyetrialsObj;
		end
	end
	if isempty(et)
		nd = nptdata(obj);
		celldir = nd.SessionDirs{1};
		session_dir = getDataOrder('session','DirString',celldir);
		cwd = pwd;
		cd(session_dir)
		et = eyetrials('auto');
		cd(cwd)
	end
	rtime = get(et, 'ReactionTime');
	tidx = 1:length(obj.data.trialidx);
	if isfield(Args.ReactionTimeDependence, 'SetIndex')
		if ~isempty(Args.ReactionTimeDependence.SetIndex)
			tidx = Args.ReactionTimeDependence.SetIndex;
		end
	end
	gidx = intersect(find(~isnan(rtime)),obj.data.trialidx(tidx));
	qidx = find(ismember(obj.data.trialidx(tidx), gidx));
	scounts = zeros(size(obj.data.counts,1), length(gidx));
	rtime = rtime(gidx);
	w = 20;
	if isfield(Args.ReactionTimeDependence,'WindowSize')
		if ~isempty(Args.ReactionTimeDependence.WindowSize)
			w = Args.ReactionTimeDependence.WindowSize;
		end
	end
	for i = 1:length(gidx)
		scounts(:,i) = smooth(obj.data.counts(:,tidx(qidx(i))),w);
	end
	pvals = zeros(size(scounts,1),1);
	mm = median(rtime);
	upper_idx = find(rtime > mm);
	lower_idx = find(rtime < mm);
	for i = 1:length(pvals)
		pvals(i) = ranksum(scounts(i,lower_idx), scounts(i, upper_idx));
	end
	vidx = find(pvals < 0.05);
	if isempty(vidx)
		r = struct('sig_window',[],...
							 'rtime', rtime, 'scounts',scounts);
	else
		%figure out the boundaries
		qidx = find(diff(vidx) > 1);
		%figure out where each region starts
		stidx = [1;(qidx+1)];
		%figure out where each region ends
		eidx = [qidx;length(vidx)];
		r = struct('sig_window',[vidx(stidx) vidx(eidx)],...
							 'rtime', rtime, 'scounts',scounts);
	end
elseif ~isempty(fieldnames(Args.glmfit))
	if isfield(Args.glmfit, 'window')
		window = Args.glmfit.window;
	else
		window = [-0.15, -0.05];
	end
	widx = find((obj.data.xi < window(2))&(obj.data.xi > window(1)));
	y = sum(obj.data.counts(widx, :),1)';
	nd = nptdata(obj);
	session_dir = getDataOrder('session', 'DirString', nd.SessionDirs{1});
	cwd = pwd;
	cd(session_dir);
	tr = trialsOld('auto');
	et = eyetrials('auto');
	cd(cwd);
	tlabel = get(tr, 'TargetLabel');
	%hack
	%
	rtime = get(et, 'ReactionTime');
	X = [rtime(obj.data.trialidx,:) tlabel(obj.data.trialidx,:)];
	xidx = (X(:,2) == 19)|(X(:,2) == 25);
	m = fitglm(X, y, 'interactions', 'CategoricalVars',[2],'Distribution','poisson',...
						 'Varnames',{'Reaction_time', 'Target_label','spike_count'},...
						 'Exclude',xidx);
	r = m;
else
	% if we don't recognize and of the options, pass the call to parent
	% in case it is to get number of events, which has to go all the way
	% nptdata/get
	r = get(obj.nptdata,varargin{:});
end
