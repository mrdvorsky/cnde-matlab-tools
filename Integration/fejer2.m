function [nodes, weights, errorWeights] = fejer2(N, a, b, options)
%FEJER2 Generate Fejer Type II weights and nodes for closed interval integration.
% This function generates the weights and nodes required to compute a
% definite integral over a closed interval. The weights and nodes are
% defined using the Fejer Type II Quadrature rules. These rules are very
% similar to the Clenshaw-Curtis rules, but do not result in evalution of
% the funtion at the endpoints a and b.
%
% The function outputs "nodes" and "weights" can be used to approximate
% the definite integral of a function f(x)dx over the interval [a,b] by
% computing q = sum(weights .* f(nodes)). This should give approximately
% the same result as "q = integral(f, a, b)", with a higher value of
% N resulting in a better approximation. The error in q can be estimated
% using the output parameter errorWeights using the formula 
% "qErr = sum(errorWeights .* f(nodes))".
%
% If f(x) is a polynomial with degree less than N, the result will
% be exact.
%
% A weighting function w(x) ("WeightingFunction") can be optionally
% supplied such that the integral "q = sum(weights .* f(nodes))"
% corresponds to the integral of f(x)w(x)dx over the closed interval [a,b].
% In this case, the convergence depend only on the behavior of  f(x),
% regardless of the behavior of w(x). The input "WeightingFunction" should
% be a function handle that accepts an array of scalar inputs and returns
% an array of scalar outputs. The default value is effectively w(x) = 1.
%
% Alternatively, the sinusoidal "moments" of the weighting function "M_k"
% (i.e., 
%   "M_k = integral(@(x) w(0.5*(b - a) .* cos(x) + 0.5*(a + b)) ...
%                       .* sin(k*x), 0, pi)"
% ) 
% can be specified directly, which is useful if these integrals are known
% analytically. The "WeightingMoments" arguments should contain the vector
% of moments "M_k", where "k = 1:N".
%
% Example Usage:
%   [nodes, weights] = fejer2(N, a, b);
%   [nodes, weights, errorWeights] = fejer2(N, a, b, ...
%                       WeightingFunction=@(x) exp(-x));
%   q = sum(fun(nodes) .* weights, 1);
%   qErr = sum(fun(nodes) .* errorWeights, 1);
%
% Inputs:
%   N - Scalar number of nodes to calculate.
%   a - Scalar integration lower bound. Must be real and finite.
%   b - Scalar integration upper bound. Must be real and finite.
%
% Outputs:
%   nodes - Column vector of coordinates at which to evaluate function.
%   weights - Column vector of weights to perform weighted sum.
%   errorWeights - Column vector of weights to estimate integration error.
%
% Named Arguments:
%   WeightingFunction (@(x) 1) - Weighting function for the integral. See
%       above. Must accept an array of scalars and return the same.
%   WeightingMoments - Moments M_k, where k = 1:N of the weighting
%       function, see above. Specify either this or "WeightingFunction".
%
% Author: Matt Dvorsky

arguments
    N(1, 1) {mustBeInteger, mustBePositive};
    a(1, 1) {mustBeReal, mustBeFinite};
    b(1, 1) {mustBeReal, mustBeFinite};

    options.WeightingFunction(1, 1);
    options.WeightingMoments(:, 1);
end

%% Check Inputs
newN = (2*round(0.5*(max(N, 2) - 1)) + 1);
if (nargout == 3) && (N ~= newN)
    N = newN;
    warning("Fejer II rule must be of odd order greater than 1 when " + ...
        "the error weights are computed. Rounding to " + ...
        "the nearest odd integer (%d).", N);
end

if isfield(options, "WeightingMoments")
    if numel(options.WeightingMoments) ~= N
        error("'WeightingMoments' argument must be a vector " + ...
            "with size N (%d).", N);
    end
end

%% Calculate Moments
n(:, 1) = 1:N;
if ~isfield(options, "WeightingMoments")
    options.WeightingMoments = (1 - (-1).^n) ./ n;
    if isfield(options, "WeightingFunction")
        for kk = 1:length(options.WeightingMoments)
            options.WeightingMoments(kk) = integral(...
                @(x) options.WeightingFunction(...
                0.5*(b - a) .* cos(x) + 0.5*(a + b)) ...
                .* sin((kk)*x), 0, pi);
        end
    end
end

%% Calculate Weights
momentsDST = 0.5j * fft([0; options.WeightingMoments; ...
    0; -flip(options.WeightingMoments)]);

theta(:, 1) = pi * n ./ (N + 1);
weights(:, 1) = 2 * sin(theta) .* momentsDST(2:N + 1) ./ (N + 1);

%% Calculate Nodes
nodes(:, 1) = cos(theta);

%% Change Interval
weights = 0.5*(b - a) .* weights;
nodes = 0.5*(b - a) .* nodes + 0.5*(a + b);

%% Compute Error Estimate Weights
if nargout == 3
    [~, weightsReducedOrder] = fejer2(floor(0.5*(N - 1)), a, b, ...
        WeightingMoments=options.WeightingMoments(1:floor(0.5*(N - 1))));
    
    errorWeights = weights;
    errorWeights(2:2:end) = errorWeights(2:2:end) - weightsReducedOrder;
end

end

