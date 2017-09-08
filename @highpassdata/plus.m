function r = plus(p,q,varargin)
%@highpassdata/plus Overloaded plus function for highpassdata objects.
%   R = plus(P,Q) combines highpassdata objects P and Q and returns the
%   highpassdata object R.

% get name of class
classname = mfilename('class');

% check if first input is the right kind of object
if(~isa(p,classname))
	% check if second input is the right kind of object
	if(~isa(q,classname))
		% both inputs are not the right kind of object so create empty
		% object and return it
		r = feval(classname);
	else
		% second input is the right kind of object so return that
		r = q;
	end
else
	if(~isa(q,classname))
		% p is the right kind of object but q is not so just return p
		r = p;
    elseif(isempty(p))
        % p is right object but is empty so return q, which should be
        % right object
        r = q;
    elseif(isempty(q))
        % p are q are both right objects but q is empty while p is not
        % so return p
        r = p;
	else
		% both p and q are the right kind of objects so add them
		% together
		% assign p to r so that we can be sure we are returning the right
		% object
		r = p;
		% useful fields for most objects
		r.data.numSets = p.data.numSets + q.data.numSets;


		% object specific fields
		r.data.data = [p.data.data r.data.data];
		r.data.channel = [p.data.channel q.data.channel];
		r.data.freq_low = [p.data.freq_low q.data.freq_low];
		r.data.freq_high = [p.data.freq_high q.data.freq_high];
		r.data.sampling_rate = p.data.sampling_rate;
		r.data.filter = [p.data.filter q.data.filter];
		% add nptdata objects as well
		r.nptdata = plus(p.nptdata,q.nptdata);
	end
end
