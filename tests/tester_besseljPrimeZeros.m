classdef tester_besseljPrimeZeros < matlab.unittest.TestCase
    % Unit tests for "besseljPrimeZeros" function.
    %
    % Author: Matt Dvorsky

    properties
        tolVal = 1e-13;

        v0 = [0, 1, 2, 10, 0.5, 1000, 10000];
        jpvn0 = [...
            3.831705970207512, ...
            1.841183781340659, ...
            3.05423692822714, ...
            11.77087667495558, ...
            1.165561185207211, ...
            1008.093363320071, ...
            10017.42447436328 ...
            ];
    end

    methods (Test)
        %% Basic Functionality Tests
        function test_firstZero(testCase)
            v = testCase.v0(:);
            z0Actual = besseljPrimeZeros(v, 1);
            z0Exp = testCase.jpvn0(:);

            testCase.verifyEqual(z0Actual, z0Exp, ...
                RelTol=testCase.tolVal, AbsTol=testCase.tolVal);

            % Verify that they are zeros.
            besVal = besseljPrime(v, z0Actual);
            testCase.verifyEqual(besVal, 0*v, ...
                RelTol=testCase.tolVal, AbsTol=testCase.tolVal);
        end

        %% Assert Interleaving Property of Bessel Function Zeros
        function test_compare_jpvn_interleaving_v0(testCase)
            v = 0;
            n(:, 1) = 1:1000;

            jpvn = besseljPrimeZeros(v, n);
            jpvplus1m = besseljPrimeZeros(v + 1, n);

            % For zero order, jpvn should be larger, due to the convention
            % of having the first zero of J0'(x) be non-zero.
            zerosInOrder = reshape([jpvplus1m, jpvn].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");

            besselValueAtZero = besseljPrime(v, jpvn);
            testCase.verifyEqual(besselValueAtZero, ...
                zeros(size(besselValueAtZero)), ...
                AbsTol=testCase.tolVal);
        end

        function test_compare_jpvn_interleaving_v1(testCase)
            v = 1;
            n(:, 1) = 1:1000;

            jpvn = besseljPrimeZeros(v, n);
            jpvplus1m = besseljPrimeZeros(v + 1, n);

            zerosInOrder = reshape([jpvn, jpvplus1m].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");

            besselValueAtZero = besseljPrime(v, jpvn);
            testCase.verifyEqual(besselValueAtZero, ...
                zeros(size(besselValueAtZero)), ...
                AbsTol=testCase.tolVal);
        end

        function test_compare_jpvn_interleaving_vOneHalf(testCase)
            v = 0.5;
            n(:, 1) = 1:1000;

            jpvn = besseljPrimeZeros(v, n);
            jpvplus1m = besseljPrimeZeros(v + 1, n);

            zerosInOrder = reshape([jpvn, jpvplus1m].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");

            besselValueAtZero = besseljPrime(v, jpvn);
            testCase.verifyEqual(besselValueAtZero, ...
                zeros(size(besselValueAtZero)), ...
                AbsTol=testCase.tolVal);
        end

        function test_compare_jpvn_interleaving_v10000(testCase)
            v = 10000;
            n(:, 1) = 1:1000;

            jpvn = besseljPrimeZeros(v, n);
            jpvplus1m = besseljPrimeZeros(v + 1, n);

            zerosInOrder = reshape([jpvn, jpvplus1m].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");

            besselValueAtZero = besseljPrime(v, jpvn);
            testCase.verifyEqual(besselValueAtZero, ...
                zeros(size(besselValueAtZero)), ...
                AbsTol=testCase.tolVal);
        end

        function test_compare_jpvn_interleaving_vVariable(testCase)
            n(:, 1) = 1:20;
            for v = 0.5:0.5:100
                jpvn = besseljPrimeZeros(v, n);
                jpvplus1m = besseljPrimeZeros(v + 1, n);

                zerosInOrder = reshape([jpvn, jpvplus1m].', [], 1);
                testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                    sprintf("Bessel function zeros (for v = %g) " + ...
                    "must interlace properly.", v));

                besselValueAtZero = besseljPrime(v, jpvn);
                testCase.verifyEqual(besselValueAtZero, ...
                    zeros(size(besselValueAtZero)), ...
                    AbsTol=testCase.tolVal);
            end
        end

        %% Broadcasting Tests
        function test_broadcasting1(testCase)
            v = rand(10, 1);
            n = round(10*rand(1, 5)) + 1;

            jpvn = besseljPrimeZeros(v, n);
            testCase.verifySize(jpvn, [numel(v), numel(n)]);
        end

        function test_broadcasting2(testCase)
            v = rand(3, 1, 4);
            n = round(10*rand(1, 5, 4)) + 1;

            jpvn = besseljPrimeZeros(v, n);
            testCase.verifySize(jpvn, [3, 5, 4]);
        end

        %% Edge Case Tests
        function testEdge_decreasingSpacing_vGreaterThanOneHalf(testCase)
            v = 0.51;
            n(:, 1) = 1:1000;

            jpvn = besseljPrimeZeros(v, n);
            testCase.verifyLessThanOrEqual(diff(jpvn, 2), 0, ...
                "Spacing of zeros must be monotonically decreasing.");
        end

        function testEdge_decreasingSpacing_vLarge(testCase)
            v = 1000;
            n(:, 1) = 1:1000;

            jpvn = besseljPrimeZeros(v, n);
            testCase.verifyLessThanOrEqual(diff(jpvn, 2), 0, ...
                "Spacing of zeros must be monotonically decreasing.");
        end

        function testEdge_decreasingSpacing_vZero(testCase)
            v = 0;
            n(:, 1) = 1:1000;

            jpvn = besseljPrimeZeros(v, n);
            testCase.verifyLessThanOrEqual(diff(jpvn, 2), 0, ...
                "Spacing of zeros must be monotonically decreasing.");
        end

        %% Error Condition Tests
        function testError_broadcastingMismatch(testCase)
            v = rand(10, 1);
            n = round(10*rand(9, 5)) + 1;

            testCase.verifyError(@() besseljPrimeZeros(v, n), ...
                "MATLAB:sizeDimensionsMustMatch");
        end

        function testError_nonPositiveN(testCase)
            testCase.verifyError(@() besseljPrimeZeros(0, 0), ...
                "MATLAB:validators:mustBePositive");
            testCase.verifyError(@() besseljPrimeZeros(0, -1), ...
                "MATLAB:validators:mustBePositive");
        end

        function testError_nonIntegerN(testCase)
            testCase.verifyError(...
                @() besseljPrimeZeros(0, 1.5), ...
                "MATLAB:validators:mustBeInteger");
        end

        function testError_negativeNu(testCase)
            testCase.verifyError(...
                @() besseljPrimeZeros(-0.1, 1), ...
                "MATLAB:validators:mustBeNonnegative");
        end

        function testError_nonfiniteNu(testCase)
            testCase.verifyError(...
                @() besseljPrimeZeros(inf, 1), ...
                "MATLAB:validators:mustBeFinite");
        end
    end
end