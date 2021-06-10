function [ nodes, weights ] = clenshawCurtis( orderN, a, b, w )
%CLENSHAWCURTIS Generate integration weights and nodes for closed interval
%   This function generates the weights and nodes required to compute a
%   definite integral over a closed interval. The weights and nodes are
%   defined using the Clenshaw-Curtis Quadrature rules.
%   
%   The function outputs "nodes" and "weights" can be used to approximate
%   the definite integral of a function f(x)dx over the interval [a,b] by
%   computing I = sum(weights .* f(nodes)). This should give approximately
%   the same result as I = integral(f, a, b), with a higher value of
%   orderN resulting in a better approximation. The parameter orderN is
%   the number of points at which to evaluate f(x). If f(x) is a polynomial
%   with degree less than or equal to orderN, the result will be exact.
%   The inputs "a" and "b" must be real, finite values.
%
%   A weighting function "w" can be optionally supplied such that the
%   integral I = sum(weights .* f(nodes)) corresponds to the integral of
%   f(x)w(x)dx over the closed interval [a,b]. In this case, the value I
%   will be exact f(x) is a polynomial with degree less than orderN,
%   regardless of w(x). The input "w" should be a function handle that
%   accepts a scalar input and returns a scalar output. The default value
%   of "w" is effectively w(x) = 1.

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

