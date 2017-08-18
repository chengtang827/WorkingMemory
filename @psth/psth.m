function [obj, varargout] = psth(varargin)
%@psth Constructor function for PSTH class
%   OBJ = psth(varargin)
%
%   OBJ = psth('auto') attempts to create a poststimulus time histogram
%   object
%
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   % Instructions on psth %
%   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%example [as, Args] = psth('save','redo')
%   This object is calculated on a single session, cd to ../run01/ as
%   an example
%
%dependencies:

%ProcessLevel example:
%In D:\E\Matlab 2017a\bin\working memory\080817
%r = ProcessLevel(psth,'Levels','Day','save')
%InspectGUI(r)

Args = struct('RedoLevels',0, 'SaveLevels',0, 'Auto',1, 'ArgsOnly',0,'stimulus','target','binLen',50,...
    'pre',-300,'post',2600);
Args.flags = {'Auto','ArgsOnly'};
% The arguments which can be neglected during arguments checking
Args.UnimportantArgs = {'RedoLevels','SaveLevels','Auto'};

[Args,modvarargin] = getOptArgs(varargin,Args, ...
    'subtract',{'RedoLevels','SaveLevels'}, ...
    'shortcuts',{'redo',{'RedoLevels',1}; 'save',{'SaveLevels',1}}, ...
    'remove',{'Auto'});

% variable specific to this class. Store in Args so they can be easily
% passed to createObject and createEmptyObject
Args.classname = 'psth';
Args.matname = [Args.classname '.mat'];
Args.matvarname = 'ps';

% To decide the method to create or load the object
command = checkObjCreate('ArgsC',Args,'narginC',nargin,'firstVarargin',varargin);
  
if(strcmp(command,'createEmptyObjArgs'))
    varargout{1} = {'Args',Args};
    obj = createEmptyObject(Args);
elseif(strcmp(command,'createEmptyObj'))
    obj = createEmptyObject(Args);
elseif(strcmp(command,'passedObj'))
    obj = varargin{1};
elseif(strcmp(command,'loadObj'))
    l = load(Args.matname);
    obj = eval(['l.' Args.matvarname]);
elseif(strcmp(command,'createObj'))
    % IMPORTANT NOTICE!!!
    % If there is additional requirements for creating the object, add
    % whatever needed here
    obj = createObject(Args,varargin{:});
end

function obj = createObject(Args,varargin)

dlist = nptDir('trial*');
trialnr = length(dlist);
if trialnr<1
    obj = createEmptyObject(Args);
    return;
end

%%%
load('neuron_names.mat');
neuronnr = length(neurons);
stimulus = Args.stimulus;
binLen = Args.binLen;
pre = Args.pre;
post = Args.post;
binnr = ceil((post-pre)/binLen);
%%%


stimLoc = zeros(trialnr,2);
stimTs = zeros(trialnr,1);
spikeCount = zeros(neuronnr, trialnr, binnr);
flags = zeros(trialnr,4); %(target, distractor, response_cue, reward)
%1 for present, 0 for absent



for i = 1:trialnr
    load([pwd '\trial' sprintf('%02d', i) '\event.mat']);
    flags(i,1) = ~isempty(event.target);
    flags(i,2) = ~isempty(event.distractor);
    flags(i,3) = ~isempty(event.response_cue);
    flags(i,4) = ~isempty(event.reward);
    
    try
        stimLoc(i,1) = event.(stimulus).row;
        stimLoc(i,2) = event.(stimulus).column;
        stimTs(i) = event.(stimulus).timestamp;
    catch
        stimLoc(i) = NaN;
        stimTs(i) = NaN;
    end
    
    for j = 1:neuronnr
        load(['trial' sprintf('%02d', i) '\' cell2mat(neurons(j)) '.mat']);
        spike = spike - stimTs(i);
        
        for k = 1:binnr
            range = [(pre+(k-1)*binLen) (pre+k*binLen)];
            spikeCount(j,i,k) = sum(spike>=range(1)&spike<=range(2));
        end
    end
end
%%%
switch stimulus
    case 'target'
        validTrials = ~isnan(stimTs)&flags(:,4);
    case 'distractor'
        validTrials = ~isnan(stimTs)&flags(:,4);
end


data.spikeCount = spikeCount(:,validTrials,:);
data.stimLoc = stimLoc(validTrials,:);
data.flags = flags(validTrials,:);

% this is a valid object
% these are fields that are useful for most objects
data.numSets = neuronnr;
data.Args = Args;

% create nptdata so we can inherit from it

data.Args = Args;
n = nptdata(data.numSets,0,pwd);
d.data = data;
obj = class(d,Args.classname,n);

saveObject(obj,'ArgsC',Args);


function obj = createEmptyObject(Args)

% useful fields for most objects
data.numSets = 0;
data.setNames = '';

% these are object specific fields
data.dlist = [];
data.setIndex = [];

% create nptdata so we can inherit from it
data.Args = Args;
n = nptdata(0,0);
d.data = data;
obj = class(d,Args.classname,n);

