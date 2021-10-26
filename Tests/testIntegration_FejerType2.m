clc;
clear;
close all;

%% Inputs
f = @(x) log(x);

N = 20;
a = 0;
b = 1;

%% Compute Integral Adaptive
intAdaptive = integral(f, a, b)

%% Compute Integral With Fejer Type II
[nodes, weights] = fejer2(N, a, b);
intFejer = sum(weights .* f(nodes))

%% Compute Integral Estimation Error
[nodes, ~, errorWeights] = fejer2(N, a, b);

intFejerEstErr = abs(sum(errorWeights .* f(nodes)))
intErr = abs(intFejer - intAdaptive)

