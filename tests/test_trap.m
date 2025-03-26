clc;
clear;
close all;

%% Inputs
fPeriodic = @(x) polyval([1, 1, 1, 1, 1], cos(x * pi));
fNonperiodic = @(x) polyval([1, 1, 1], x);

N = 6;

%% Integrate
Ip1 = integral(@(x) fPeriodic(x), -1, 1);
In1 = integral(@(x) fNonperiodic(x), -1, 1);

[x2, x2_weights, x2_error] = trap(N, -1, 1);
Ip2 = sum(fPeriodic(x2) .* x2_weights);
In2 = sum(fNonperiodic(x2) .* x2_weights);

err2p = db(Ip1 - Ip2)
err2n = db(In1 - In2)
errEst2p = db(sum(fPeriodic(x2) .* x2_error))
errEst2n = db(sum(fNonperiodic(x2) .* x2_error))







