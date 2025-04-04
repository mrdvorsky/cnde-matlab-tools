function [ S ] = createSarData3dBistatic( x, y, f, xp, yp, zp, rho0, phi0, thetaBw )

c = 299.7924499512;

x0 = rho0 .* cos(phi0);
y0 = rho0 .* sin(phi0);

x1(:, 1, 1) = x(:);
y2(1, :, 1) = y(:);
k3(1, 1, :) = (2 .* pi .* f(:)) ./ c;
S = zeros(length(x), length(y), length(f));
for ii = 1:length(xp)
    [~, theta1, R1] = cart2sph(x1 - xp(ii) - 0.5*x0, y2 - yp(ii) - 0.5*y0, abs(zp(ii)));
    [~, theta2, R2] = cart2sph(x1 - xp(ii) + 0.5*x0, y2 - yp(ii) + 0.5*y0, abs(zp(ii)));
    
%     S = S + exp(-1j .* k3 .* (R1 + R2));

%     S = S + exp(-1j .* k3 .* (R1 + R2)) ...
%         .* antennaPatternGaussian(0.5*pi - theta1, thetaBw) ...
%         .* antennaPatternGaussian(0.5*pi - theta2, thetaBw);

    S = S + exp(-1j .* k3 .* (R1 + R2)) ./ R1 ./ R2 ...
        .* antennaPatternGaussian(0.5*pi - theta1, thetaBw) ...
        .* antennaPatternGaussian(0.5*pi - theta2, thetaBw);
end

end

