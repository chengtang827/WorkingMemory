function [obj, varargout] = raster(varargin)
%@raster Constructor function for raster class
%   OBJ = raster(varargin)
%
%   OBJ = raster('auto') attempts to create a raster object by ...
%
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   % Instructions on raster %
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%example [as, Args] = raster('save','redo')
%
%dependencies:

Args = struct('RedoLevels',0, 'SaveLevels',0, 'Auto',0, 'ArgsOnly',0);
Args.flags = {'Auto','ArgsOnly'};
% The arguments which can be neglected during arguments checking
Args.DataCheckArgs = {};

[Args,modvarargin] = getOptArgs(varargin,Args, ...
    'subtract',{'RedoLevels','SaveLevels'}, ...
    'shortcuts',{'redo',{'RedoLevels',1}; 'save',{'SaveLevels',1}}, ...
    'remove',{'Auto'});

% variable specific to this class. Store in Args so they can be easily
% passed to createObject and createEmptyObject
Args.classname = 'raster';
Args.matname = [Args.classname '.mat'];
Args.matvarname = 'rr';

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
    obj = createObject(Args,modvarargin{:});
end

function obj = createObject(Args,varargin)

% example object
dlist = nptDir;
% get entries in directory
dnum = size(dlist,1);
session_dir = getDataDirNew('session');
cwd = pwd;
cd(session_dir);
if ~isempty(strmatch('Pancake',strsplit(cwd,'/'))) || ~isempty(strmatch('James',strsplit(cwd,'/')))
    tr = trialsOld('auto',varargin{:},'redo');
else
    tr = trials('auto',varargin{:},'redo');
end
cd(cwd);



% check if the right conditions were met to create object
if ~isempty(tr) && exist('unit.mat')
    % this is a valid object
    % these are fields that are useful for most objects
    data.numSets = 1;
    data.Args = Args;
    
    % these are object specific fields
    data.dlist = dlist;
    % set index to keep track of which data goes with which directory
    
    % create nptdata so we can inherit from it
    trialidx = [];
    spiketimes = [];
    load unit.mat
    sampling_rate = 1000;
    timestamps = timestamps./sampling_rate; %convert to seconds
    for t=1:length(tr.data.trials)
        t0 = tr.data.trials(t).start;
        if isempty(t0)
            continue %invalid trials
        end
        if ~isempty(strmatch('Pancake',strsplit(cwd,'/'))) || ~isempty(strmatch('James',strsplit(cwd,'/')))
            t1 = tr.data.trials(t).end;
        else
            t1 = t0 + tr.data.trials(t).end;
        end
        if isempty(t1)
            continue %invalid trials
        end
        tidx = find((timestamps > t0)&(timestamps < t1));
        spiketimes = [spiketimes;timestamps(tidx)-t0];
        trialidx = [trialidx;repmat(t, length(tidx),1)];
    end
    data.trialidx = trialidx;
    data.spiketimes = spiketimes;
    data.setIndex = ones(length(trialidx),1);
    data.trialobj = tr.data.trials;
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
