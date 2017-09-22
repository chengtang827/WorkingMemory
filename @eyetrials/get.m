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
 							'EventTiming','','Event','','OldGrid',0);
Args.flags ={'ObjectLevel','AnalysisLevel','OldGrid'};
Args = getOptArgs(varargin,Args);

% set variables to default
r = [];

if (Args.ObjectLevel)
	% specifies that the object should be created in the session directory
	r = 'session';
elseif (Args.AnalysisLevel)
	% specifies that the AnalysisLevel of the object is 'AllIntragroup'
	r = 'Single';
elseif (Args.TrialLevel)
	%total number of trials
	r = length(obj.data.setIndex);
elseif ~isempty(Args.Event)
  if strcmpi(Args.Event,'response_saccade')
    %response_saccade = struct;
    for t = 1:length(obj.data.trials)
      ff = fieldnames(obj.data.trials(1).saccade);
      if ~isempty(obj.data.trials(t).saccade)
        q = obj.data.trials(t).saccade;
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
          qq = struct;
          for fi = 1:length(ff)
            qq.(ff{fi}) = nan;
          end
          response_saccade(t) = qq;
        else
          i = i -1;
          ts(t) = q(i).onset;
          response_saccade(t) = q(i);
        end %if i
      end %if ~isempty
    end %for t
    r = response_saccade;
  end % if strcmpi(Args.Event)
elseif ~isempty(Args.EventTiming)
  ts = nan(length(obj.data.trials),1);
  if isfield(obj.data.trials(1),Args.EventTiming)
		if strcmpi(Args.EventTiming,'saccade')
			%find the saccade immediately preceeding either reward or failure
      response_saccade = get(obj,'Event','response_saccade');
      for t = 1:length(obj.data.trials)
        if ~isempty(response_saccade(t).onset)
          ts(t) = response_saccade(t).onset;
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
        end %for t
    end %if strcmpi(Args.EventTiming, 'saccade')
  end %if isfield(obj.data.trials(1),Args.EventTiming)
  r = ts;
elseif Args.OldGrid
  %get a 5 by 5 grid used by the old data
  rows = 5;
  cols = 5;
  screen_width = obj.data.screen_size(1);
  screen_height = obj.data.screen_size(2);
  squareArea = floor((screen_height-screen_height/10)/rows);
  xmargin = (screen_width - cols * squareArea) / 2;
  ymargin = (screen_height - rows * squareArea) / 2;
  xdiff = (screen_width-2*xmargin)/cols;
  ydiff = (screen_height-2*ymargin)/rows;
  center_x = repmat(xmargin + (0:(cols-1)).*xdiff + xdiff/2,rows,1);
  center_y = repmat((ymargin + (0:(rows-1)).*ydiff + ydiff/2)', 1, cols);
  r = struct('rows', rows, 'columns', cols, 'screen_width',screen_width,...
             'screen_height',screen_height,'xmargin', xmargin,...
             'ymargin', ymargin, 'xdiff', xdiff, 'ydiff', ydiff,...
             'center_x',center_x, 'center_y', center_y);
else
	% if we don't recognize and of the options, pass the call to parent
	% in case it is to get number of events, which has to go all the way
	% nptdata/get
	r = get(obj.nptdata,varargin{:});
end
