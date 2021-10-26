clc;
clear;
close all;

%% Inputs
w = @(x) besselj(0, 10*x.^2) .* exp(-1*x.^2)*0 + 1;
f = @(x) polyval([10, -10, -10, -1, 1, 27, 1], x) .* exp(-x);

N = 30;
a = 0;
b = inf;
L = 1;

g = @(x) w(x) .* f(x);

%% Compute Integral Adaptive
intAdaptive = integral(g, a, b)

%% Compute Integral With Clenshaw Curtiss
[nodes, weights] = clenshawCurtisHalfOpen(N, L);
intCC = sum(weights .* g(nodes))

%% Compute Weighted Integral With Clenshaw Curtiss
[nodes, weights] = clenshawCurtisHalfOpen(N, L, WeightingFunction=w);
intWeightedCC = sum(weights .* f(nodes))

errWeightedCC = abs(intAdaptive - intWeightedCC)

%% Compute Integral Estimation Error
% [~, ~, errorWeights] = clenshawCurtis(N, a, b, WeightingFunction=w);



