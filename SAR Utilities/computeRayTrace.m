function [R, psi_source] = computeRayTrace(x, z, z_source, z_boundaries, er)
%COMPUTERAYTRACE Compute ray tracing paths for multilayered structure.
% Compute ray tracing path lengths and angles for ...
%
% Author: Matt Dvorsky

arguments
    x(:, 1);
    z(1, :);
    z_source(1, 1) {mustBeReal, mustBeFinite};
    z_boundaries(1, :) {mustBeReal, mustBeFinite};
    er(1, :) {mustBeReal, mustBeFinite};
end

%% Check Inputs
if (numel(z_boundaries) + 1) ~= numel(er)
    error("Input 'z_boundaries' must have a number of elements " + ...
        "equal to the size of 'er' minus 1.");
end

if ~issorted(z_boundaries)
    error("Input 'z_boundaries' must be sorted.");
end

%% Calculate Layer Index
indSource = interp1(z_boundaries, 1:numel(z_boundaries), z_source, "next", 1);
if (indSource == 1) && (z_source > z_boundaries(end))
    indSource = numel(z_boundaries) + 1;
end

indZ = interp1(z_boundaries, 1:numel(z_boundaries), z, "next", 1);

%% 


end

