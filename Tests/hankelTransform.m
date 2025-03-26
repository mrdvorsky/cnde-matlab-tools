function [F, k] = hankelTransform(fun, kMax, N, options)
%FHT Evaluates Hankel transform of the input function using fft.
% Evaluates the Hankel transform of the input function handle "fun" using
% the fast Hankel transform algorithm. Should be roughly equivalent to
% evaluating the continuous Hankel transform of "fun".
%
% The function handle input can be an array-valued function, just specify
% any unused dimension using the "Dimension" named argument. The function
% handle will be called as "fun(rho)", where "rho" is a vector along the
% specified dimension. The output "F" will be the Hankel transform evaluted
% at the points specified by the vector "k". The size of "F" will be the
% same as "fun(1) + rho".
%
% Based on: https://opg.optica.org/ol/fulltext.cfm?uri=ol-1-1-13&id=6574
%
% Author: Matt Dvorsky

arguments
    fun(1, 1);
    kMax(1, 1) {mustBePositive} = 1;
    N(1, 1) {mustBePositive, mustBeInteger} = 1024;
    
    options.Dimension {mustBeValidDimension(options.Dimension, AllowVector=0)} = 1;
    options.hankelTransformOrder(1, 1) {mustBeNonnegative, mustBeInteger} = 0;
    options.kPointsPerCycle(1, 1) {mustBePositive, mustBeInteger} = 4;
    options.rPointsPerCycle(1, 1) {mustBePositive, mustBeInteger} = 4;
end

%% Compute Transform Parameters
Kr_over_Kk = options.rPointsPerCycle ./ options.kPointsPerCycle;
alpha = lambertw(N .* Kr_over_Kk) ./ N;
r0 = 1 ./ (options.rPointsPerCycle .* kMax);
k0 = alpha ./ (Kr_over_Kk .* options.rPointsPerCycle .* r0);

%% Compute Transform Coordinates
n1 = reshape(0:(1*N - 1), [ones(1, options.Dimension - 1), 1*N, 1]);
n2 = reshape(0:(2*N - 1), [ones(1, options.Dimension - 1), 2*N, 1]);

r = r0 .* exp(alpha .* n1);
k = k0 .* exp(alpha .* n1);
rk = r0 .* k0 .* exp(alpha .* n2);

%% Compute Hankel Transform
% Sample original function
fHat = r .* fun(r);
jHat = (2*pi*alpha) .* rk .* besselj(0, (2*pi) .* rk);

% Convolve
FHat = fft(fft(fHat, numel(jHat), options.Dimension) ...
    .* ifft(jHat, [], options.Dimension), ...
    [], options.Dimension);

%% Crop and Scale Output
outputInds = repmat({':'}, 1, max(ndims(FHat)), options.Dimension);
outputInds{options.Dimension} = 1:N;
F = FHat(outputInds{:}) ./ k;

end

