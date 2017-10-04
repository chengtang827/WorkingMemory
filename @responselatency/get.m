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

Args = struct('ObjectLevel',0, 'AnalysisLevel',0,'TrialLevel',0, 'Smoothed',0);
Args.flags ={'ObjectLevel','AnalysisLevel','TrialLevel'};
Args = getOptArgs(varargin,Args);

% set variables to default
r = [];

if(Args.ObjectLevel)
	% specifies that the object should be created in the session directory
	r = 'cell';
elseif(Args.AnalysisLevel)
	% specifies that the AnalysisLevel of the object is 'AllIntragroup'
	r = 'Single';
elseif Args.TrialLevel
    r = length(obj.data.setIndex);
elseif Args.Smoothed > 0
	scounts = zeros(size(obj.data.counts));
	for i = 1:size(scounts,2)
		scounts(:,i) = smooth(obj.data.counts(:,i),Args.Smoothed);
	end
	r = scounts;
else
	% if we don't recognize and of the options, pass the call to parent
	% in case it is to get number of events, which has to go all the way
	% nptdata/get
	r = get(obj.nptdata,varargin{:});
end
