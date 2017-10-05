function [obj, varargout] = plot(obj,varargin)
%@dirfiles/plot Plot function for dirfiles object.
%   OBJ = plot(OBJ) creates a raster plot of the neuronal
%   response.

Args = struct('LabelsOff',0,'GroupPlots',1,'GroupPlotIndex',1,'Color','b', ...
    'ReturnVars',{''}, 'ArgsOnly',0,'Sortby','');
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
    spikecount = squeeze(obj.data.spikecount(find(obj.data.setIndex==sidx),:,:));
    edges = obj.data.edges(find(obj.data.setIndex==sidx));
else
    % plot all data
   sidx = 1:length(obj.data.setIndex);
   spikecount = obj.data.spikecount;
   edges = obj.data.edges;
end

% add code for plot options here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(Args.Sortby)
    plot(obj.data.edges(2:end),mean(spikecount,1)/(obj.data.edges(2) - obj.data.edges(1)),'LineStyle','-','color',Args.Color)
    if obj.data.edges(1) < 0 && obj.data.edges(end) > 0
        line([0 0],ylim,'color','black','LineStyle',':');
    elseif obj.data.edges(1) < 0.3 && obj.data.edges(end) > 0.3
        line([0.3 0.3],ylim,'color','black','LineStyle',':');
    elseif obj.data.edges(1) < 1.3 && obj.data.edges(end) > 1.3
        line([1.3 1.3],ylim,'color','black','LineStyle',':');
    elseif obj.data.edges(1) < 1.6 && obj.data.edges(end) > 1.6
        line([1.6 1.6],ylim,'color','black','LineStyle',':');
    end
elseif strcmpi(Args.Sortby,'target')
    tar_loc = AssignTrialLabel(obj.data.trialobj,1);
    n_tar = unique(tarloc);
    for i = 1:length(n_tar)
        if i < 5
            subplot(3,3,i)
            tr_ind = find(tar_loc==i);
            plot(obj.data.edges(2:end),mean(spikecount(tr_ind,:),1)/(obj.data.edges(2) - obj.data.edges(1)),'LineStyle','-','color',Args.Color);
        else
            subplot(3,3,i+1);
            tr_ind = find(tar_loc==i);
            plot(obj.data.edges(2:end),mean(spikecount(tr_ind,:),1)/(obj.data.edges(2) - obj.data.edges(1)),'LineStyle','-','color',Args.Color);
        end
        linkaxes
            if obj.data.edges(1) < 0 && obj.data.edges(end) > 0
                line([0 0],ylim,'color','black','LineStyle',':');
            elseif obj.data.edges(1) < 0.3 && obj.data.edges(end) > 0.3
                line([0.3 0.3],ylim,'color','black','LineStyle',':');
            elseif obj.data.edges(1) < 1.3 && obj.data.edges(end) > 1.3
                line([1.3 1.3],ylim,'color','black','LineStyle',':');
            elseif obj.data.edges(1) < 1.6 && obj.data.edges(end) > 1.6
                line([1.6 1.6],ylim,'color','black','LineStyle',':');
            end        
    end
elseif strcmpi(Args.Sortby,'distractor')
     tar_loc = AssignTrialLabel(obj.data.trialobj,2);
    n_tar = unique(tarloc);
    for i = 1:length(n_tar)
        if i < 5
            subplot(3,3,i)
            tr_ind = find(tar_loc==i);
            plot(obj.data.edges(2:end),mean(spikecount(tr_ind,:),1)/(obj.data.edges(2) - obj.data.edges(1)),'LineStyle','-','color',Args.Color);
        else
            subplot(3,3,i+1);
            tr_ind = find(tar_loc==i);
            plot(obj.data.edges(2:end),mean(spikecount(tr_ind,:),1)/(obj.data.edges(2) - obj.data.edges(1)),'LineStyle','-','color',Args.Color);
        end
        linkaxes
            if obj.data.edges(1) < 0 && obj.data.edges(end) > 0
                line([0 0],ylim,'color','black','LineStyle',':');
            elseif obj.data.edges(1) < 0.3 && obj.data.edges(end) > 0.3
                line([0.3 0.3],ylim,'color','black','LineStyle',':');
            elseif obj.data.edges(1) < 1.3 && obj.data.edges(end) > 1.3
                line([1.3 1.3],ylim,'color','black','LineStyle',':');
            elseif obj.data.edges(1) < 1.6 && obj.data.edges(end) > 1.6
                line([1.6 1.6],ylim,'color','black','LineStyle',':');
            end        
    end
end
    %
    % @dirfiles/PLOT takes 'LabelsOff' as an example
    if(~Args.LabelsOff)
        xlabel('X Axis')
        ylabel('Y Axis')
    end
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    RR = eval('Args.ReturnVars');
    for i=1:length(RR) RR1{i}=eval(RR{i}); end
    varargout = getReturnVal(Args.ReturnVars, RR1);
