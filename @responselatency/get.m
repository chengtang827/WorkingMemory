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
							'ReactionTimeDependence',0,'glmfit',0);
Args.flags ={'ObjectLevel','AnalysisLevel','TrialLevel','ReactionTimeDependence',...
							'glmfit'};
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
elseif Args.ReactionTimeDependence
	nd = nptdata(obj);
	celldir = nd.SessionDirs{1};
	session_dir = getDataOrder('session','DirString',celldir);
	cwd = pwd;
	cd(session_dir)
	et = eyetrials('auto');
	cd(cwd)
	rtime = get(et, 'ReactionTime');
	gidx = intersect(find(~isnan(rtime)),obj.data.trialidx);
	qidx = find(ismember(obj.data.trialidx, gidx));
	scounts = zeros(size(obj.data.counts,1), length(gidx));
	rtime = rtime(gidx);
	w = 20;  % TODO: make this an argument
	for i = 1:length(gidx)
		scounts(:,i) = smooth(obj.data.counts(:,qidx(i)),w);
	end
	pvals = zeros(size(scounts,1),1);
	mm = median(rtime);
	upper_idx = find(rtime > mm);
	lower_idx = find(rtime < mm);
	for i = 1:length(pvals)
		pvals(i) = ranksum(scounts(i,lower_idx), scounts(i, upper_idx));
	end
	vidx = find(pvals < 0.05);
	%figure out the boundaries
	qidx = find(diff(vidx) > 1);
	%figure out where each region starts
	stidx = [1;(qidx+1)];
	%figure out where each region ends
	eidx = [qidx;length(vidx)];
	r = obj.data.xi([vidx(stidx) vidx(eidx)]);
elseif Args.glmfit
	window = [-0.15, 0.05];
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
	rtime = get(et, 'ReactionTime');
	X = [rtime(obj.data.trialidx,:) tlabel(obj.data.trialidx,:)];
	m = fitglm(X, y, 'interactions', 'CategoricalVars',[2],'Distribution','poisson');
	r = m;
else
	% if we don't recognize and of the options, pass the call to parent
	% in case it is to get number of events, which has to go all the way
	% nptdata/get
	r = get(obj.nptdata,varargin{:});
end
