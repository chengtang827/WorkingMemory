function [obj, varargout] = plot(obj,varargin)
%@dirfiles/plot Plot function for dirfiles object.
%   OBJ = plot(OBJ) creates a raster plot of the neuronal
%   response.

Args = struct('LabelsOff',0,'GroupPlots',1,'GroupPlotIndex',1,'Color','b', ...
    'ReturnVars',{''}, 'ArgsOnly',0, 'Alignment','start','Sortby','','Trial','','Bins',[]);
Args.flags = {'LabelsOff','ArgsOnly'};
[Args,varargin2] = getOptArgs(varargin,Args);

% if user select 'ArgsOnly', return only Args structure for an empty object
if Args.ArgsOnly
    Args = rmfield (Args, 'ArgsOnly');
    varargout{1} = {'Args',Args};
    return;
end

if(~isempty(Args.NumericArguments))
    % plot one data set at a time
    n = Args.NumericArguments{1};
    sidx = find(obj.data.setIndex==n);
else
    % plot all data
    sidx = 1:length(obj.data.setIndex);
end

% add code for plot options here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%re-align raster if requested
spiketimes = obj.data.spiketimes(sidx);
trialidx = obj.data.trialidx(sidx);
if ~strcmpi(Args.Alignment,'start') || ~isempty(Args.Sortby)
    if isempty(Args.NumericArguments)
        warn('Realining and sorting multiple sessions is not implmented yet')
    else
        %load the trial structure to get the new alignment
        %get the session directory for the request plot
        dd = nptdata(obj);
        session_dir = getDataOrder('session');
        %,'DirString', dd.SessionDirs{n});
        cwd = pwd;
        cd(session_dir);
        if ~isempty(strmatch('Pancake',strsplit(pwd,'/'))) || ~isempty(strmatch('James',strsplit(pwd,'/')))
            tr = trialsOld('auto',varargin{:});
        else
            tr = trials('auto',varargin{:});
            et = eyetrials('auto',varargin{:});
        end
        cd(cwd);
        if ~strcmpi(Args.Alignment, 'start')
            if ~isfield(tr.data.trials(1),Args.Alignment)
                warning('Invalid alignemnt request')
            end
            obj2 = get(obj,'TrialType',Args.Trial,'AlignmentEvent',Args.Alignment,'TimeInterval',Args.Bins,'TrialObj',tr);
            % 			for t = 1:length(tr.data.trials)
            % 				idx = obj.data.trialidx==t;
            % 			end
            idcx = find(obj2.data.setIndex==n);
            spiketimes = obj2.data.spiketimes(idcx);
            trialidx = obj2.data.trialidx(idcx);
        end
        if ~isempty(Args.Sortby)
            if strcmpi(Args.Sortby, 'saccade')
                ts = get(et, 'EventTiming','saccade');
                t0 = get(et, 'EventTiming','start');
                sortby = double(ts-t0)/1000;
                sortby(sortby < 0.0) = 0.0;
            elseif ~isfield(tr.data.trials(1), Args.Sortby)
                warning('Invalid sorting request')
            else
                sortby = get(tr, 'EventTiming',Args.Sortby);
            end
            [ss,qidx] = sort(sortby);
            otrialidx = obj.data.trialidx(sidx);
            for t = 1:length(ss)
                idx = otrialidx==qidx(t); %find the trials with index sidx(t)
                trialidx(idx) = t;
            end
            cla
            plot(ss, 1:length(ss), '.k')
            hold on
        end
    end
end
plot(spiketimes, trialidx,'.','color',Args.Color);
if(~Args.LabelsOff)
    xlabel('X Axis')
    ylabel('Y Axis')
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

RR = eval('Args.ReturnVars');
for i=1:length(RR) RR1{i}=eval(RR{i}); end
varargout = getReturnVal(Args.ReturnVars, RR1);
