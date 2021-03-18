function [ magOut] = antennaPatternRadialPolarization(theta, theta0, varargin)
%ANTENNAPATTERNRADIALPOLARIZATION Radially-polarized antenna electric field pattern
%   Electric field pattern of a radially-polarized probe
%    theta - spherical coordinate for antenna pointing in +z direction
%    thetaBw - antennna maximum beamangle (units the same as theta)
%   Usage: efield = antennaPatternRadialPolarization(theta, thetaBw);
%
%   The antenna pattern magnitude can optionally be scaled so that the
%    total radiated power is 1 Watt, regardless of beamwidth. The units of
%    theta and thetaBw must be radians in this usage.
%       efield = antennaPatternRadialPolarization(theta, thetaBw, "NormalizeOutputPower", 1);


%% Parse Inputs
p = inputParser;
addParameter(p, "NormalizeOutputPower", 0);
parse(p, varargin{:});

%% Generate Pattern
x0 = theta0;
x = theta;

if p.Results.NormalizeOutputPower == 0
    % Maximum value is 1
    magOut = abs(exp(0.5).*(x./x0).*exp(-0.5.*(x./x0).^2));
else
    % Total radiated power (spherical) is 1 Watt
    %  i.e., integral(magOut(theta)^2 * sin(theta), 0, pi) = 2
    magOut = abs(2.*(x./(x0.*sin(x0))).*exp(-0.5.*(x./x0).^2));
end

end

