function obj = load(obj)
  fname = obj.data.Args.matname
  obj.data.waveforms = h5read(fname, '/waveforms');
  obj.data.spikeidx = h5read(fname, '/spikeidx');
  obj.data.feature_data = h5read(fname, '/feature_data');
  obj.data.cluster_id = h5read(fname, '/clusterid');
  obj.data.cid = h5read(fname, '/cid');
  obj.data.sampling_rate = h5read('/sampling_rate');
  obj;
end
