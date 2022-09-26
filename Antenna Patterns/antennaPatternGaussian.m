function [ magOut] = antennaPatternGaussian( theta, thetaBw, varargin )
%ANTENNAPATTERNGAUSSIAN Axially-symmetric gaussian electric field antenna pattern
%   Electric field pattern of the form exp(-1.3863*(theta./thetaBw).^2)
%    theta - spherical coordinate for antenna pointing in +z direction
%    thetaBw - halfpower beamwidth (units the same as theta)
%   Usage: efield = antennaPatternGaussian(theta, thetaBw);
%
%   The antenna pattern magnitude can optionally be scaled so that the
%    total radiated power is 1 Watt, regardless of beamwidth. The units of
%    theta and thetaBw must be in radians in this usage.
%       efield = antennaPatternGaussian(theta, thetaBw, "NormalizeOutputPower", 1);

%% Parse Inputs
p = inputParser;
addParameter(p, "NormalizeOutputPower", 0);
parse(p, varargin{:});

%% Generate Pattern
if p.Results.NormalizeOutputPower == 0
    % Maximum value is 1
    magOut = exp(-log(4)*(theta./thetaBw).^2);
else
    % Total radiated power (spherical) is 1 Watt
    %  i.e., integral(magOut(theta)^2 * sin(theta), 0, pi) = 2
    normFactor = sqrt(abs(0.25 * thetaBw .* dawsonIntegral(0.25 * thetaBw ...
        ./ sqrt(log(2))) ./ sqrt(log(2))));
    magOut = exp(-log(4)*(theta./thetaBw).^2) ./ normFactor;
end

end

function [F] = dawsonIntegral(x)
    F = exp(-x.^2) .* integral(@(t) exp(t.^2), 0, x);
end
