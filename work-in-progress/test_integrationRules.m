clc;
clear;
close all;

%% Inputs
deltaX = pi*0.5;
N = 100;

fun = @(x) (besselj(2, x) + 1.1*besselj(2, 1.1*x)) .* (1./(1 + x.^2));
funDer = @(x) imag(fun(x + 1e-15*1j)) * 1e15;

k = 7;

%% Integrate
[x, w] = fejer2(N, 0, deltaX);

numTerms = 2*k + 1;
for kk = 1:numTerms
    terms(kk) = sum(w .* fun(x + (kk-1)*deltaX));
    % terms(kk) = terms(kk) + 1j*sum(w .* funDer(x + (kk-1)*deltaX));
end

int1 = sum(terms)

intA = integral(fun, 0, inf, RelTol=1e-9)

%% Convergence
A_ind = flip(toeplitz(0:k, -(0:k)), 2);
A = terms(A_ind(1:end-1, :) + 2 + k);

A_top = [cumsum(terms(1:k + 1)); A];
A_bot = [ones(1, k + 1); A];

int2 = real(det(A_top / A_bot))

err2 = intA - int2







