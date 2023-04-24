function [Image] = sar2d(S, x, z, f, options)
%SAR3D Calculate SAR image(s) from a uniform 1D scan data set or sets.
% This function returns a 2D complex SAR image given measurement data from
% a 1D frequency-stepped x-raster scan. Optionally, can process multiple
% data sets having the same dimensions simultaneously.
%
% Example Usage:
%   Img = sar2d(S, x, z, f);
%   Img = sar2d(S, x, z, f, ZeroPadPercent=25);
%   Img = sar2d(S, x, z, f, RemoveAverage=false);
%   Img = sar2d(S, x, z, f, Er=[2, 3], Thk=[10, inf]);
%
% The output Img will have size length(x) by length(z) by ...,
% each value correspoding to the measurement made at the coordinate
% corresponding to the same indices in the inputs x and z, with extra
% dimensions (3 and onward) being preserved in the output. Each image
% Img(:, :, ii) will be a SAR image of the data S(:, :, ii).
%
% The default units are mm and GHz, but this can be changed by specifying
% the speed of light as an optional named parameter.
%
% Inputs:
%   S - Matrix of size length(x) by by length(f) by ..., each value
%       correspoding to the measurement made at the coordinate and
%       frequency corresponding to the same indices in the inputs x and f.
%       The matrix S may have any number of extra dimensions, and each of
%       S(:, :, ii) will be treated as an independent data set.
%   x - Vector of sample x-coordinates.
%   z - Vector of desired z-coordinates.
%   f - Vector of sample frequency coordinates.
% Outputs:
%   Img - Matrix of size length(x) by length(z) by ..., each value
%       correspoding to the measurement made at the coordinate
%       corresponding to the same indices in the inputs x, y, z. The 3rd
%       dimensions and onward will be the same size as the input S.
%       Essentially, Img(:, :, ii) will be the SAR image of the data set
%       S(:, :, ii).
% Named Arguments:
%   ZeroPadPercent (0) - Amount of zero padding to use on the x-axis.
%       Expressed as a percentage of the input size. For example, a value
%       of 100 will result in the input matrix size being doubled along
%       the x-axis.
%   RemoveAverage (true) - If true, the average value for each column in
%       the input S will be removed (e.g., S = S - mean(S, 1);).
%   SpeedOfLight (299.792458) - Value of speed of light to use.
%   Er (1) - Vector of dielectric constants for each layer.
%   Thk (inf) - Vector of thicknesses for each layer. Thk(end) is assumed
%       to be inf (i.e., infinite half-space). Must be same lenth as Er.
%
% Author: Matt Dvorsky

arguments
    S double;
    x(:, 1) double;
    z(:, 1) double;
    f(:, 1) double;
    options.ZeroPadPercent(1, 1) double = 0;
    options.RemoveAverage(1, 1) {mustBeNumericOrLogical} = true;
    options.SpeedOfLight(1, 1) {mustBePositive} = 299.792458;
    options.Er(:, 1) {mustBeGreaterThanOrEqual(options.Er, 1)} = 1;
    options.Thk(:, 1) {mustBePositive} = inf;
end

%% Use sar3d to Compute Output
options.ZeroPadPercentX = options.ZeroPadPercent;
options.ZeroPadPercent = 0;
optionsCell = namedargs2cell(options);

% Add in y-dimension with size 1
S = reshape(S, [size(S, 1), 1, size(S, 2:max(2, ndims(S)))]);

Image = sar3d(S, x, 0, z, f, optionsCell{:});

%% Reshape Output to Correct Size
Image = reshape(Image, [size(Image, 1), size(Image, 3:max(3, ndims(Image)))]);

end