function sessions  = parseEDFData(obj,edfdata,triggers)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Parse eye link data into a trial structure
    %Input:
    %edfdata    :   eyelink data structure or name of edffile
    %nrows      :   number of grid rwos
    %ncols      :   number of grid columns
    %
	%Output:
	%	trials		:		struct array with information about each trial
    %   trials.start    :    start of the trial, absoute time
    %   trials.prestim  :    start of the prestim-period, relative to trial
    %                        start
    %   trials.target.timestamp    : target onset, relative to trial start
    %   trials.target.row          : row index of the target
    %   trials.target.column       : column index of the target
    %   trials.distractors         : array of distractors; rows are time
    %                                relative to start of the trial, row
    %                                and column index
	%   trial.response			   : time, relative to target onset, of the beginning of the repsonse period
    %   trials.reward              : time of reward, relative trial start
    %   trials.failure             : time of failure, relative to trial
    %                                start
    %   trials.end                 : aboslute time of trial end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ischar(edfdata)
        edfdata = edfmex(edfdata);
    end
    if nargin < 3
        ncols = 5;
        nrows = 5;
    end
    required_fields = {'start', 'end', 'fixation_start', 'response_cue',...
                       'failure','delay', 'reward', 'target','distractor',...
                       'left_fixation'};
    nevents = length(edfdata.FEVENT);
    trialnr = 0;
    sessions = struct;
    sessionnr = 0;
    k = 1;
    trial_start_seen = false;
    trial_end_seen = false;
    skipped = [];
    nstarts = 0;
    nends = 0;
    if isfield(triggers, 'trial_start')
      trial_start_trigger = triggers.trial_start;
    else
      trial_start_trigger = '00000000';
    end
    if isfield(triggers, 'target_prefix')
      target_prefix = triggers.target_prefix;
    else
      target_prefix = '101';
    end
    if isfield(triggers, 'distractor_prefix')
      distractor_prefix = triggers.distractor_prefix;
    else
      distractor_prefix = '011';
    end
    for nextevent=1:nevents
        if ~isempty(edfdata.FEVENT(nextevent).message)
          m = strrep(edfdata.FEVENT(nextevent).message, ' ', '');
          if ~isempty(m)
            if strcmpi(m(1:3), '110') %session start
              sessionnr = sessionnr + 1; %bin2dec(m(4:end));
              sessions(sessionnr).trials = struct;
              trialnr = 0; %reset the trial counter
            elseif strcmp(m, trial_start_trigger) %trial start
              trialnr  = trialnr + 1;
              k = 1;
              trialstart = edfdata.FEVENT(nextevent).sttime;
              sessions(sessionnr).trials(trialnr).start = trialstart;
              trial_start_seen = true;
              trial_end_seen = false;
              nstarts = nstarts + 1;
            %sessions(sessionnr).trials(trialnr).saccade = struct;
            else
              if ~trial_start_seen
                skipped = [skipped nextevent];
                continue; %don't add to a trial unless trial start was seen
              end
              if strcmp(m(1:3), target_prefix) %target
                  %get the row and column index
                  if length(m) == 8
                      px = bin2dec(m(5:-1:3));
                      py = bin2dec(m(8:-1:6));
                  elseif length(m) == 14
                      px = bin2dec(m(8:-1:3));
                      py = bin2dec(m(end:-1:9));
                  end
                  sessions(sessionnr).trials(trialnr).target = struct('row', py, 'column', px, 'onset', edfdata.FEVENT(nextevent).sttime);

              elseif strcmp(m(1:3), distractor_prefix)  %distractor
                  if length(m) == 8
                      px = bin2dec(m(5:-1:3));
                      py = bin2dec(m(8:-1:6));
                  elseif length(m) == 14
                      px = bin2dec(m(8:-1:3));
                      py = bin2dec(m(end:-1:9));
                  end
                  sessions(sessionnr).trials(trialnr).distractor = struct('row', py, 'column', px, 'onset', edfdata.FEVENT(nextevent).sttime);

              elseif strcmp(m,'00000101') %go-cueue
                  sessions(sessionnr).trials(trialnr).response_cue = edfdata.FEVENT(nextevent).sttime;
              elseif strcmp(m,'00000110') %reward
                  sessions(sessionnr).trials(trialnr).reward = edfdata.FEVENT(nextevent).sttime;
              elseif strcmp(m,'00000111') %failure
                  sessions(sessionnr).trials(trialnr).failure = edfdata.FEVENT(nextevent).sttime;
              elseif strcmpi(m,'00000011') %stimulus blank
                  sessions(sessionnr).trials(trialnr).stimblank = edfdata.FEVENT(nextevent).sttime;
              elseif strcmpi(m,'00000100') %delay
                  sessions(sessionnr).trials(trialnr).delay = edfdata.FEVENT(nextevent).sttime;
              elseif strcmpi(m,'00000001') %fixation start
                  sessions(sessionnr).trials(trialnr).fixation = edfdata.FEVENT(nextevent).sttime;
                elseif strcmpi(m, '00011101') %left fixation
                  sessions(sessionnr).trials(trialnr).left_fixation = edfdata.FEVENT(nextevent).sttime;
              elseif strcmpi(m,'00100000') && trial_start_seen %trial end
                  sessions(sessionnr).trials(trialnr).end = edfdata.FEVENT(nextevent).sttime;
                  %make sure we have all required fields, if not fill them with nan
                  for fi = 1:length(required_fields)
                    if ~isfield(sessions(sessionnr).trials(trialnr),required_fields{fi})
                      if (strcmpi(required_fields{fi},'distractor') ||...
                          strcmpi(required_fields{fi},'target'))
                        sessions(sessionnr).trials(trialnr).(required_fields{fi}) = struct('row', 0, 'column',0, 'onset', nan);
                      else
                        sessions(sessionnr).trials(trialnr).(required_fields{fi}) = nan;
                      end
                    end
                  end
                  %add eye gaze data as well
                  %figure out which eye was tracked
                  if edfdata.FSAMPLE.gx(1,1) == -32768
                    tracked_eye = 2;
                  else
                    tracked_eye = 1;
                  end
                  tidx = ((edfdata.FSAMPLE.time < sessions(sessionnr).trials(trialnr).end) &...
                          (edfdata.FSAMPLE.time > sessions(sessionnr).trials(trialnr).start));
                  sessions(sessionnr).trials(trialnr).gazex = double(edfdata.FSAMPLE.gx(tracked_eye,tidx));
                  sessions(sessionnr).trials(trialnr).gazey = double(edfdata.FSAMPLE.gy(tracked_eye,tidx));
                  sessions(sessionnr).trials(trialnr).pupil = double(edfdata.FSAMPLE.pa(tracked_eye,tidx));
                  %filter out saturated points
                  sidx = sessions(sessionnr).trials(trialnr).gazex == 100000000;
                  sessions(sessionnr).trials(trialnr).gazex(sidx) = nan;
                  sessions(sessionnr).trials(trialnr).gazey(sidx) = nan;
                  sessions(sessionnr).trials(trialnr).pupil(sidx) = nan;
                  trial_start_seen = false;

              elseif strcmpi(m, '00001111') %stimulation
                  sessions(sessionnr).trials(trialnr).stim = edfdata.FEVENT(nextevent).sttime;
              end
            end
          end
        else
            if strcmpi(edfdata.FEVENT(nextevent).codestring, 'ENDSACC')
                %check that the event immediately before this was cue onset, i.e. we want to grab the first saccade after cue
                m = edfdata.FEVENT(nextevent-3).message(1:3:end);
                %TODO: we also want to get saccades for failed trials
                %before the co-cue
                %if strcmp(m,'00000101') %go-cueue
                event = edfdata.FEVENT(nextevent);
                if sessionnr > 0 && trialnr > 0 && event.sttime > trialstart
                    sessions(sessionnr).trials(trialnr).saccade(k) = struct('startx', event.gstx, 'starty', event.gsty, 'endx', event.genx', 'endy', event.geny, 'onset', event.sttime, 'offset', event.entime);
                    k = k+1;
                end
            end
        end
        pp = nextevent/nevents*100;
        %fprintf(1, '\b%.2f', pp);
    end
end
