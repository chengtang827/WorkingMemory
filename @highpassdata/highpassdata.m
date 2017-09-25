function [obj, varargout] = highpassdata(varargin)
%@highpassdata Constructor function for highpassdata class
%   OBJ = highpassdata(varargin)
%
%   OBJ = highpassdata('auto') attempts to create a highpassdata object by ...
%
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   % Instructions on highpassdata %
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%example [as, Args] = highpassdata('save','redo')
%
%dependencies: plx_ad_v

Args = struct('RedoLevels',0, 'SaveLevels',0, 'Auto',0, 'ArgsOnly',0,...
							'Channel',1, 'low', 300, 'high', 10000, 'Data',[],...
							'sampling_rate',0.0);
Args.flags = {'Auto','ArgsOnly'};
% The arguments which can be neglected during arguments checking
Args.DataCheckArgs = {};


[Args,modvarargin] = getOptArgs(varargin,Args, ...
	'subtract',{'RedoLevels','SaveLevels'}, ...
	'shortcuts',{'redo',{'RedoLevels',1}; 'save',{'SaveLevels',1}}, ...
	'remove',{'Auto'});

% variable specific to this class. Store in Args so they can be easily
% passed to createObject and createEmptyObject
Args.classname = 'highpassdata';
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

% check if the right conditions were met to create object
pl2file = dir('*.pl2');
if isempty(pl2file) && isempty(Args.Data)
  obj = createEmptyObject(Args);
else
	if isempty(Args.Data)
		%TODO: Make sure we adjust for the timestamps
	  [adfreq, n, ts, fn, ad] = plx_ad_v(pl2file.fname, Args.channel);
		event_ts = [];
		event_id = [];
		for i = 1:8
			[n,ts,sv] = plx_event_ts(fname, sprintf('EVT%.2d', i))
			event_ts = [event_ts ts];
			event_id = [event_id repmat(i, length(ts),1)];
		end
		%find sessions
		session_starts = [];
		for i = 1:length(event_ts)
			if event_id(i,1:3) == [1 1 0]
				session_starts = [session_starts event_ts(i)];
			end
		end
	else
		ad = Args.Data;
		adfreq = Args.sampling_rate;
	end
  [b,a] = butter(4,[Args.low/Args.sampling_rate Args.high/Args.sampling_rate]);
	data.data = filtfilt(b,a,ad);
	%break up the signal into sessions. A session is defined as a block
	%of data starting with a 110000XX marker and continues either until the
	%next such marker, or until the end of the file

	data.channel = Args.Channel;
	data.sampling_rate = adfreq;
	data.freq_low = Args.low;
	data.freq_high = Args.high;
	data.filter = 'butterworth';
	data.order = 4;
	% these are fields that are useful for most objects
	data.numSets = 1;
	data.Args = Args;
	n = nptdata(data.numSets,0,pwd);
	d.data = data;
	obj = class(d,Args.classname,n);
end
saveObject(obj,'ArgsC',Args);

function obj = createEmptyObject(Args)

% useful fields for most objects
data.numSets = 0;
data.setNames = '';

% these are object specific fields
data.data = [];
data.channel = 1;
data.sampling_rate = 0;
data.freq_low = 0.0;
data.freq_high = 1.0;
data.filter = '';
data.order = 4;

% create nptdata so we can inherit from it
data.Args = Args;
n = nptdata(0,0);
d.data = data;
obj = class(d,Args.classname,n);
