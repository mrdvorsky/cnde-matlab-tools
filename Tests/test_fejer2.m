clc;
clear;
close all;

%% Inputs
f = @(x) polyval([1, 1, 1], x);
w = @(x) exp(-11.0123j * x);

N = 7;

%% Integrate
I1 = integral(@(x) f(x) .* w(x), -1, 1);

[x2, x2_weights] = fejer2(N, -1, 1);
I2 = sum(f(x2) .* w(x2) .* x2_weights);

[x3, x3_weights, erw] = fejer2(N, -1, 1, WeightingFunction=w);
I3 = sum(f(x3) .* x3_weights);

err2 = db(I1 - I2)
err3 = db(I1 - I3)
errEst3 = db(sum(f(x3) .* erw))







