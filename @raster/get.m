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


Args = struct('ObjectLevel',0, 'AnalysisLevel',0,'TrialType','','AlignmentEvent','',...
    'SortingEvent', '', 'TimeInterval',[],'TrialObj',[], 'EyeTrialObj', [],'EventTiming','');

Args.flags ={'ObjectLevel','AnalysisLevel'};
Args = getOptArgs(varargin,Args);

% set variables to default
r = [];
cwd = pwd;
if (Args.ObjectLevel)
    % specifies that the object should be created in the session directory
    r = 'cell';
elseif (Args.AnalysisLevel)
    % specifies that the AnalysisLevel of the object is 'AllIntragroup'
    r = 'Single';
elseif(~isempty(Args.TrialType) && isempty(Args.AlignmentEvent) && isempty(Args.TimeInterval))
    if strcmpi(Args.TrialType,'Correct')
        
        ind = zeros(length(tr.data.trials),1);
        tr = obj.data.trialobj;
        for i = 1:length(tr)
            if tr(i).reward
                ind(i) = 1;
                
            end
        end
        ind = find(ind);
        tr_ind = ismember(obj.data.trialidx,ind);
        %for j = 1:length(tr_ind)
        %    tr_ind = [tr_ind; find(obj.data.trialidx==ind(j))];
        %    if obj.data.trialidx(i)
        %end
        df = obj;
        df.data.trialidx = obj.data.trialidx(tr_ind);
        df.data.spiketimes = obj.data.spiketimes(tr_ind);
        df.data.setIndex = obj.data.setIndex(tr_ind);
        df.data.trialobj = obj.data.trialobj(ind);
        r = df;
        
    elseif strcmpi(Args.TrialType,'error')
        ind = zeros(length(obj.data.trialobj),1);
        tr = obj.data.trialobj;
        for i = 1:length(tr)
            if tr.(i).failure && tr(i).response
                ind(i) = 1;
                
            end
        end
        ind = find(ind);
        tr_ind = ismember(obj.data.trialidx,ind);
        df = obj;
        df.data.trialidx = obj.data.trialidx(tr_ind);
        df.data.spiketimes = obj.data.spiketimes(tr_ind);
        df.data.setIndex = obj.data.setIndex(tr_ind);
        df.data.trialobj = df.data.trialobj(ind);
        r = df;
    elseif strcmpi(Args.TrialType,'Aborted') || strcmpi(Args.TrialType,'aborted')
        ind = [];
        tr = obj.data.trialobj;
        for i = 1:length(tr)
            if tr(i).failure && ~tr(i).response
                ind = [ind i];
            end
        end
        tr_ind=[];
        for j = 1:length(ind)
            tr_ind = [tr_ind; find(obj.data.trialidx==ind(j))];
        end
        df = obj;
        df.data.trialidx = obj.data.trialidx(tr_ind);
        df.data.spiketimes = obj.data.spiketimes(tr_ind);
        df.data.setIndex = obj.data.setIndex(tr_ind);
        df.data.trialobj = obj.data.trialobj(ind);
        r = df;
    end
elseif(~isempty(Args.AlignmentEvent) && ~isempty(Args.TimeInterval) && ~isempty(Args.TrialType))
    
    ind = [];
    tr = obj.data.trialobj;
    
    ind = zeros(length(tr),1);

    for i = 1:length(tr)
        if strcmpi(Args.TrialType,'correct')
            if tr(i).reward
                ind(i) = 1;
            end
        elseif strcmpi(Args.TrialType,'error')
            if tr(i).failure && tr(i).response
                ind(i) = 1 ;
            end
        elseif strcmpi(Args.TrialType,'aborted')
            if tr(i).failure && ~tr(i).response
                ind(i) =1;
            end
        end
    end
    ind = find(ind);
    bins = Args.TimeInterval;sptimes=[];tIdx=[];setIdx=[];
    df = obj;
    df.data.trialobj = obj.data.trialobj(ind);
    if strcmpi(Args.AlignmentEvent,'saccade') || strcmpi(Args.SortingEvent,'saccade')
        session_dir = getDataOrder('session');
        cwd = pwd;
        cd(session_dir)
        if ~isempty(strfind(session_dir,'Pancake')) || ~isempty(strfind(session_dir,'James'))
            et = eyetrials('auto','triggers',struct('trial_start','00000000','target_prefix', '010', 'distractor_prefix','100'));
        else
            et = eyetrials('auto');
        end
        cd(cwd);
        saccade_time = get(et, 'EventTiming', 'saccade');
        start_time = get(et, 'EventTiming', 'start');
        tt = (saccade_time -  start_time)/1000; % convert to seconds
    end
    if ~isempty(Args.SortingEvent)
        if strcmpi(Args.SortingEvent,'saccade')
            sortby = tt;
        else
            sortby = get(df, 'EventTiming', Args.AlignmentEvent);
        end
    end
    if ~isempty(Args.AlignmentEvent)
        if strcmpi(Args.AlignmentEvent, 'saccade')
            event_onset = tt;
        else
            event_onset = get(df, 'EventTiming', Args.AlignmentEvent);
        end
    end
    time_onset = event_onset + bins(1);
    time_offset = event_onset + bins(2);
    tr_idx = find(ismember(obj.data.trialidx, ind));
    [~,~,i_tr_idx] = unique(obj.data.trialidx(tr_idx));
    t0 = time_onset(i_tr_idx);
    t1 = time_offset(i_tr_idx);
    spidx = (obj.data.spiketimes(tr_idx) >= t0)&(obj.data.spiketimes(tr_idx) < t1);
    sptimes = obj.data.spiketimes(tr_idx(spidx)) - event_onset(i_tr_idx(spidx));
    tIdx = obj.data.trialidx(tr_idx(spidx));
    setIdx = obj.data.setIndex(tr_idx(spidx));
    df2 = obj;
    %sorting
    if ~isempty(Args.SortingEvent)
        [ss,qidx] = sort(sortby);
        trialidx = tIdx;
        for t = 1:length(ss)
            idx = tIdx==qidx(t); %find the trials with index sidx(t)
            trialidx(idx) = t;
        end
    else
        trialidx = tIdx;
    end
    df2.data.trialidx = trialidx;
    df2.data.spiketimes = sptimes;
    df2.data.setIndex = setIdx;
    df2.data.trialobj = obj.data.trialobj(ind);
    r = df2;
elseif ~isempty(Args.EventTiming)
    ts = zeros(length(obj.data.trialobj),1);
    if isfield(obj.data.trialobj(1),Args.EventTiming)
        if isstruct(getfield(obj.data.trialobj(1),Args.EventTiming))
            if isfield(getfield(obj.data.trialobj(1),Args.EventTiming),'onset')
                for t = 1:length(obj.data.trialobj)
                    if ~isempty(getfield(obj.data.trialobj(t),Args.EventTiming))
                        ts(t) = obj.data.trialobj(t).(Args.EventTiming).onset;
                    end
                end
            else
                for t = 1:length(obj.data.trialobj)
                    if ~isempty(getfield(obj.data.trialobj(t),Args.EventTiming))
                        ts(t) = getfield(getfield(obj.data.trialobj(t),Args.EventTiming),'timestamp');
                    end
                end
            end
        else
            for t = 1:length(obj.data.trialobj)
                if ~isempty(obj.data.trialobj(t).(Args.EventTiming))
                    ts(t) = obj.data.trialobj(t).(Args.EventTiming);
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
