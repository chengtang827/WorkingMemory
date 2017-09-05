function [obj, varargout] = eyetrials(varargin)
%@eyetrials Constructor function for eyetrials class
%   OBJ = eyetrials(varargin)
%
%   OBJ = eyetrials('auto') attempts to create a eyetrials object by ...
%
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   % Instructions on eyetrials %
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%example [as, Args] = eyetrials('save','redo')
%
%dependencies:

Args = struct('RedoLevels',0, 'SaveLevels',0, 'Auto',0, 'ArgsOnly',0);
Args.flags = {'Auto','ArgsOnly'};
% The arguments which can be neglected during arguments checking
Args.UnimportantArgs = {'RedoLevels','SaveLevels'};

[Args,modvarargin] = getOptArgs(varargin,Args, ...
    'subtract',{'RedoLevels','SaveLevels'}, ...
    'shortcuts',{'redo',{'RedoLevels',1}; 'save',{'SaveLevels',1}}, ...
    'remove',{'Auto'});

% variable specific to this class. Store in Args so they can be easily
% passed to createObject and createEmptyObject
Args.classname = 'eyetrials';
Args.matname = [Args.classname '.mat'];
Args.matvarname = 'et';

% To decide the method to create or load the object
%what is the point of ArgC? To compare against saved argument
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
%dirlevels()
%check for existing mat file with parsed edfdata
dlist = nptDir('edfdata.mat');
%check for raw edf file
if isempty(dlist)
  dlist = nptDir('*.edf');
end

dnum = length(dlist);

% check if the right conditions were met to create object
if(dnum>0)
    % this is a valid object
    % these are fields that are useful for most objects
    data.Args = Args;
    data.numSets = 1;
    % these are object specific fields
    data.dlist = dlist;
    % set index to keep track of which data goes with which directory
    [pathstr,name,ext] = fileparts(dlist(1).name);
    if strcmp(ext,".mat")
      load(dlist(1).name);
    else
      edfdata = edfmex(dlist(1).name);
    end
    trialdata = parseEDFData(edfdata);
    data.trials = trialdata.trials;
    % create nptdata so we can inherit from it
    data.Args = Args;
    n = nptdata(data.numSets,0,pwd);
    d.data = data;
    obj = class(d,Args.classname,n);
    saveObject(obj,Args);
else
    % create empty object
    obj = createEmptyObject(Args);
end

function obj = createEmptyObject(Args)

% useful fields for most objects
data.numSets = 0;
data.setNames = '';

% these are object specific fields
data.trials = struct

% create nptdata so we can inherit from it
data.Args = Args;
n = nptdata(0,0);
d.data = data;
obj = class(d,Args.classname,n);
