function [ S ] = createSarData(x, y, f, x0, y0, z0, gam, thetaBw)
%CREATESARDATARADIAL Creates radially polarized scan data
%   Inputs
%    x - vector of x coordinates (mm)
%    y - vector of y coordinates (mm)
%    f - vector of frequencies (GHz)
%    x0 - vector of point target x coordinates (mm)
%    y0 - vector of point target y coordinates (mm)
%    z0 - vector of point target z coordinates (mm)
%    gam - vector of point target reflection coefficients
%    thetaBw - antenna pattern beamwidth (radians)
%   Outputs
%    S - SAR data array of size (length(x), length(y), length(f))

c = 299.7924499512;
x1(:, 1, 1) = x;
y2(1, :, 1) = y;
k3(1, 1, :) = 2 .* pi .* f ./ c;

S = zeros(length(x), length(y), length(f));
for ii = 1:length(x0)
    [~, theta, R] = cart2sph(-x1 + x0(ii), -y2 + y0(ii), -abs(z0(ii)));
    
    Stmp = exp(-2j .* R .* k3);
    Stmp = Stmp .* gam(ii);
    Stmp = Stmp .* antennaPatternGaussian(pi/2 + theta, ...
        thetaBw, "NormalizeOutputPower", 1).^2;
    Stmp = Stmp ./ R.^2;
    
    S = S + Stmp;
end

end

