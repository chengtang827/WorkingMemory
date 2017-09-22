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

Args = struct('RedoLevels',0, 'SaveLevels',0, 'Auto',0, 'ArgsOnly',0,...
              'triggers', struct,'edfdata',[]);
Args.flags = {'Auto','ArgsOnly'};
% The arguments which can be neglected during arguments checking
Args.DataCheckArgs = {};

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
    if ~exist(dlist(1).name,'file')
      obj = createEmptyObject(Args);
    else
      % this is a valid object
      % these are fields that are useful for most objects
      data.Args = Args;
      data.numSets = 1;
      % these are object specific fields
      data.dlist = dlist;
      [pathstr,name,ext] = fileparts(dlist(1).name);
      if strcmp(ext,'.mat')
        load(dlist(1).name);
      else
        edfdata = edfmex(dlist(1).name);
        if Args.SaveLevels > 0
          save('edfdata.mat','edfdata', '-v7.3');
        end
      end
      if ~isempty(fieldnames(Args.triggers))
        triggers = Args.triggers;
      else
        triggers = struct('trial_start','00000010',...
                  'trial_end','00100000');
      end
      trialdata = parseEDFData(eyetrials, edfdata, triggers);
      if isfield(trialdata(1),'trials')
        %multiple sessions in one structure
        data.setIndex = [];
        data.trials = struct;
        data.numSets = length(trialdata);
        k = 1;
        for i = 1:length(trialdata) %iterate over sessions
          for j = 1:length(trialdata(i).trials)
            ff = fieldnames(trialdata(i).trials(j));
            if ~isempty(ff)
              for fi = 1:length(ff)
                data.trials(k).(ff{fi}) = trialdata(i).trials(j).(ff{fi});
              end
              data.setIndex(k) = i;
              k = k + 1;
            end
          end
        end
        ntrials = k;
      else
        data.trials = trialdata.trials;
        ntrials = length(data.trials);
        data.setIndex = ones(ntrials,1);
      end
      %get the screen size
      screen_size_str = split(edfdata.FEVENT(1).message);
      data.screen_size = [str2double(screen_size_str{end-1}) str2double(screen_size_str{end})];
      % create nptdata so we can inherit from it
      data.Args = Args;
      % set index to keep track of which data goes with which directory
      n = nptdata(data.numSets,0,pwd);
      d.data = data;
      obj = class(d,Args.classname,n);
      saveObject(obj,'ArgsC', Args);
    end
else
    % create empty object
    obj = createEmptyObject(Args);
end

function obj = createEmptyObject(Args)

% useful fields for most objects
data.numSets = 0;
data.setNames = '';

% these are object specific fields
data.trials = struct;

% create nptdata so we can inherit from it
data.Args = Args;
n = nptdata(0,0);
d.data = data;
obj = class(d,Args.classname,n);
