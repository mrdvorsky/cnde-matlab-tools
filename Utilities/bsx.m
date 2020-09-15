function [ varargout ] = bsx( varargin )
%BSX Make inputs the same size by expanding singleton dimensions
%   Example Usage: [x, y, z] = bsx(xin, yin, zin);
%    In this example, inputs and outputs are as follows.
%    xin   - Array of size (1-3-4-1-1)
%    yin   - Array of size (1-3-1-7-6)
%    zin   - Array of size (2-1-1-7-1)
%    x,y,z - All have size (2-3-4-7-6). Each was duplicated along their
%    respective singleton dimensions. If two inputs share a non-singleton
%    dimension, the dimension sizes must be the same (e.g., 4th dimension
%    of yin and zin are both 7).

dims = 1:max(cellfun(@ndims, varargin));
argRep = @(a, b) repmat(a, ceil(sizeArr(b, dims) ./ sizeArr(a, dims)));

varargout = varargin;
for nn = 2:nargin
    varargout{1} = bsxfun(argRep, varargout{1}, varargin{nn});
end

for nn = 2:nargout
    varargout{nn} = bsxfun(argRep, varargin{nn}, varargout{1});
end

end

