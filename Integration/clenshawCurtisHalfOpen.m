function [nodes, weights] = clenshawCurtisHalfOpen(orderN, L, options)
%CLENSHAWCURTISHALFOPEN Generate Clenshaw-Curtiss weights and nodes for half-open interval.
% This function generates the weights and nodes required to compute a
% definite integral over a half-open interval. The weights and nodes are
% defined using the Clenshaw-Curtis Quadrature rules.
%
% The function outputs "nodes" and "weights" can be used to approximate
% the definite integral of a function f(x)dx over the interval [0,inf) by
% computing q = sum(weights .* f(nodes)). This should give approximately
% the same result as q = integral(f, 0, inf), with a higher value of
% orderN resulting in a better approximation.

% The parameter L is a scaling factor such that the integral computed is
% actually I = L*integral(f(L*x), 0, inf). Changing the value of L can
% change the convergence speed, and should be chosen based on the
% function being integrated. The default value of L is 1.
%
% A weighting function "w" can be optionally supplied such that the
% integral 1 = sum(weights .* f(nodes)) corresponds to the integral of
% f(x)w(x)dx over the closed interval [0,inf). In this case, the accuracy
% of q will be independent of the properties of w(x). The input "w" should
% be a function handle that accepts a scalar input and returns a scalar
% output. The default value of "w" is effectively w(x) = 1. The input "w"
% is specified using the WeightingFunction named argument.
%
% Example Usage:
%   [nodes, weights] = clenshawCurtis(N, a, b);
%   [nodes, weights] = clenshawCurtis(N, a, b, WeightingFunction=fun);
%   [nodes, weights] = clenshawCurtis(N, a, b, ComputeErrorWeights=false);
%   q = sum(fun(nodes) .* weights, 1);
%
% Inputs:
%   orderN - Scalar number of nodes to calculate.
%   L - Scaling factor when transforming [-1, 1] to [0, inf). Must be
%       finite. Modifying this value will change convergence properties.
% Outputs:
%   nodes - Column vector of coordinates at which to evaluate function.
%   weights - Column vector of weights to perform weighted sum.
%   errorWeights - Column vector of weights to estimate integration error.
% Named Options:
%   WeightingFunction - Optional weighting function w(x). See above.
%
% Author: Matt Dvorsky

arguments
    orderN(1, 1) {mustBeInteger, mustBePositive} = 10;
    L(1, 1) {mustBeReal, mustBeFinite} = 1;
    options.WeightingFunction;
end

%% Calculate Moments
% Round orderN up to nearest even integer
N = 2*ceil(0.5*orderN);

n(:, 1) = 0:N;
if isfield(options, "WeightingFunction")
    moments = 0*n;
    for ii = 1:length(moments)
        moments(ii) = integral(...
            @(x) options.WeightingFunction(L * cot(0.5*x).^2) ...
            .* sin(x) .* cos((ii - 1)*x), 0, pi);
    end
else
    moments = 2 ./ (1 - n.^2);
    moments(2:2:end) = 0;
end

%% Calculate Weights using DCT Type 1
% Use even ifft to calculate DCT-1.
weights = real(ifft([moments; moments(end - 1:-1:2)]));
weights = weights(1:N + 1);
weights(2:end - 1) = 2*weights(2:end - 1);

%% Calculate Nodes and Adjust Weights for Half Open Interval
theta(:, 1) = (1:N) * (pi/N);
nodes(:, 1) = L * cot(0.5*theta).^2;

weights = (2*L) * weights(2:end) ./ (1 - cos(theta)).^2;

end

