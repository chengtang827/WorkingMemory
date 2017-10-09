function [words,timestamps] = createWords(event_ids, event_ts)
    words = [];
    timestamps = [];
    [sorted_ts, sidx] = sort(event_ts);
    sorted_ids = event_ids(sidx);
    i = 1;
    while (i < length(event_ts)) && sorted_ts(i) < 0
      i = i + 1;
    end
    nn = max(event_ids);
    w = zeros(1,nn);
    w(sorted_ids(i)) = 1;
    for j=i+1:length(event_ts)
        if sorted_ts(j) - sorted_ts(j-1) < 1e-4
          w(sorted_ids(j)) = 1;
        else
          words = [words;reverse(w)];
          w = zeros(1,nn);
          w(sorted_ids(j)) = 1;
          timestamps = [timestamps;sorted_ts(j-1)];
        end
    end
    %add the last word as well
    words = [words;w];
    timestamps = [timestamps;sorted_ts(j-1)];
end
