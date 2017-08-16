function [obj, varargout] = plot(obj,varargin)
%@dirfiles/plot Plot function for dirfiles object.
%   OBJ = plot(OBJ) creates a raster plot of the neuronal
%   response.

Args = struct('LabelsOff',0,'AverageRuns',0,'RunNumber',1,'GroupPlots',1,'GroupPlotIndex',1,'Color','b', ...
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


if Args.AverageRuns
    %find the average over all the trials
    stimLoc = [];
    spikeCount = [];
    flags = [];
    for i = 1:length(obj.data)
        stimLoc = [stimLoc;obj.data(i).stimLoc];
        spikeCount = [spikeCount obj.data(i).spikeCount];
        flags = [flags;obj.data(i).flags];
    end
else
    runnr = Args.RunNumber;
    stimLoc = obj.data(runnr).stimLoc;
    spikeCount = obj.data(runnr).spikeCount;
    flags = obj.data(runnr).flags;
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
