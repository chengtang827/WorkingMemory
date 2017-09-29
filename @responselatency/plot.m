function [obj, varargout] = plot(obj,varargin)
%@dirfiles/plot Plot function for dirfiles object.
%   OBJ = plot(OBJ) creates a raster plot of the neuronal
%   response.

Args = struct('LabelsOff',0,'GroupPlots',1,'GroupPlotIndex',1,'Color','b', ...
		  'TrialLevel', 0, 'ReturnVars',{''}, 'ArgsOnly',0);
Args.flags = {'LabelsOff','ArgsOnly','TrialLevel'};
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
    if ~Args.TrialLevel
        tidx = find(obj.data.setIndex == n);
    else
        tidx = n;
    end
else
	% plot all data
	n = 1;
    tidx = 1:size(obj.data.density,2);
end

if length(tidx) == 1
    plot(obj.data.xi, obj.data.density(:,tidx))  
else
    %use only trials with non-zeros density
    zidx = find(max(obj.data.density(:,tidx))>0);
    mu = mean(obj.data.density(:,tidx(zidx)),2);
    sigma = std(obj.data.density(:,tidx(zidx))')';
    lower = mu - sigma;
    upper = mu + sigma;
    cla
    patch('XData',[obj.data.xi(n,:) obj.data.xi(n,end:-1:1)],'YData',[lower' upper(end:-1:1)'],...
             'FaceColor',[0.3, 0.1, 0.5]);
    hold on
    plot(obj.data.xi(n,:), mu)  
    hold off
end


% add code for plot options here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% @dirfiles/PLOT takes 'LabelsOff' as an example
if(~Args.LabelsOff)
	xlabel('X Axis')
	ylabel('Y Axis')
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

RR = eval('Args.ReturnVars');
RR1 = {};
for i=1:length(RR) RR1{i}=eval(RR{i}); end 
varargout = getReturnVal(Args.ReturnVars, RR1);
