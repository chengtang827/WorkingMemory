function [obj, varargout] = responselatency(varargin)
%@responselatency Constructor function for DIRFILES class
%   OBJ = responselatency(varargin)
%
%   OBJ = responselatency('auto') attempts to create a DIRFILES object by ...
%
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   % Instructions on responselatency %
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%example [as, Args] = responselatency('save','redo')
%
%dependencies:

Args = struct('RedoLevels',0, 'SaveLevels',0, 'Auto',0, 'ArgsOnly',0,...
             'Reference','PreSaccade', 'AnalysisWindow', [-0.2 0.1],...
             'BaselineWindow',[-0.3, -0.2], 'Bandwidth',0.0);
Args.flags = {'Auto','ArgsOnly'};
% Specify which arguments should be checked when comparing saved objects
% to objects that are being asked for. Only arguments that affect the data
% saved in objects should be listed here.
Args.DataCheckArgs = {};

[Args,modvarargin] = getOptArgs(varargin,Args, ...
	'subtract',{'RedoLevels','SaveLevels'}, ...
	'shortcuts',{'redo',{'RedoLevels',1}; 'save',{'SaveLevels',1}}, ...
	'remove',{'Auto'});

% variable specific to this class. Store in Args so they can be easily
% passed to createObject and createEmptyObject
Args.classname = 'responselatency';
Args.matname = [Args.classname '.mat'];
Args.matvarname = 'rl';

% To decide the method to create or load the object
command = checkObjCreate('ArgsC',Args,'narginC',nargin,'firstVarargin',varargin);

if(strcmp(command,'createEmptyObjArgs'))
    varargout{1} = {'Args',Args};
    obj = createEmptyObject(Args);
elseif(strcmp(command,'createEmptyObj'))
    obj = createEmptyObject(Args);
elseif(strcmp(command,'passedObj'))
    obj = varargin{1};
elseif(strcmp(command,'loadObj'))
    l = load(Args.matname);
    obj = eval(['l.' Args.matvarname]);
elseif(strcmp(command,'createObj'))
    % IMPORTANT NOTICE!!!
    % If there is additional requirements for creating the object, add
    % whatever needed here
    obj = createObject(Args,varargin{:});
end

function obj = createObject(Args,varargin)

% example object
dlist = nptDir;
% get entries in directory
dnum = size(dlist,1);
rr = raster('auto');

% check if the right conditions were met to create object
if ~isempty(rr)
	% this is a valid object
	% these are fields that are useful for most objects
    data.Args = Args;

	% these are object specific fields
    window = [Args.BaselineWindow(1) Args.AnalysisWindow(2)];
    saccade_raster = get(rr, 'AlignmentEvent', 'saccade', 'TimeInterval', window,...
                         'TrialType','correct');
    trialidx = unique(saccade_raster.data.trialidx);
    ntrials = length(trialidx);
    data.numSets = 1;
    bw = zeros(ntrials,1);
    bins = window(1):0.001:window(2);
    ff = zeros(length(bins),ntrials);
    counts = zeros(length(bins)-1,ntrials);
    for t = 1:ntrials
        tidx = find(saccade_raster.data.trialidx==t);
        if ~isempty(tidx)
            timestamps = saccade_raster.data.spiketimes(tidx);
            %find latency by computing spike density
            if Args.Bandwidth == 0
              [ff(:,t),xi, bw(t)] = ksdensity(timestamps,bins);
            else
              [ff(:,t),xi] = ksdensity(timestamps,bins,'Bandwidth',Args.Bandwidth);
              bw(t) = Args.Bandwidth;
            end
            counts(:,t) = histcounts(timestamps, bins);
        end
    end

	data.dlist = dlist;
	% set index to keep track of which data goes with which directory
	data.setIndex = ones(1, ntrials);

	% create nptdata so we can inherit from it
    data.density = ff;
    data.counts = counts;
    data.bins = bins;
    data.bandwidth = bw;
    data.xi = xi;
    data.Args = Args;
    data.trialidx = trialidx;
	n = nptdata(data.numSets,0,pwd);
	d.data = data;
	obj = class(d,Args.classname,n);
	saveObject(obj,'ArgsC',Args);
else
	% create empty object
	obj = createEmptyObject(Args);
end

function obj = createEmptyObject(Args)

% useful fields for most objects
data.numSets = 0;
data.setNames = '';

% these are object specific fields
data.dlist = [];
data.setIndex = [];

% create nptdata so we can inherit from it
data.Args = Args;
n = nptdata(0,0);
d.data = data;
obj = class(d,Args.classname,n);
