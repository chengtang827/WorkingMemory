function [obj, varargout] = trials(varargin)
%@trials Constructor function for trials class
%   Tr = trials(varargin)
%
%   trials() creates an empty object. To avoid that,
%
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   % Instructions on trials %
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This constructor functions returns an object with the following fields
%   Tr.start - timestamp when the trial started
%   Tr.fixation - timestamp when fixation started
%   Tr.target.onset - timestamp when the target came on
%   Tr.target.offset - timestamp when the target was removed
%   Tr.target.location - where the target was presented
%   Tr.distractor.onset - timestamp when the distractor came on
%   Tr.distractor.offset - timestamp when the distractor was removed
%   Tr.distractor.location - where the distractor was presented.
%   Tr.response - timestamp when the response cue was delivered to the
%   animal
%   Tr.reward.onset - timestamp when reward starts
%   Tr.reward.offset - timestamp when reward stops
%   Tr.failure - timestamp when failure strobe word was sent
%   Tr.saccade.onset = timestamp when the animal makes a saccade in the trial.
%   If this saccade was before the response cue - the trial was aborted.
%   Tr.saccade.where - where the saccade ended up.
%
%   all the timestamps are in ms and are relative to the trial start. If
%   the trial gets aborted midway, the field's epochs that did not happen
%   are replaced with an empty matrix.
%example [as, Args] = dirfiles('save','redo')
%
%dependencies: .edf for each session and event_markers.edf

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
Args.classname = 'trials';
Args.matname = [Args.classname '.mat'];
Args.matvarname = 'tr';

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
end

function obj = createObject(Args,varargin)

% example object
dlist = nptDir;
dnum = size(dlist,1);
% get entries in directory
if ~isempty(dlist)
    if exist('event_markers.mat')
        load('event_markers.mat');
        tr_start = strmatch('00000010',ev.textdata);
        data.numSets = length(tr_start);
            data.Args = Args;
        for i_start = 1:length(tr_start)
            % this is a valid object
            % these are fields that are useful for most objects
            
            if i_start~=length(tr_start)
                events = ev.textdata(tr_start(i_start):tr_start(i_start+1)-1);
                time = ev.data(tr_start(i_start):tr_start(i_start+1)-1);
            else
                events = ev.textdata(tr_start(i_start):end);
                time = ev.data(tr_start(i_start):end);
            end
            % these are object specific fields
            data.dlist = dlist;
            for i_events = 1:length(time)
                switch events{i_events}
                    case('00000010')
                        y(i_start).start = time(i_events);
                    case('00000001')
                        y(i_start).fixation = time(i_events) - y(i_start).start;
                    case('00100000')
                        y(i_start).end = time(i_events) - y(i_start).start;
                    case('00000111')
                        y(i_start).failure = time(i_events) - y(i_start).start;
                    case('00000110')
                        y(i_start).reward.onset = time(i_events) - y(i_start).start;
                    case('00000100')
                        y(i_start).reward.offset = time(i_events) - y(i_start).start;
                    case('00000101')
                        y(i_start).response = time(i_events) - y(i_start).start;
                    case('00000101')
                        y(i_start).saccade.onset = time(i_events) - y(i_start).start;
                end
                if strmatch('101',events(i_events))
                    y(i_start).target.onset = time(i_events) - y(i_start).start;
                elseif strmatch('100',events(i_events))
                    y(i_start).target.offset = time(i_events) - y(i_start).start;
                elseif strmatch('011',events(i_events))   
                    y(i_start).distractor.onset = time(i_events) - y(i_start).start;
                elseif strmatch('010',events(i_events))  
                    y(i_start).distractor.offset = time(i_events) - y(i_start).start;
                end
            end
        end
        % set index to keep track of which data goes with which directory
            data.setIndex = [0; dnum];
            
            % create nptdata so we can inherit from it
            
            data.Args = Args;
            n = nptdata(data.numSets,0,pwd);
            data.trials = y;
            d.data = data;
            obj = class(d,Args.classname,n);
            saveObject(obj,'ArgsC',Args);
    else
        cd ..
        if exist('event_markers.txt')
            A = importdata('event_markers.txt');
            A.textdata(1,:) = [];
            A.textdata(:,2) = [];
            sess_start = strmatch('110',A.textdata);
            for i_sess = 1:length(sess_start)
                if i_sess~=length(sess_start)
                    cd(sprintf('session%02d',i_sess))
                    ev.textdata = A.textdata(sess_start(i_sess):sess_start(i_sess+1)-1);
                    ev.data = A.data(sess_start(i_sess):sess_start(i_sess+1)-1);
                    save('event_markers.mat','ev');
                    cd ..
                else
                    cd(sprintf('session%2d',i_sess))
                    ev.textdata = A.textdata(sess_start(i_sess):end);
                    ev.data = A.data(sess_start(i_sess):end);
                    save('event_markers.mat','ev');
                    cd ..
                end
            end
        else
            obj = createEmptyObject(Args);
        end
    end
else
    % create empty object
    obj = createEmptyObject(Args);
end
end

function obj = createEmptyObject(Args)

% useful fields for most objects
data.numSets = 0;
data.setNames = '';

% these are object specific fields
data.start =[];
data.fixation =[];
data.target = [];
data.distractor = [];
data.response = [];
data.reward = [];
data.failure  = [];
data.saccade = [];

% create nptdata so we can inherit from it
data.Args = Args;
n = nptdata(0,0);
d.data = data;
obj = class(d,Args.classname,n);
end
