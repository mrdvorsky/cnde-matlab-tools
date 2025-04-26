classdef tester_besseljZeros < matlab.unittest.TestCase
    % Unit tests for "besseljZeros" function.
    %
    % Author: Matt Dvorsky

    properties
        tolVal = 1e-13;

        v0 = [0, 1, 2, 10, 0.5, 1000, 10000];
        jvn0 = [...
            2.404825557695773, ...
            3.831705970207512, ...
            5.135622301840684, ...
            14.47550068655454, ...
            pi, ...
            1018.660880967908, ...
            10040.02902849852 ...
            ];
    end

    methods (Test)
        %% Basic Functionality Tests
        function test_firstZero(testCase)
            v = testCase.v0(:);
            z0Actual = besseljZeros(v, 1);
            z0Exp = testCase.jvn0(:);

            testCase.verifyEqual(z0Actual, z0Exp, ...
                RelTol=testCase.tolVal, AbsTol=testCase.tolVal);

            % Verify that they are zeros.
            besVal = besselj(v, z0Actual);
            testCase.verifyEqual(besVal, 0*v, ...
                RelTol=testCase.tolVal, AbsTol=testCase.tolVal);
        end

        %% Assert Interleaving Property of Bessel Function Zeros
        function test_compare_jvn_interleaving_v0(testCase)
            v = 0;
            n(:, 1) = 1:1000;

            jvn = besseljZeros(v, n);
            jvplus1n = besseljZeros(v + 1, n);

            zerosInOrder = reshape([jvn, jvplus1n].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");

            besselValueAtZero = besselj(v, jvn);
            testCase.verifyEqual(besselValueAtZero, ...
                zeros(size(besselValueAtZero)), ...
                AbsTol=testCase.tolVal);
        end

        function test_compare_jvn_interleaving_v1(testCase)
            v = 1;
            n(:, 1) = 1:1000;

            jvn = besseljZeros(v, n);
            jvplus1n = besseljZeros(v + 1, n);

            zerosInOrder = reshape([jvn, jvplus1n].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");

            besselValueAtZero = besselj(v, jvn);
            testCase.verifyEqual(besselValueAtZero, ...
                zeros(size(besselValueAtZero)), ...
                AbsTol=testCase.tolVal);
        end

        function test_compare_jvn_interleaving_vOneHalf(testCase)
            v = 0.5;
            n(:, 1) = 1:1000;

            jvn = besseljZeros(v, n);
            jvplus1n = besseljZeros(v + 1, n);

            zerosInOrder = reshape([jvn, jvplus1n].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");

            besselValueAtZero = besselj(v, jvn);
            testCase.verifyEqual(besselValueAtZero, ...
                zeros(size(besselValueAtZero)), ...
                AbsTol=testCase.tolVal);
        end

        function test_compare_jvn_interleaving_v10000(testCase)
            v = 10000;
            n(:, 1) = 1:1000;

            jvn = besseljZeros(v, n);
            jvplus1n = besseljZeros(v + 1, n);

            zerosInOrder = reshape([jvn, jvplus1n].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");

            besselValueAtZero = besselj(v, jvn);
            testCase.verifyEqual(besselValueAtZero, ...
                zeros(size(besselValueAtZero)), ...
                AbsTol=testCase.tolVal);
        end

        function test_compare_jvn_interleaving_vVariable(testCase)
            n(:, 1) = 1:20;
            for v = 0.5:0.5:100
                jvn = besseljZeros(v, n);
                jvplus1n = besseljZeros(v + 1, n);

                zerosInOrder = reshape([jvn, jvplus1n].', [], 1);
                testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                    sprintf("Bessel function zeros (for v = %g) " + ...
                    "must interlace properly.", v));

                besselValueAtZero = besselj(v, jvn);
                testCase.verifyEqual(besselValueAtZero, ...
                    zeros(size(besselValueAtZero)), ...
                    AbsTol=testCase.tolVal);
            end
        end

        %% Broadcasting Tests
        function test_broadcasting1(testCase)
            v = rand(10, 1);
            n = round(10*rand(1, 5)) + 1;

            jvn = besseljZeros(v, n);
            testCase.verifySize(jvn, [numel(v), numel(n)]);
        end

        function test_broadcasting2(testCase)
            v = rand(3, 1, 4);
            n = round(10*rand(1, 5, 4)) + 1;

            jvn = besseljZeros(v, n);
            testCase.verifySize(jvn, [3, 5, 4]);
        end

        %% Edge Case Tests
        function testEdge_decreasingSpacing_vGreaterThanOneHalf(testCase)
            v = 0.51;
            n(:, 1) = 1:1000;

            jvn = besseljZeros(v, n);
            testCase.verifyLessThanOrEqual(diff(jvn, 2), 0, ...
                "Spacing of zeros must be monotonically decreasing.");
        end

        function testEdge_increasingSpacing_vLessThanOneHalf(testCase)
            v = 0.49;
            n(:, 1) = 1:1000;

            jvn = besseljZeros(v, n);
            testCase.verifyGreaterThanOrEqual(diff(jvn, 2), 0, ...
                "Spacing of zeros must be monotonically increasing.");
        end

        function testEdge_decreasingSpacing_vLarge(testCase)
            v = 1000;
            n(:, 1) = 1:1000;

            jvn = besseljZeros(v, n);
            testCase.verifyLessThanOrEqual(diff(jvn, 2), 0, ...
                "Spacing of zeros must be monotonically decreasing.");
        end

        function testEdge_increasingSpacing_vZero(testCase)
            v = 0;
            n(:, 1) = 1:1000;

            jvn = besseljZeros(v, n);
            testCase.verifyGreaterThanOrEqual(diff(jvn, 2), 0, ...
                "Spacing of zeros must be monotonically increasing.");
        end

        %% Error Condition Tests
        function testError_broadcastingMismatch(testCase)
            v = rand(10, 1);
            n = round(10*rand(9, 5)) + 1;

            testCase.verifyError(@() besseljZeros(v, n), ...
                "MATLAB:sizeDimensionsMustMatch");
        end

        function testError_nonPositiveN(testCase)
            testCase.verifyError(@() besseljZeros(0, 0), ...
                "MATLAB:validators:mustBePositive");
            testCase.verifyError(@() besseljZeros(0, -1), ...
                "MATLAB:validators:mustBePositive");
        end

        function testError_nonIntegerN(testCase)
            testCase.verifyError(...
                @() besseljZeros(0, 1.5), ...
                "MATLAB:validators:mustBeInteger");
        end

        function testError_negativeNu(testCase)
            testCase.verifyError(...
                @() besseljZeros(-0.1, 1), ...
                "MATLAB:validators:mustBeNonnegative");
        end

        function testError_nonfiniteNu(testCase)
            testCase.verifyError(...
                @() besseljZeros(inf, 1), ...
                "MATLAB:validators:mustBeFinite");
        end
    end
end