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
%   S = createSarData3d(x, y, f, x0, y0, z0, a0, SpeedOfLight=299.78e6);
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
%   x0 - Vector of point target x-coordinates.
%   y0 - Vector of point target y-coordinates. Must be same length as x0.
%   z0 - Vector of point target z-coordinates. Must be same length as x0.
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
%
% Author: Matt Dvorsky

arguments
    x(:, 1, 1);
    y(1, :, 1);
    f(1, 1, :);
    x0(:, 1);
    y0(:, 1);
    z0(:, 1);
    a0(:, 1) = ones(size(x0));
    options.UseRangeForAmplitude = true;
    options.SpeedOfLight(1, 1) = 299.792458;
    options.ThetaBeamwidthX(1, 1) = inf;
    options.ThetaBeamwidthY(1, 1) = inf;
    options.Er(:, 1) = 1;
    options.Thk(:, 1) = inf;
end

%% Create SAR Data
k = 2*pi .* f ./ options.SpeedOfLight;
S = 0*(x + y + f);
for ii = 1:length(z0)
    % Create refraction lookup table for specific liftoff.
    
    
    R = hypot(z0(ii), hypot(x - x0(ii), y - y0(ii)));
    S_ii = exp(-2j .* k .* R) .* a0(ii);
    
    if options.UseRangeForAmplitude
        S_ii = S_ii ./ R.^2;
    end
    
    if isfinite(options.thetaBeamwidthX)
        S_ii = S_ii .* antennaPatternGaussian(atan2(abs(x - x0(ii)), abs(z0(ii))), ...
            options.thetaBeamwidthX);
    end
    
    if isfinite(options.thetaBeamwidthY)
        S_ii = S_ii .* antennaPatternGaussian(atan2(abs(y - y0(ii)), abs(z0(ii))), ...
            options.thetaBeamwidthY);
    end
    
    S = S + S_ii;
end

end

