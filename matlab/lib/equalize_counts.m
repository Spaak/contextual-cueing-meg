function varargout = equalize_counts(varargin)

counts = cellfun(@numel, varargin);
todraw = min(counts);
for k = 1:nargout
  if counts(k) > todraw
    varargout{k} = randsample(varargin{k}, todraw);
  else
    varargout{k} = varargin{k};
  end
end

end