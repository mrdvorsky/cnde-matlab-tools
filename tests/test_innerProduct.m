% Author: Matt Dvorsky

%% Clear Workspace
clc;
clear;
close all;

%% Inputs
numTrials = 20;
maxDimSize = [5000, 13, 3, 128, 31];
numDims = numel(maxDimSize);
err_cutoff = sqrt(eps);

%% Test
for ii = 1:numTrials
    A_singleton = rand(1, numDims) > 0.5;
    B_singleton = rand(1, numDims) > 0.5;

    AB_size = ceil(maxDimSize .* rand(1, numDims));
    A_size = (~A_singleton).*AB_size + A_singleton;
    B_size = (~B_singleton).*AB_size + B_singleton;

    A = rand(A_size);
    B = rand(B_size);
    dim = find(rand(1, numDims) > 0.5);
    if isempty(dim)
        dim = ceil(numDims * rand(1));
    end

    tic;
    sum1_AB = sum(A .* B, dim);
    sum1_time = toc;

    tic;
    mean1_AB = mean(A .* B, dim);
    mean1_time = toc;

    tic;
    sum2_AB = innerProduct(A, B, dim);
    sum2_time = toc;

    tic;
    mean2_AB = innerProduct(A, B, dim, SummationMode="Mean");
    mean2_time = toc;

    sum_err = abs(mean(sum1_AB - sum2_AB, "all"));
    mean_err = abs(mean(mean1_AB - mean2_AB, "all"));

    fprintf("Trial %d:\n", ii);
    fprintf("A -> [%s]\nB -> [%s]\ndim -> [%s]\n", ...
        join(compose("%d", A_size), ", "), ...
        join(compose("%d", B_size), ", "), ...
        join(compose("%d", dim), ", "));
    fprintf("\tTime (sum):          %.4f\n", sum1_time);
    fprintf("\tTime (innerProduct): %.4f\n", sum2_time);
    fprintf("\tError: %g\n\n", max(sum_err, mean_err));

    if max(sum_err, mean_err) > err_cutoff
        error("Error Too Large.");
    end
end
