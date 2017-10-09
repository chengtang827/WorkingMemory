function [obj, varargout] = pl2split(varargin)
%@pl2split Constructor function for pl2split class
%   OBJ = pl2split(varargin)
%
%   OBJ = pl2split('auto') attempts to create a pl2split object by ...
%
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   % Instructions on pl2split %
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%example [as, Args] = pl2split('save','redo')
%
%dependencies:

Args = struct('RedoLevels',0, 'SaveLevels',0, 'Auto',0, 'ArgsOnly',0,...
						 'ChannelsPerArray',32, 'Channel',1);
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
Args.classname = 'pl2split';
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
	dlist = nptDir;
	% get entries in directory
	dnum = size(dlist,1);
	pl2file = dir('*.pl2');
	array_index = floor(Args.Channel/Args.ChannelsPerArray)+1;
	channel_index = Args.Channel - (array_index-1)*Args.ChannelsPerArray;
	array_name = sprintf('array%02d', array_index);
	channel_name = sprintf('channel%03d', channel_index);
	cwd = pwd;
	if isempty(pl2file)
	  obj = createEmptyObject(Args);
	else
		% TODO: Make sure we adjust for the timestamps
		if exist('event_markers.txt','file')
			tt = readtable('event_markers.txt');
			markers = tt.markers;
			timestamps = tt.timestamps;
		else
			event_ts = [];
			event_id = [];
			for i = 1:8
				[n,ts,sv] = plx_event_ts(pl2file(1).name, sprintf('EVT%.2d', i));
				event_ts = [event_ts;ts];
				event_id = [event_id;repmat(i, length(ts),1)];
			end
			[strobes,timestamps] = createWords(event_id, event_ts);
			%convert to string
			markers = {};
			for i = 1:size(strobes,1)
				markers{i} = strrep(num2str(strobes(i,:)),' ','');
			end
			markers = markers';
			%create a table
			TT = table(markers,timestamps);
			writetable(TT, 'event_markers.txt');
		end
		%find sessions
		session_starts = [];
		for i = 1:size(markers,1)
			w = markers{i};
			if strcmp(w(1:3), '110')
				session_starts = [session_starts timestamps(i)];
			end
		end
		pl2_channel_name = sprintf('WB%03d', Args.Channel);
	  [adfreq, n, ts, fn, ad] = plx_ad_v(pl2file(1).name, pl2_channel_name);
		session_starts = [session_starts ts(end) + length(ad)/adfreq];
		for i =1:length(session_starts)-1
			idx1 = floor((session_starts(i) - ts(end))*adfreq);
			idx2 = floor((session_starts(i+1) - ts(end))*adfreq);
			y = ad(idx1:idx2);
			%check if session directory exists
			session_name = sprintf('session%02d',i);
			if ~exist(session_name,'dir')
				nptMkDir(session_name)
			end
			cd(session_name);
			if ~exist(array_name,'dir')
				nptMkDir(array_name);
			end
			cd(array_name);
			if ~exist(channel_name,'dir')
				nptMkDir(channel_name);
			end
			cd(channel_name);
			highpassdata('Data',y, 'sampling_rate',adfreq, 'channel',Args.Channel,'save');
			cd(cwd);
		end
		% create nptdata so we can inherit from it
		data.numSets = 1;
	  data.Args = Args;
		n = nptdata(data.numSets,0,pwd);
		d.data = data;
		obj = class(d,Args.classname,n);
		saveObject(obj,'ArgsC',Args);
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
