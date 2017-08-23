function [obj, varargout] = plot(obj,varargin)
%@dirfiles/plot Plot function for dirfiles object.
%   OBJ = plot(OBJ) creates a raster plot of the neuronal
%   response.

Args = struct('LabelsOff',0,'GroupPlots',1,'GroupPlotIndex',1,'Color','b', ...
		  'ReturnVars',{''}, 'ArgsOnly',0);
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
else
	% plot all data
	n = 1;
end

%plot feature space
ax1 = subplot(2,2,1);
scatter3(ax1, obj.data.feature_data(1,:), obj.data.feature_data(2,:),...
				 obj.data.feature_data(3,:),1.0, obj.data.cid);
%plot waveforms
%segregate into different clusters
clusterids = unique(obj.data.cid);
cm = colormap;
cc = cm(clusterids, :);
ax2 = subplot(2,2,2);
for ci = 1:length(clusterids)
	idx = find(obj.data.cid == clusterids(ci));
	plot(ax2, obj.data.waveforms(:,idx),'color', cc(ci,:));
end

if(~Args.LabelsOff)
	ax1 = subplot(2,2,1);
	xlabel(ax1, 'X Axis')
	ylabel(ax1, 'Y Axis')
	zlabel(ax1, 'Z Axis')
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

RR = eval('Args.ReturnVars')
RR1 = {''};
for i=1:length(RR)
	RR1{i}=eval(RR{i});
end
varargout = getReturnVal(Args.ReturnVars, RR1);
