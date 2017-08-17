function r = ProcessDay(~, varargin)
%PROCESSDAY Summary of this function goes here
% Analyze the day, create objects based on each run, and plus them
% for example, cd D:\E\Matlab 2017a\bin\working memory\080817
% r = ProcessDay(psth, 'auto', 'save', 'redo', ...);

dlist = nptDir('session*');
r = psth();
for i = 1:length(dlist)
    cd(dlist(i).name);
    ps = psth(varargin{:});
    r = plus(r, ps);
    cd ..
end

save('r','r');

end

