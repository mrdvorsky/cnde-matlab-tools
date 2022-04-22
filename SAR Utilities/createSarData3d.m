function [S] = createSarData3d(x, y, f, x0, y0, z0, a0, options)
%CREATESARDATA3D Create uniform SAR data from point source specificication.
% This function returns uniform SAR measurement data that would have
% occured measuring point targets located at x0(ii), y0(ii), z0(ii)
% with scattering coefficients a0(ii).
%
% Example Usage:
%   S = createSarData3d(x, y, f, x0, y0, z0);
%   S = createSarData3d(x, y, f, x0, y0, z0, a0);
%   S = createSarData3d(x, y, f, x0, y0, z0, UseRangeForAmplitude=false);
%   S = createSarData3d(x, y, f, x0, y0, z0, a0, SpeedOfLight=299.79e6);
% 
% The output S will be of size length(x) by length(y) by length(f), each
% value correspoding to the measurement made at the coordinate and
% frequency corresponding to the same indices in the inputs x, y, f.
%
% The default units are mm and GHz, but this can be changed by specifying
% the speed of light as an optional named parameter.
%
% Inputs:
%   x - Vector of sample x-coordinates.
%   y - Vector of sample y-coordinates.
%   f - Vector of sample frequency coordinates.
%   x0 - Vector of point target x-coordinates. Inputs x0, y0, z0, and a0
%       must have compatible sizes.
%   y0 - Vector of point target y-coordinates.
%   z0 - Vector of point target z-coordinates.
%   a0 (optional) - Vector of point target reflectivities. Must be same
%       length as x0. Defaults to ones(size(x0));
% Outputs:
%   S - Matrix of size length(x) by length(y) by length(f), each value
%       correspoding to the measurement made at the coordinate and
%       frequency corresponding to the same indices in the inputs x, y, f.
% Named Arguments:
%   UseRangeForAmplitude (true) - Specifies whether or not to include the
%       1/R^2 term to scale the magnitude of the output.
%   SpeedOfLight (299.792458) - Value of speed of light to use.
%   ThetaBeamwidthX (inf) - Halfpower beamwidth of the antenna in the
%       xz-plane in radians.
%   ThetaBeamwidthY (inf) - Same as thetaBeamwidthX for the yz-plane.
%   Er (1) - Vector of dielectric constants for each layer.
%   Thk (inf) - Vector of thicknesses for each layer. Thk(end) is assumed
%       to be inf (i.e., infinite half-space). Must be same lenth as Er.
%   DispersionTableSize (1001) - Number of points to use for multilayer
%       dispersion lookup table.
%
% Author: Matt Dvorsky

arguments
    x(:, 1, 1) {mustBeReal};
    y(1, :, 1) {mustBeReal};
    f(1, 1, :) {mustBePositive};
    x0(:, 1) {mustBeReal};
    y0(:, 1) {mustBeReal};
    z0(:, 1) {mustBeReal};
    a0(:, 1) = ones(size(x0));
    options.UseRangeForAmplitude {mustBeNumericOrLogical} = true;
    options.SpeedOfLight(1, 1) {mustBePositive} = 299.792458;
    options.ThetaBeamwidthX(1, 1) {mustBePositive} = inf;
    options.ThetaBeamwidthY(1, 1) {mustBePositive} = inf;
    options.Er(:, 1) {mustBeGreaterThanOrEqual(options.Er, 1)} = 1;
    options.Thk(:, 1) {mustBePositive} = inf;
    options.DispersionTableSize(1, 1) {mustBeInteger, mustBePositive} = 101;
end

%% Check for Argument Size Mismatch
try
    [x0, y0, z0, a0] = bsx(x0, y0, z0, a0);
catch
    error(strcat("Non-singleton dimensions of x0, y0, z0, and a0", ...
        " (4th through 7th arguments) must match each other."));
end

if numel(options.Er) ~= numel(options.Thk)
    error("Er and Thk must have the same length.");
end

%% Calculate Dispersion
ior(1, :) = sqrt(options.Er);

psi = zeros(options.DispersionTableSize, numel(options.Thk));
psi(:, 1) = (0:options.DispersionTableSize - 1) .* (0.5*pi) ...
    ./ options.DispersionTableSize;
for ii = 2:numel(options.Er)
    psi(:, ii) = asin(ior(ii - 1) ./ ior(ii) .* sin(psi(:, ii - 1)));
end

%% Create SAR Data
k = 2*pi .* f ./ options.SpeedOfLight;
S = 0*(x + y + f);
for ii = 1:length(z0)
    % Calculate R and Psi adjusted for multilayer structure.
    if numel(options.Er) > 1
        % Create refraction lookup table for specific liftoff.
        layerInd = 1 + sum(cumsum(abs(options.Thk)) < abs(z0(ii)));
        zLayers = abs(options.Thk).';
        zLayers(layerInd:end) = 0;
        zLayers(layerInd) = abs(z0(ii)) - abs(sum(options.Thk(1:layerInd - 1)));
        
        xQuery = sum(zLayers .* tan(psi), 2);
        RQuery = sum(zLayers ./ cos(psi) .* ior, 2);
        R_interp = griddedInterpolant(xQuery, RQuery);
        
        R = R_interp(hypot(x - x0(ii), y - y0(ii)));
    else
        R = sqrt(options.Er) .* hypot(z0(ii), hypot(x - x0(ii), y - y0(ii)));
    end
    
    % Calculate SAR values.
    S_ii = exp(-2j .* k .* R) .* a0(ii);
    
    if options.UseRangeForAmplitude
        S_ii = S_ii ./ R.^2;
    end
    
    if isfinite(options.ThetaBeamwidthX)
        S_ii = S_ii .* antennaPatternGaussian(atan2(abs(x - x0(ii)), abs(z0(ii))), ...
            options.ThetaBeamwidthX);
    end
    
    if isfinite(options.ThetaBeamwidthY)
        S_ii = S_ii .* antennaPatternGaussian(atan2(abs(y - y0(ii)), abs(z0(ii))), ...
            options.ThetaBeamwidthY);
    end
    
    S = S + S_ii;
end

end
