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

Args = struct('ObjectLevel',0, 'AnalysisLevel',0,'TrialType','','EventMarkers','','TimeInterval',[]);
Args.flags ={'ObjectLevel','AnalysisLevel'};
Args = getOptArgs(varargin,Args);

% set variables to default
r = [];
cwd = pwd;
if(Args.ObjectLevel)
    % specifies that the object should be created in the session directory
    r = 'cell';
elseif(Args.AnalysisLevel)
    % specifies that the AnalysisLevel of the object is 'AllIntragroup'
    r = 'Single';
elseif(~isempty(Args.TrialType) && isempty(Args.EventMarkers) && isempty(Args.TimeInterval))
    if strcmpi(Args.TrialType,'Correct')
        ind = [];
        session_dir = getDataDirNew('session');
        cd(session_dir)
        if ~isempty(strmatch('Pancake',strsplit(pwd,'/'))) || ~isempty(strmatch('James',strsplit(pwd,'/')))
            tr = trialsOld('auto',varargin{:});
        else
            tr = trials('auto',varargin{:});
        end
        cd(cwd)
        for i = 1:length(tr.data.trials)
            if tr.data.trials(i).reward
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
        r = df;
    elseif strcmpi(Args.TrialType,'Error') || strcmpi(Args.TrialType,'error')
        ind = [];
        session_dir = getDataDirNew('session');
        cd(session_dir)
        if ~isempty(strmatch('Pancake',strsplit(pwd,'/'))) || ~isempty(strmatch('James',strsplit(pwd,'/')))
            tr = trialsOld('auto',varargin{:});
        else
            tr = trials('auto',varargin{:});
        end
        cd(cwd)
        for i = 1:length(tr.data.trials)
            if tr.data.trials(i).failure && tr.data.trials(i).response
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
        r = df;
    elseif strcmpi(Args.TrialType,'Aborted') || strcmpi(Args.TrialType,'aborted')
        ind = [];
        session_dir = getDataDirNew('session');
        cd(session_dir)
        if ~isempty(strmatch('Pancake',strsplit(pwd,'/'))) || ~isempty(strmatch('James',strsplit(pwd,'/')))
            tr = trialsOld('auto',varargin{:});
        else
            tr = trials('auto',varargin{:});
        end
        cd(cwd)
        for i = 1:length(tr.data.trials)
            if tr.data.trials(i).failure && ~tr.data.trials(i).response
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
        r = df;
    end
elseif(~isempty(Args.EventMarkers) && ~isempty(Args.TimeInterval) && ~isempty(Args.TrialType))
    ind = [];
    session_dir = getDataDirNew('session');
    cd(session_dir)
    if ~isempty(strmatch('Pancake',strsplit(pwd,'/'))) || ~isempty(strmatch('James',strsplit(pwd,'/')))
        tr = trialsOld('auto',varargin{:});
    else
        tr = trials('auto',varargin{:});
    end
    cd(cwd)
    for i = 1:length(tr.data.trials)
        if strcmpi(Args.TrialType,'correct')
            if tr.data.trials(i).reward
                ind = [ind i];
            end
        elseif strcmpi(Args.TrialType,'error')
            if tr.data.trials(i).failure && tr.data.trials(i).response
                ind = [ind i];
            end
        elseif strcmpi(Args.TrialType,'aborted')
            if tr.data.trials(i).failure && ~tr.data.trials(i).response
                ind = [ind i];
            end
        end
    end
    bins = Args.TimeInterval;sptimes=[];tIdx=[];setIdx=[];
    for j = 1:length(ind)
        if strcmpi(Args.EventMarkers,'target')
            if ~isempty(strmatch('Pancake',strsplit(pwd,'/'))) || ~isempty(strmatch('James',strsplit(pwd,'/')))
                time_onset = tr.data.trials(ind(j)).target.timestamp - bins(1);
                time_offset = tr.data.trials(ind(j)).target.timestamp + bins(2);
            else
                time_onset = tr.data.trials(ind(j)).target.onset - bins(1);
                time_offset = tr.data.trials(ind(j)).target.onset + bins(2);
            end
            tr_ind = find(obj.data.trialidx==ind(j) & (obj.data.spiketimes>time_onset & obj.data.spiketimes < time_offset));
            sptimes = [sptimes; obj.data.spiketimes(tr_ind)];
            tIdx = [tIdx; obj.data.trialidx(tr_ind)];
            setIdx = [setIdx; obj.data.setIndex(tr_ind)];
        elseif strcmpi(Args.EventMarkers,'distractor')
            if ~isempty(strmatch('Pancake',strsplit(pwd,'/'))) || ~isempty(strmatch('James',strsplit(pwd,'/')))
                time_onset = tr.data.trials(ind(j)).distractors(1) - bins(1);
                time_offset = tr.data.trials(ind(j)).distractors(1) + bins(2);
            else
                time_onset = tr.data.trials(ind(j)).distractor.onset - bins(1);
                time_offset = tr.data.trials(ind(j)).distractor.onset + bins(2);
            end
            tr_ind = find(obj.data.trialidx==ind(j) & (obj.data.spiketimes>time_onset & obj.data.spiketimes < time_offset));
            sptimes = [sptimes; obj.data.spiketimes(tr_ind)];
            tIdx = [tIdx; obj.data.trialidx(tr_ind)];
            setIdx = [setIdx; obj.data.setIndex(tr_ind)];
        elseif strcmpi(Args.EventMarkers,'saccade')
            if ~isempty(strmatch('Pancake',strsplit(pwd,'/'))) || ~isempty(strmatch('James',strsplit(pwd,'/')))
                time_onset = tr.data.trials(ind(j)).saccade.timestamp - bins(1);
                time_offset = tr.data.trials(ind(j)).saccade.timestamp + bins(2);
            else
                time_onset = tr.data.trials(ind(j)).saccade.onset - bins(1);
                time_offset = tr.data.trials(ind(j)).saccade.onset + bins(2);
            end
            tr_ind = find(obj.data.trialidx==ind(j) & (obj.data.spiketimes>time_onset & obj.data.spiketimes < time_offset));
            sptimes = [sptimes; obj.data.spiketimes(tr_ind)];
            tIdx = [tIdx; obj.data.trialidx(tr_ind)];
            setIdx = [setIdx; obj.data.setIndex(tr_ind)];
        end
    end
    df = obj;
    df.data.trialidx = tIdx;
    df.data.spiketimes = sptimes;
    df.data.setIndex = setIdx;
    r = df;
else
    % if we don't recognize and of the options, pass the call to parent
    % in case it is to get number of events, which has to go all the way
    % nptdata/get
    r = get(obj.nptdata,varargin{:});
end
