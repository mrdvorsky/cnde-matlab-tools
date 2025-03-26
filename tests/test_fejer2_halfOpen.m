clc;
clear;
close all;

%% Inputs
f = @(x) polyval([1, 1, 1], x ./ (1 + x.^2));
w = @(x) exp(-1.01*11.0123j * x) .* exp(-0.1 * x);

N = 21;

a = -0;
L = 1;

%% Integrate
I1 = integral(@(x) f(x) .* w(x), a, inf);

[x2, x2_weights] = fejer2_halfOpen(N, L, a);
I2 = sum(f(x2) .* w(x2) .* x2_weights);

[x3, x3_weights] = fejer2_halfOpen(N, L, a, WeightingFunction=w);
I3 = sum(f(x3) .* x3_weights);

for kk = 1:N
    Mk(kk) = integral(@(x) (2*L) * w(a + L * cot(0.5*x).^2) ...
                          .* sin(kk*x) ./ (1 - cos(x)).^2, 0, pi);
end
[x4, x4_weights, x4_error] = fejer2_halfOpen(N, L, a, WeightingMoments=Mk);
I4 = sum(f(x4) .* x4_weights);


err2 = db(I1 - I2)
err3 = db(I1 - I3)
err4 = db(I1 - I4)
errEst4 = db(sum(f(x4) .* x4_error))




