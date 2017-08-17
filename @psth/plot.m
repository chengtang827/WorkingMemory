function [obj, varargout] = plot(obj,varargin)
%@dirfiles/plot Plot function for dirfiles object.
%   OBJ = plot(OBJ) creates a raster plot of the neuronal
%   response.

Args = struct('LabelsOff',0,'AverageRuns',0,'SessionNumber',1,'GroupPlots',1,'GroupPlotIndex',1,'Color','b', ...
    'ReturnVars',{''}, 'ArgsOnly',0);
Args.flags = {'LabelsOff','ArgsOnly','AverageRuns'};
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
else
    % plot all data
    n = 1;
end

% add code for plot options here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
binLen = 50;%ms
sessionnr = Args.SessionNumber;

if Args.AverageRuns
    switch obj.data(1).Args.stimulus
        case 'target'
            %divide the runs into 2 categories
            %sessions with distractor and sessions without distractor
            %1 without distractor, 2 with distractor
            stimLoc = cell(2,1);
            spikeCount = cell(2,1);
            flags = cell(2,1);
            for i = 1:length(obj.data)
                if obj.data(i).flags(1,2)==0%without distractor
                    stimLoc{1} = [stimLoc{1}; obj.data(i).stimLoc];
                    spikeCount{1} = [spikeCount{1} obj.data(i).spikeCount];
                    flags{1} = [flags{1}; obj.data(i).flags];
                else
                    %with distractor
                    stimLoc{2} = [stimLoc{2}; obj.data(i).stimLoc];
                    spikeCount{2} = [spikeCount{2} obj.data(i).spikeCount];
                    flags{2} = [flags{2}; obj.data(i).flags];
                end
            end
            stimLoc = stimLoc{sessionnr};
            spikeCount = spikeCount{sessionnr};
            flags = flags{sessionnr};
            
        case 'distractor'
            %TODO
    end
else
    %display individual sessions
    
    stimLoc = obj.data(sessionnr).stimLoc;
    spikeCount = obj.data(sessionnr).spikeCount;
    flags = obj.data(sessionnr).flags;
end



%%%%%%%%%%%%%%%%
locations = {[2 2];[3 2];[4 2];[2 3];[3 3];[4 3]; [2 4]; [3 4]; [4 4]};

for i = 1:length(locations)
    location = locations{i};
    temp = stimLoc==location;
    selected = temp(:,1)&temp(:,2);
    
    %%%%%
    %only the successful trials
    selected = selected&flags(:,4);
    %%%%%
    psth = squeeze(mean(spikeCount(:,selected,:),2));
    
    subplot(3,3,i);
    plot(-275:50:2575,psth(n,:)/(binLen/1000));
    xlim([-300 2600]);
end
% @dirfiles/PLOT takes 'LabelsOff' as an example
if(~Args.LabelsOff)
    xlabel('X Axis')
    ylabel('Y Axis')
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

RR = eval('Args.ReturnVars');
for i=1:length(RR) RR1{i}=eval(RR{i}); end
varargout = getReturnVal(Args.ReturnVars, RR1);
