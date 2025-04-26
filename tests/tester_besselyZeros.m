classdef tester_besselyZeros < matlab.unittest.TestCase
    % Unit tests for "besselyZeros" function.
    %
    % Author: Matt Dvorsky

    properties
        tolVal = 1e-13;

        v0 = [0, 1, 2, 10, 0.5, 1000, 10000];
        yvn0 = [...
            0.8935769662791675, ...
            2.197141326031017, ...
            3.384241767149593, ...
            12.12892770441544, ...
            0.5*pi, ...
            1009.341814997842, ...
            10020.08229939202 ...
            ];
    end

    methods (Test)
        %% Basic Functionality Tests
        function test_firstZero(testCase)
            v = testCase.v0(:);
            z0Actual = besselyZeros(v, 1);
            z0Exp = testCase.yvn0(:);

            testCase.verifyEqual(z0Actual, z0Exp, ...
                RelTol=testCase.tolVal, AbsTol=testCase.tolVal);

            % Verify that they are zeros.
            besVal = bessely(v, z0Actual);
            testCase.verifyEqual(besVal, 0*v, ...
                RelTol=testCase.tolVal, AbsTol=testCase.tolVal);
        end

        %% Assert Interleaving Property of Bessel Function Zeros
        function test_compare_yvn_interleaving_v0(testCase)
            v = 0;
            n(:, 1) = 1:1000;

            yvn = besselyZeros(v, n);
            yvplus1m = besselyZeros(v + 1, n);

            zerosInOrder = reshape([yvn, yvplus1m].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");

            besselValueAtZero = bessely(v, yvn);
            testCase.verifyEqual(besselValueAtZero, ...
                zeros(size(besselValueAtZero)), ...
                AbsTol=testCase.tolVal);
        end

        function test_compare_yvn_interleaving_v1(testCase)
            v = 1;
            n(:, 1) = 1:1000;

            yvn = besselyZeros(v, n);
            yvplus1m = besselyZeros(v + 1, n);

            zerosInOrder = reshape([yvn, yvplus1m].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");

            besselValueAtZero = bessely(v, yvn);
            testCase.verifyEqual(besselValueAtZero, ...
                zeros(size(besselValueAtZero)), ...
                AbsTol=testCase.tolVal);
        end

        function test_compare_yvn_interleaving_vOneHalf(testCase)
            v = 0.5;
            n(:, 1) = 1:1000;

            yvn = besselyZeros(v, n);
            yvplus1m = besselyZeros(v + 1, n);

            zerosInOrder = reshape([yvn, yvplus1m].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");

            besselValueAtZero = bessely(v, yvn);
            testCase.verifyEqual(besselValueAtZero, ...
                zeros(size(besselValueAtZero)), ...
                AbsTol=testCase.tolVal);
        end

        function test_compare_yvn_interleaving_v10000(testCase)
            v = 10000;
            n(:, 1) = 1:1000;

            yvn = besselyZeros(v, n);
            yvplus1m = besselyZeros(v + 1, n);

            zerosInOrder = reshape([yvn, yvplus1m].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");

            besselValueAtZero = bessely(v, yvn);
            testCase.verifyEqual(besselValueAtZero, ...
                zeros(size(besselValueAtZero)), ...
                AbsTol=testCase.tolVal);
        end

        function test_compare_yvn_interleaving_vVariable(testCase)
            n(:, 1) = 1:20;
            for v = 0.5:0.5:100
                yvn = besselyZeros(v, n);
                yvplus1m = besselyZeros(v + 1, n);

                zerosInOrder = reshape([yvn, yvplus1m].', [], 1);
                testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                    sprintf("Bessel function zeros (for v = %g) " + ...
                    "must interlace properly.", v));

                besselValueAtZero = bessely(v, yvn);
                testCase.verifyEqual(besselValueAtZero, ...
                    zeros(size(besselValueAtZero)), ...
                    AbsTol=testCase.tolVal);
            end
        end

        %% Broadcasting Tests
        function test_broadcasting1(testCase)
            v = rand(10, 1);
            n = round(10*rand(1, 5)) + 1;

            yvn = besselyZeros(v, n);
            testCase.verifySize(yvn, [numel(v), numel(n)]);
        end

        function test_broadcasting2(testCase)
            v = rand(3, 1, 4);
            n = round(10*rand(1, 5, 4)) + 1;

            yvn = besselyZeros(v, n);
            testCase.verifySize(yvn, [3, 5, 4]);
        end

        %% Edge Case Tests
        function testEdge_decreasingSpacing_vGreaterThanOneHalf(testCase)
            v = 0.51;
            n(:, 1) = 1:1000;

            yvn = besselyZeros(v, n);
            testCase.verifyLessThanOrEqual(diff(yvn, 2), 0, ...
                "Spacing of zeros must be monotonically decreasing.");
        end

        function testEdge_increasingSpacing_vLessThanOneHalf(testCase)
            v = 0.49;
            n(:, 1) = 1:1000;

            yvn = besselyZeros(v, n);
            testCase.verifyGreaterThanOrEqual(diff(yvn, 2), 0, ...
                "Spacing of zeros must be monotonically increasing.");
        end

        function testEdge_decreasingSpacing_vLarge(testCase)
            v = 1000;
            n(:, 1) = 1:1000;

            yvn = besselyZeros(v, n);
            testCase.verifyLessThanOrEqual(diff(yvn, 2), 0, ...
                "Spacing of zeros must be monotonically decreasing.");
        end

        function testEdge_increasingSpacing_vZero(testCase)
            v = 0;
            n(:, 1) = 1:1000;

            yvn = besselyZeros(v, n);
            testCase.verifyGreaterThanOrEqual(diff(yvn, 2), 0, ...
                "Spacing of zeros must be monotonically increasing.");
        end

        %% Error Condition Tests
        function testError_broadcastingMismatch(testCase)
            v = rand(10, 1);
            n = round(10*rand(9, 5)) + 1;

            testCase.verifyError(@() besselyZeros(v, n), ...
                "MATLAB:sizeDimensionsMustMatch");
        end

        function testError_nonPositiveN(testCase)
            testCase.verifyError(@() besselyZeros(0, 0), ...
                "MATLAB:validators:mustBePositive");
            testCase.verifyError(@() besselyZeros(0, -1), ...
                "MATLAB:validators:mustBePositive");
        end

        function testError_nonIntegerN(testCase)
            testCase.verifyError(...
                @() besselyZeros(0, 1.5), ...
                "MATLAB:validators:mustBeInteger");
        end

        function testError_negativeNu(testCase)
            testCase.verifyError(...
                @() besselyZeros(-0.1, 1), ...
                "MATLAB:validators:mustBeNonnegative");
        end

        function testError_nonfiniteNu(testCase)
            testCase.verifyError(...
                @() besselyZeros(inf, 1), ...
                "MATLAB:validators:mustBeFinite");
        end
    end
end