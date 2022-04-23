function [S] = createSarData2d(x, f, x0, z0, a0, options)
%CREATESARDATA3D Create uniform 2D SAR data from point source specificication.
% This function returns uniform SAR measurement data that would have
% occured measuring point targets located at x0(ii), z0(ii), with
% scattering coefficients a0(ii).
%
% Example Usage:
%   S = createSarData3d(x, f, x0, z0);
%   S = createSarData3d(x, f, x0, z0, a0);
%   S = createSarData3d(x, f, x0, z0, UseRangeForAmplitude=false);
%   S = createSarData3d(x, f, x0, z0, a0, SpeedOfLight=299.79e6);
% 
% The output S will be of size length(x) by by length(f), each value
% correspoding to the measurement made at the coordinate and frequency
% corresponding to the same indices in the inputs x and f.
%
% The default units are mm and GHz, but this can be changed by specifying
% the speed of light as an optional named parameter.
%
% Inputs:
%   x - Vector of sample x-coordinates.
%   f - Vector of sample frequency coordinates.
%   x0 - Vector of point target x-coordinates. Inputs x0, y0, z0, and a0
%       must have compatible sizes.
%   z0 - Vector of point target z-coordinates.
%   a0 (optional) - Vector of point target reflectivities. Must be same
%       length as x0. Defaults to ones(size(x0));
% Outputs:
%   S - Matrix of size length(x) by length(f), each value correspoding
%       to the measurement made at the coordinate and frequency
%       corresponding to the same indices in the inputs x and f.
% Named Arguments:
%   UseRangeForAmplitude (true) - Specifies whether or not to include the
%       1/R^2 term to scale the magnitude of the output.
%   SpeedOfLight (299.792458) - Value of speed of light to use.
%   ThetaBeamwidthX (inf) - Halfpower beamwidth of the antenna in the
%       xz-plane in radians.
%   Er (1) - Vector of dielectric constants for each layer.
%   Thk (inf) - Vector of thicknesses for each layer. Thk(end) is assumed
%       to be inf (i.e., infinite half-space). Must be same lenth as Er.
%   DispersionTableSize (1001) - Number of points to use for multilayer
%       dispersion lookup table.
%
% Author: Matt Dvorsky

arguments
    x(:, 1, 1) {mustBeReal};
    f(1, 1, :) {mustBePositive};
    x0(:, 1) {mustBeReal};
    z0(:, 1) {mustBeReal};
    a0(:, 1) = ones(size(x0));
    options.UseRangeForAmplitude {mustBeNumericOrLogical} = true;
    options.SpeedOfLight(1, 1) {mustBePositive} = 299.792458;
    options.ThetaBeamwidthX(1, 1) {mustBePositive} = inf;
    options.Er(:, 1) {mustBeGreaterThanOrEqual(options.Er, 1)} = 1;
    options.Thk(:, 1) {mustBePositive} = inf;
    options.DispersionTableSize(1, 1) {mustBeInteger, mustBePositive} = 101;
end

%% Use createSarData3d to Calculate Output
optionsCell = namedargs2cell(options);
S = createSarData3d(x, 0, f, x0, 0, z0, a0, optionsCell{:});

%% Reshape Output to Correct Size
S = reshape(S, [size(S, 1), size(S, 3:max(3, ndims(S)))]);

end
