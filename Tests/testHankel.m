clc;
clear;
close all;

%% Inputs
f = @(r) (1 + r.^2).^-1.5;
g = @(k) 2*pi .* exp(-2*pi .* k);

kMax = 5;

%% Compute Parameters
tic;
[F, k] = hankelTransform(f, kMax, 100000, Dimension=1);
toc;

%% Plotting
figure;
plots(k, real(F), "", Linewidth=1.5);
hold on;
plots(k, g(k), "", Linewidth=1.5);
grid on;

figure;
plots(k, real(F) - g(k), "", Linewidth=1.5);
grid on;