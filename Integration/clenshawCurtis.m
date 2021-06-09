function [ nodes, weights ] = clenshawCurtis( orderN, a, b, w )
%CLENSHAWCURTIS Summary of this function goes here
%   Detailed explanation goes here

%% Check Input
if nargin < 3
    b = 1;
end
if nargin < 2
    a = -1;
end
if nargin < 1
    orderN = 10;
end

% Round orderN up to nearest even integer
N = 2*ceil(0.5*orderN);

%% Calculate Indices
n(:, 1) = 0:N;
if nargin < 4
    d = 2 ./ (1 - n.^2);
    d(2:2:end) = 0;
else
    d = 0*n;
    for ii = 1:length(d)
        d(ii) = integral(...
            @(x) w(0.5*(b - a) .* cos(x) + 0.5*(a + b)) ...
            .* sin(x) .* cos((ii - 1)*x), 0, pi);
    end
end

%% Calculate Weights using DCT Type 1
% Use even ifft to calculate DCT-1.
weights = real(ifft([d; d(end - 1:-1:2)]));
weights = weights(1:N + 1);
weights(2:end - 1) = 2*weights(2:end - 1);

%% Calculate Nodes
nodes(:, 1) = cos((0:N) * (pi/N));

%% Change Interval
weights = 0.5*(b - a) .* weights;
nodes = 0.5*(b - a) .* nodes + 0.5*(a + b);

end

