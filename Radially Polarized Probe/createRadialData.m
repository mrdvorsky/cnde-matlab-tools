function [ S ] = createRadialData( X, Y, Z, gamN, gamP, phi0 )
%CREATERADIALDATA Create Radial Antenna SAR Data for a point target
%   Point target is at 0, 0, Z, and has parameters gamN, gamP, phi0.
%   The units of X,Y,Z are wavelengths. Phi0 is angle of target relative
%   to the X-axis

[phi, theta0, R] = cart2sph(X, Y, Z);
S = (gamN + gamP .* cos(phi - phi0).^2) .* exp(-2j .* pi .* R) ./ R.^2;

end

