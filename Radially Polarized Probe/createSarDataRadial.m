function [ S ] = createSarDataRadial(x, y, f, x0, y0, z0, a0, e0, p0, np0, thetaBw)
%CREATESARDATARADIAL Creates radially polarized scan data
%   Inputs
%    x - vector of x coordinates (mm)
%    y - vector of y coordinates (mm)
%    f - vector of frequencies (GHz)
%    x0 - vector of point target x coordinates (mm)
%    y0 - vector of point target y coordinates (mm)
%    z0 - vector of point target z coordinates (mm)
%    a0 - vector of point target azimuth angles (radians)
%    e0 - vector of point target elevation angles (radians)
%    p0 - vector of point target polarizing reflection coefficients
%    np0 - vector of point target non-polarizing reflection coefficients
%    thetaBw - antenna pattern beamangle (radians)
%   Outputs
%    S - SAR data array of size (length(x), length(y), length(f))

c = 299.7924499512;
x1(:, 1, 1) = x;
y2(1, :, 1) = y;
k3(1, 1, :) = 2 .* pi .* f ./ c;

S = zeros(length(x), length(y), length(f));
for ii = 1:length(x0)
    [phi, theta, R] = cart2sph(-x1 + x0(ii), -y2 + y0(ii), -abs(z0(ii)));
    polDot = cos(a0(ii) - phi) .* cos(e0(ii)) .* cos(theta + pi/2) ...
        + sin(e0(ii)) .* sin(theta + pi/2);
    
    Stmp = exp(-2j .* R .* k3);
    Stmp = Stmp .* (p0(ii) .* polDot.^2 + np0(ii));
    Stmp = Stmp .* radialProbePattern(pi/2 + theta, thetaBw);
    Stmp = Stmp ./ R.^2;
    
    S = S + Stmp;
end

end

