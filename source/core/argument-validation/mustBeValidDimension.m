function [] = mustBeValidDimension(dim, options)
%Validate that value is a valid dimension index.
% Throws an error if dim is not a positive integer vector (or scalar) or
% the string "all" or 'all'. If AllowVector is set to false (default is
% true), then dim can only be a positive integer scalar.
%
% Example Usage:
%   arguments
%       ...
%       dim1(:, 1) {mustBeValidDimension};      % Allows vector or "all".
%       dim2(:, 1) {mustBeValidDimension(dim2, AllowVector=0)}; % Scalar only.
%       ...
%   end
%
% Author: Matt Dvorsky

arguments
    dim;

    options.AllowVector(1, 1) logical = true;
end

%% Check Argument
if options.AllowVector
    if strcmp(dim, "all")
        return;
    end

    if isstring(dim) || ...
            ~allfinite(dim) || ~all(dim == floor(dim), "all") ...
            || ~all(dim > 0, "all") || (numel(unique(dim)) ~= numel(dim))
        throwAsCaller(MException("CNDE:mustBeValidDimension", ...
            "Dimension argument must be a positive integer scalar, " + ...
            "a vector of unique positive integers, or 'all'."));
    end
else
    if ~isscalar(dim)
        throwAsCaller(MException("CNDE:mustBeValidDimension", ...
            "Dimension argument must be a positive integer scalar."));
    end
end

end

