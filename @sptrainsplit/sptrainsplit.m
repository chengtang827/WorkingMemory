function [obj, varargout] = sptrainsplit(varargin)
%@sptrainsplit Constructor function for DIRFILES class
%   OBJ = sptrainsplit(varargin)
%
%   OBJ = sptrainsplit('auto') attempts to create a DIRFILES object by ...
%
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   % Instructions on sptrainsplit %
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%example [as, Args] = sptrainsplit('save','redo')
%
%dependencies:

Args = struct('RedoLevels',0, 'SaveLevels',0, 'Auto',0, 'ArgsOnly',0,...
             'SamplingRate', 30000,'ChannelConfig', [], 'ChannelsPerArray', 32);
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
Args.classname = 'sptrainsplit';
Args.matname = [Args.classname '.mat'];
Args.matvarname = 'df';

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
dlist = nptDir('spiketrains.mat');
% get entries in directory
dnum = size(dlist,1);

% check if the right conditions were met to create object
if(dnum>0)
	% this is a valid object
	% these are fields that are useful for most objects
	data.numSets = 1;
    data.Args = Args;
    
	% these are object specific fields
	data.dlist = dlist;
    sptrains = load('spiketrains.mat');
    cells = fieldnames(sptrains);
    if exist('channel_config.csv','file')
        tt = readtable('channel_config.csv');
        for jj = 1:length(tt.channels)
            ll = split(tt.channels{jj},'-');
            c0 = str2num(ll{1});
            c1 = str2num(ll{2});
            channel_config.(tt.area{jj}) = c0:c1;
        end
    end
    for ii = 1:length(cells)
       [tokens, matches] = regexp(cells{ii}, '([A-Za-z0-9]*)_g([0-9]*)c([0-9]*)', 'tokens','match');
       area = tokens{1}{1};
       channel = str2num(tokens{1}{2});
       cc = str2num(tokens{1}{3});
       cell_channel = channel_config.(area)(channel);
       array_index = floor((cell_channel-1)/Args.ChannelsPerArray)+1;
       array_name = sprintf('array%02d', array_index);
       channel_name = sprintf('channel%03d',channel);
       cell_name = sprintf('cell%02d', cc);
       if ~exist(array_name,'dir')
           mkdir(array_name)
       end
       cd(array_name);
       if ~exist(channel_name, 'dir')
           mkdir(channel_name);
       end
       cd(channel_name);
       if ~exist(cell_name,'dir')
           mkdir(cell_name)
       end
       cd(cell_name);
       unit = struct('timestamps', Args.SamplingRate*sptrains.(cells{ii}),...
                    'sampling_rate', Args.SamplingRate', 'waveform', zeros(60));
        if Args.SaveLevels > 0
            save('unit.mat', '-struct', 'unit');
        end
        cd('../../../')
    end

	% set index to keep track of which data goes with which directory
	data.setIndex = [0; dnum];

	% create nptdata so we can inherit from it

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
