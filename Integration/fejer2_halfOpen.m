function [nodes, weights, varargout] = fejer2_halfOpen(N, L, a, options)
%FEJER2_HALFOPEN Generate Fejer Type II weights and nodes for half-open [a,inf) integration interval.
% This function generates the weights and nodes required to compute a
% definite integral over a half-open interval (i.e., [a,inf)). The weights
% and nodes are defined using the Fejer Type II Quadrature rules. These
% rules do not result in function evalution at the endpoints 0 or inf. The
% input "L" is a scale factor input that affects the convergence of the
% integral.
%
% The function outputs "nodes" and "weights" can be used to approximate
% the definite integral of a function f(x)dx over the interval [a,inf) by
% computing "q = sum(weights .* f(nodes))". This should give approximately
% the same result as "q = integral(f, a, inf)", with a higher value of
% N resulting in a better approximation. The error in q can be estimated
% using the output parameter errorWeights using the formula
% "qErr = sum(errorWeights .* f(nodes))".
%
% A weighting function w(x) ("WeightingFunction") can be optionally
% supplied such that the integral "q = sum(weights .* f(nodes))"
% corresponds to the integral of f(x)w(x)dx over the half-open interval
% [a,inf). In this case, the convergence will only depend on the properties
% of f(x), regardless of w(x). The input "WeightingFunction" should
% be a function handle that accepts an array of scalar inputs and returns
% an array of scalar outputs. The default value is effectively w(x) = 1.
%
% **Note: the integral over w(x) must converge, and the limit of f(x) as
% x approaches inf must be finite, else these rules may give accurate
% results.
%
% Alternatively, the sinusoidal "moments" of the weighting function "M_k"
% (i.e., 
%   "M_k = integral(@(x) (2*L) * w(a + L * cot(0.5*x).^2) ...
%                           .* sin(k*x) ./ (1 - cos(x)).^2, 0, pi)"
% )
% can be specified directly, which is useful if these integrals are known
% analytically. The "WeightingMoments" arguments should contain the vector
% of moments "M_k", where "k = 1:N".
%
% Example Usage:
%   [nodes, weights] = fejer2_halfOpen(N, L);   % a = 0;
%   [nodes, weights, errorWeights] = fejer2_halfOpen(N, L, a, ...
%                       WeightingFunction=@(x) exp(-x));
%   q = sum(fun(nodes) .* weights, 1);
%   qErr = sum(fun(nodes) .* errorWeights, 1);
%
% Inputs:
%   N - Scalar number of nodes to calculate.
%   L - Scale factor for integral that affects convergence.
%   a - Scalar integration lower bound. Must be real and finite.
%
% Outputs:
%   nodes - Column vector of coordinates at which to evaluate function.
%   weights - Column vector of weights to perform weighted sum.
%   errorWeights - Column vector of weights to estimate integration error.
%
% Named Arguments:
%   WeightingFunction (@(x) 1) - Weighting function for the integral. See
%       above. Must accept an array of scalars and return the same.
%   WeightingMoments - Moments "M_k", where "k = 1:N" of the weighting
%       function, see above. Specify either this or "WeightingFunction".
%
% Author: Matt Dvorsky

arguments
    N(1, 1) {mustBeInteger, mustBePositive};
    L(1, 1) {mustBePositive};
    a(1, 1) {mustBeReal, mustBeFinite} = 0;

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

%% Calculate Weights and Nodes with Weighting Function Provided
if isfield(options, "WeightingFunction")
    % Calculate weights and nodes over [-1,1].
    [x, weights, varargout{1:nargout - 2}] = fejer2(N, -1, 1, ...
        WeightingFunction=@(x) (2*L) * options.WeightingFunction(...
        a + L .* (1 + x) ./ (1 - x)) ...
        ./ (1 - x).^2);

    % Adjust for Half-Open interval.
    nodes = a + L .* (1 + x) ./ (1 - x);

    return;
end

%% Calculate Weights and Nodes with Weighting Moments Provided
if isfield(options, "WeightingMoments")
    % Calculate weights and nodes over [-1,1].
    [x, weights, varargout{1:nargout - 2}] = fejer2(N, -1, 1, ...
        WeightingMoments=options.WeightingMoments);

    % Adjust for Half-Open interval.
    nodes = a + L .* (1 + x) ./ (1 - x);

    return;
end

%% Calculate Weights and Nodes with No Weighting Function
% Calculate weights and nodes over [-1,1].
[x, x_weights, varargout{1:nargout - 2}] = fejer2(N, -1, 1);

% Adjust for Half-Open interval.
nodes = a + L .* (1 + x) ./ (1 - x);
weights = (2*L) .* x_weights ./ (1 - x).^2;

if nargout >= 3
    varargout{3} = (2*L) .* varargout{3} ./ (1 - x).^2;
end

end

