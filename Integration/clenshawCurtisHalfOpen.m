function [ nodes, weights ] = clenshawCurtisHalfOpen( orderN, L, w )
%CLENSHAWCURTIS Summary of this function goes here
%   Detailed explanation goes here

%% Check Input
if nargin < 2
    L = 1;
end
if nargin < 1
    orderN = 10;
end

% Round orderN up to nearest even integer
N = 2*ceil(0.5*orderN);

%% Calculate Indices
n(:, 1) = 0:N;
if nargin < 3
    d = 2 ./ (1 - n.^2);
    d(2:2:end) = 0;
else
    d = 0*n;
    for ii = 1:length(d)
        d(ii) = integral(...
            @(x) w(L * cot(0.5*x).^2) ...
            .* sin(x) .* cos((ii - 1)*x), 0, pi);
    end
end

%% Calculate Weights using DCT Type 1
% Use even ifft to calculate DCT-1.
weights = real(ifft([d; d(end - 1:-1:2)]));
weights = weights(1:N + 1);
weights(2:end - 1) = 2*weights(2:end - 1);

%% Calculate Nodes and Adjust Weights for Half Open Interval
theta(:, 1) = (1:N) * (pi/N);
nodes(:, 1) = L * cot(0.5*theta).^2;

weights = (2*L) * weights(2:end) ./ (1 - cos(theta)).^2;

%% Change Interval
% weights = 0.5*(b - a) .* weights;
% nodes = 0.5*(b - a) .* nodes + 0.5*(a + b);

end

