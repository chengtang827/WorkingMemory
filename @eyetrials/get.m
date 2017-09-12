function [r,varargout] = get(obj,varargin)
%eyetrials/get Get function for eyetrials objects
%eyetrials/GET Returns object properties
%   VALUE = GET(OBJ,PROP_NAME) returns an object
%   property.
%   In eyetrials, PROP_NAME can be one of the following:
%      'ObjectLevel'
%	 'AnalysisLevel'
%
%   Dependencies:

Args = struct('ObjectLevel',0, 'AnalysisLevel',0, 'TrialLevel',0,...
 							'EventTiming','');
Args.flags ={'ObjectLevel','AnalysisLevel'};
Args = getOptArgs(varargin,Args);

% set variables to default
r = [];

if(Args.ObjectLevel)
	% specifies that the object should be created in the session directory
	r = 'session';
elseif(Args.AnalysisLevel)
	% specifies that the AnalysisLevel of the object is 'AllIntragroup'
	r = 'Single';
elseif(Args.TrialLevel)
	%total number of trials
	r = length(obj.data.setIndex);
elseif ~isempty(Args.EventTiming)
  ts = nan(length(obj.data.trials),1);
  if isfield(obj.data.trials(1),Args.EventTiming)
		if strcmpi(Args.EventTiming,'saccade')
			%find the saccade immediately preceeding either reward or failure
      for t = 1:length(obj.data.trials)
        if ~isempty(obj.data.trials(t).(Args.EventTiming))
					q = obj.data.trials(t).(Args.EventTiming);
					if ~isnan(obj.data.trials(t).failure)
						tf = obj.data.trials(t).failure;
					elseif ~isnan(obj.data.trials(t).reward)
						tf = obj.data.trials(t).reward;
          else
            tf = nan;
					end
					i = 1;
					while (i < length(q)) && (q(i).onset < tf)
						i = i + 1;
					end
					if i == 1
						ts(t) = nan;
					else
						i = i -1;
	          ts(t) = q(i).onset;
					end
        end
			end
    elseif isstruct(obj.data.trials(1).(Args.EventTiming))

        for t = 1:length(obj.data.trials)
          if ~isempty(obj.data.trials(t).(Args.EventTiming))
            ts(t) = obj.data.trials(t).(Args.EventTiming).onset;
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
