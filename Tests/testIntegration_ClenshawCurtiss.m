% Author: Matt Dvorsky

%% Clear Workspace
clc;
clear;
close all;

%% Inputs
w = @(x) besselj(0, 100*x.^2) .* exp(-0.1*x);
f = @(x) polyval([100, -10, -10, -1, 1, 27, 1], x);

N = 8;
a = 0;
b = 2;

g = @(x) w(x) .* f(x);

%% Compute Integral Adaptive
intAdaptive = integral(g, a, b)

%% Compute Integral With Clenshaw Curtiss
[nodes, weights] = clenshawCurtis(N, a, b);
intCC = sum(weights .* g(nodes))

%% Compute Weighted Integral With Clenshaw Curtiss
[nodes, weights] = clenshawCurtis(N, a, b, WeightingFunction=w);
intWeightedCC = sum(weights .* f(nodes))

errWeightedCC = abs(intAdaptive - intWeightedCC)

%% Compute Integral Estimation Error
% [~, ~, errorWeights] = clenshawCurtis(N, a, b, WeightingFunction=w);



