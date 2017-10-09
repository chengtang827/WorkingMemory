function [obj, varargout] = spikecount(varargin)
%@dirfiles Constructor function for DIRFILES class
%   OBJ = dirfiles(varargin)
%
%   OBJ = dirfiles('auto') attempts to create a DIRFILES object by ...
%   
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   % Instructions on dirfiles %
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%example [as, Args] = dirfiles('save','redo')
%
%dependencies: 

Args = struct('RedoLevels',0, 'SaveLevels',0, 'Auto',0, 'ArgsOnly',0,'Bins',[],'Trial','','AlignmentEvent','');
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
Args.classname = 'spikecount';
Args.matname = [Args.classname '.mat'];
Args.matvarname = 'sp';

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

% check if the right conditions were met to create object
if exist('unit.mat')
	% this is a valid object
	% these are fields that are useful for most objects
	data.numSets = 1;
    data.Args = Args;
	if exist('raster.mat')
        r = raster('auto','save','redo');
        rr = get(r,'TrialType',Args.Trial,'AlignmentEvent',Args.AlignmentEvent,'TimeInterval',[abs(Args.Bins(1)) abs(Args.Bins(end))]);
    else
        r = raster('auto','save','redo');
        rr = get(r,'TrialType',Args.Trial,'AlignmentEvent',Args.AlignmentEvent,'TimeInterval',[abs(Args.Bins(1)) abs(Args.Bins(end))]);
    end
    n_trials = unique(rr.data.trialidx);
    for i = 1:length(n_trials)
        tmp_spikes = rr.data.spiketimes(find(rr.data.trialidx==n_trials(i)));
        [spcount(i,:),edges] = histcounts(tmp_spikes,Args.Bins);
    end
	% these are object specific fields
	data.dlist = dlist;
	% set index to keep track of which data goes with which directory
	data.setIndex = rr.data.setIndex;
	data.spcount = spcount;
    data.edges = edges;
	% create nptdata so we can inherit from it
    data.trialobj = rr.data.trialobj;
    data.trialsessidx = ones(length(data.trialobj),1);
    data.Args = Args;
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
