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

Args = struct('ObjectLevel',0, 'AnalysisLevel',0,'EventTiming','');
Args.flags ={'ObjectLevel','AnalysisLevel'};
Args = getOptArgs(varargin,Args);

% set variables to default
r = [];

if(Args.ObjectLevel)
	% specifies that the object should be created in the session directory
% 	r = levelConvert('levelName','session');
    r = 'session';
elseif(Args.AnalysisLevel)
	% specifies that the AnalysisLevel of the object is 'AllIntragroup'
	r = 'Single';
elseif ~isempty(Args.EventTiming)
  ts = zeros(length(obj.data.trials),1);
  if isfield(obj.data.trials(1),Args.EventTiming)
    if isstruct(obj.data.trials(1).(Args.EventTiming))
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
