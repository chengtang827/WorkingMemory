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

Args = struct('ObjectLevel',0, 'AnalysisLevel',0, 'TargetOnset',0,'EventTiming','');
Args.flags ={'ObjectLevel','AnalysisLevel','TargetOnset'};
Args = getOptArgs(varargin,Args);

% set variables to default
r = [];

if(Args.ObjectLevel)
	% specifies that the object should be created in the session directory
	r = 'Session';
elseif(Args.AnalysisLevel)
	% specifies that the AnalysisLevel of the object is 'AllIntragroup'
	r = 'Single';
elseif Args.TargetOnset
    target_onset = nan(length(obj.data.trials),1);
    for i = 1:length(target_onset)
        if ~isempty(obj.data.trials(i).target)
            target_onset(i) = obj.data.trials(i).target.timestamp;
        end
    end
    r = target_onset;
elseif ~isempty(Args.EventTiming)
  ts = nan(length(obj.data.trials),1);
  if strcmpi(Args.EventTiming,'distractor')
    for t = 1:length(obj.data.trials)
      if ~isempty(obj.data.trials(t).distractors)
          ts(t) = obj.data.trials(t).distractors(1);
      end
  end
  elseif isfield(obj.data.trials(1),Args.EventTiming)
    if isstruct(obj.data.trials(1).(Args.EventTiming))
        for t = 1:length(obj.data.trials)
          if ~isempty(obj.data.trials(t).(Args.EventTiming))
            ts(t) = obj.data.trials(t).(Args.EventTiming).timestamp;
          end
        end
    else
        for t = 1:length(obj.data.trials)
          if ~isempty(obj.data.trials(t).(Args.EventTiming))
            ts(t) = obj.data.trials(t).(Args.EventTiming);
          end
        end
    end
  end
  r = ts;
else
	% if we don't recognize and of the options, pass the call to parent
	% in case it is to get number of events, which has to go all the way
	% nptdata/get
	r = get(obj.nptdata,varargin{:});
end
