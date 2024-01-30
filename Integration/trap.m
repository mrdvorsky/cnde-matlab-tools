function [nodes, weights, errorWeights] = trap(N, a, b)
%TRAP Generate trapezoidal midpoint rule weights and nodes for integration.
% This function generates the weights and nodes required to compute a
% definite integral over a closed interval. The weights and nodes are
% defined using the trapezoidal midpoint rules, which are only accurate if
% used over a period of a smooth, periodic function. These do not result in
% evalution of the funtion at the endpoints a and b.
%
% **Note**: Only use this function when integrating smooth, periodic
% functions over an integer number of periods. Otherwise, the "fejer2"
% function is often better, and can be used with arbitrary weighting
% functions.
%
% The function outputs "nodes" and "weights" can be used to approximate
% the definite integral of a function f(x)dx over the interval [a,b] by
% computing q = sum(weights .* f(nodes)). This should give approximately
% the same result as "q = integral(f, a, b)", with a higher value of
% N resulting in a better approximation. The error in q can be estimated
% using the output parameter errorWeights using the formula 
% "qErr = sum(errorWeights .* f(nodes))".
%
% If f(x) is a trig polynomial (i.e., a product of sin and cos terms) with
% degree less than N, the result will be exact, assuming the interval 
% [a,b] is over exactly one period.
%
% Example Usage:
%   [nodes, weights] = trap(N, a, b);
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
% Author: Matt Dvorsky

arguments
    N(1, 1) {mustBeInteger, mustBePositive};
    a(1, 1) {mustBeReal, mustBeFinite};
    b(1, 1) {mustBeReal, mustBeFinite};
end

%% Check Inputs
newN = 2*round(0.5*(max(N, 4)));
if (nargout == 3) && (N ~= newN)
    N = newN;
    warning("Trapezoidal rule must be of even order greater than 2 when " + ...
        "the error weights are computed. Rounding to " + ...
        "the nearest even integer (%d).", N);
end

%% Calculate Weight and Nodes
weights(:, 1) = zeros(N, 1) + 2 ./ N;
nodes(:, 1) = 2 * ((1:N) - 0.5) ./ N - 1;

%% Change Interval
weights = 0.5*(b - a) .* weights;
nodes = 0.5*(b - a) .* nodes + 0.5*(a + b);

%% Compute Error Estimate Weights
if nargout == 3
    [~, weightsReducedOrder] = trap(floor(0.5*N), a, b);
    
    errorWeights = weights;
    errorWeights(2:2:end) = errorWeights(2:2:end) - weightsReducedOrder;
end

end

