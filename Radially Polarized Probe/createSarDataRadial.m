function [ S ] = createSarDataRadial(X, Y, F, x0, y0, z0, theta0, a0, p0, np0)
%CREATESARDATARADIAL Creates radially polarized scan data
%   TODO: Write description

c = 300;
X1(:, 1, 1) = X;
Y2(1, :, 1) = Y;
k3(1, 1, :) = 2 .* pi .* F ./ c;

S = zeros(length(X), length(Y), length(F));
for ii = 1:length(x0)
    [phi, theta, R] = cart2sph(-X1 + x0(ii), -Y2 + y0(ii), -abs(z0(ii)));
    Stmp = exp(-2j .* R .* k3);
    Stmp = Stmp .* (p0(ii) .* cos(a0(ii) - phi).^2 + np0(ii));
    Stmp = Stmp .* radialProbePattern(pi/2 + theta, theta0);
    Stmp = Stmp ./ R.^2;
    
    S = S + Stmp;
end

end

