function [ nodes, weights ] = clenshawCurtisHalfOpen( orderN, L, w )
%CLENSHAWCURTIS Generate integration weights and nodes for half-open interval
%   This function generates the weights and nodes required to compute a
%   definite integral over a half-open interval. The weights and nodes are
%   defined using the Clenshaw-Curtis Quadrature rules.
%   
%   The function outputs "nodes" and "weights" can be used to approximate
%   the definite integral of a function f(x)dx over the interval [0,inf)
%   by computing I = sum(weights .* f(nodes)). This should give
%   approximately the same result as I = integral(f, 0, inf), with a higher
%   value of orderN resulting in a better approximation. The parameter
%   orderN is the number of points at which to evaluate f(x).
%
%   The parameter L is a scaling factor such that the integral computed is
%   actually I = L*integral(f(L*x), 0, inf). Changing the value of L can
%   change the convergence speed, and should be chosen based on the
%   function being integrated. The default value of L is 1.
%
%   A weighting function "w" can be optionally supplied such that the
%   integral I = sum(weights .* f(nodes)) corresponds to the integral of
%   f(x)w(x)dx over theinterval [0,inf). The input "w" should be a function
%   handle that accepts a scalar input and returns a scalar output. The
%   default value of "w" is effectively w(x) = 1.

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

end

