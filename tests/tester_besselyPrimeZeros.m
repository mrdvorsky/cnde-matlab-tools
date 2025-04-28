classdef tester_besselyPrimeZeros < matlab.unittest.TestCase
    % Unit tests for "besselyPrimeZeros" function.
    %
    % Author: Matt Dvorsky

    properties
        tolVal = 1e-13;

        v0 = [0, 1, 2, 10, 0.5, 1000, 10000];
        ypvn0 = [...
            2.197141326031017, ...
            3.683022856585178, ...
            5.002582931446064, ...
            14.35301374369987, ...
            2.975086321688279, ...
            1018.304921954356, ...
            10039.27799214372, ...
            ];
    end

    methods (Test)
        %% Basic Functionality Tests
        function test_firstZero(testCase)
            v = testCase.v0(:);
            z0Actual = besselyPrimeZeros(v, 1);
            z0Exp = testCase.ypvn0(:);

            testCase.verifyEqual(z0Actual, z0Exp, ...
                RelTol=testCase.tolVal, AbsTol=testCase.tolVal);

            % Verify that they are zeros.
            besVal = besselyPrime(v, z0Actual);
            testCase.verifyEqual(besVal, 0*v, ...
                RelTol=testCase.tolVal, AbsTol=testCase.tolVal);
        end

        %% Assert Interleaving Property of Bessel Function Zeros
        function test_compare_ypvn_interleaving_v0(testCase)
            v = 0;
            n(:, 1) = 1:1000;

            ypvn = besselyPrimeZeros(v, n);
            ypvplus1m = besselyPrimeZeros(v + 1, n);

            zerosInOrder = reshape([ypvn, ypvplus1m].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");

            besselValueAtZero = besselyPrime(v, ypvn);
            testCase.verifyEqual(besselValueAtZero, ...
                zeros(size(besselValueAtZero)), ...
                AbsTol=testCase.tolVal);
        end

        function test_compare_ypvn_interleaving_v1(testCase)
            v = 1;
            n(:, 1) = 1:1000;

            ypvn = besselyPrimeZeros(v, n);
            ypvplus1m = besselyPrimeZeros(v + 1, n);

            zerosInOrder = reshape([ypvn, ypvplus1m].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");

            besselValueAtZero = besselyPrime(v, ypvn);
            testCase.verifyEqual(besselValueAtZero, ...
                zeros(size(besselValueAtZero)), ...
                AbsTol=testCase.tolVal);
        end

        function test_compare_ypvn_interleaving_vOneHalf(testCase)
            v = 0.5;
            n(:, 1) = 1:1000;

            ypvn = besselyPrimeZeros(v, n);
            ypvplus1m = besselyPrimeZeros(v + 1, n);

            zerosInOrder = reshape([ypvn, ypvplus1m].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");

            besselValueAtZero = besselyPrime(v, ypvn);
            testCase.verifyEqual(besselValueAtZero, ...
                zeros(size(besselValueAtZero)), ...
                AbsTol=testCase.tolVal);
        end

        function test_compare_ypvn_interleaving_v10000(testCase)
            v = 10000;
            n(:, 1) = 1:1000;

            ypvn = besselyPrimeZeros(v, n);
            ypvplus1m = besselyPrimeZeros(v + 1, n);

            zerosInOrder = reshape([ypvn, ypvplus1m].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");

            besselValueAtZero = besselyPrime(v, ypvn);
            testCase.verifyEqual(besselValueAtZero, ...
                zeros(size(besselValueAtZero)), ...
                AbsTol=testCase.tolVal);
        end

        function test_compare_ypvn_interleaving_vVariable(testCase)
            n(:, 1) = 1:20;
            for v = 0.5:0.5:100
                ypvn = besselyPrimeZeros(v, n);
                ypvplus1m = besselyPrimeZeros(v + 1, n);

                zerosInOrder = reshape([ypvn, ypvplus1m].', [], 1);
                testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                    sprintf("Bessel function zeros (for v = %g) " + ...
                    "must interlace properly.", v));

                besselValueAtZero = besselyPrime(v, ypvn);
                testCase.verifyEqual(besselValueAtZero, ...
                    zeros(size(besselValueAtZero)), ...
                    AbsTol=testCase.tolVal);
            end
        end

        %% Broadcasting Tests
        function test_broadcasting1(testCase)
            v = rand(10, 1);
            n = round(10*rand(1, 5)) + 1;

            ypvn = besselyPrimeZeros(v, n);
            testCase.verifySize(ypvn, [numel(v), numel(n)]);
        end

        function test_broadcasting2(testCase)
            v = rand(3, 1, 4);
            n = round(10*rand(1, 5, 4)) + 1;

            ypvn = besselyPrimeZeros(v, n);
            testCase.verifySize(ypvn, [3, 5, 4]);
        end

        %% Edge Case Tests
        function testEdge_decreasingSpacing_vGreaterThanOneHalf(testCase)
            v = 0.51;
            n(:, 1) = 1:1000;

            ypvn = besselyPrimeZeros(v, n);
            testCase.verifyLessThanOrEqual(diff(ypvn, 2), 0, ...
                "Spacing of zeros must be monotonically decreasing.");
        end

        function testEdge_decreasingSpacing_vLarge(testCase)
            v = 1000;
            n(:, 1) = 1:1000;

            ypvn = besselyPrimeZeros(v, n);
            testCase.verifyLessThanOrEqual(diff(ypvn, 2), 0, ...
                "Spacing of zeros must be monotonically decreasing.");
        end

        function testEdge_decreasingSpacing_vZero(testCase)
            v = 0;
            n(:, 1) = 1:1000;

            ypvn = besselyPrimeZeros(v, n);
            testCase.verifyLessThanOrEqual(diff(ypvn, 2), 0, ...
                "Spacing of zeros must be monotonically increasing.");
        end

        %% Error Condition Tests
        function testError_broadcastingMismatch(testCase)
            v = rand(10, 1);
            n = round(10*rand(9, 5)) + 1;

            testCase.verifyError(@() besselyPrimeZeros(v, n), ...
                "MATLAB:sizeDimensionsMustMatch");
        end

        function testError_nonPositiveN(testCase)
            testCase.verifyError(@() besselyPrimeZeros(0, 0), ...
                "MATLAB:validators:mustBePositive");
            testCase.verifyError(@() besselyPrimeZeros(0, -1), ...
                "MATLAB:validators:mustBePositive");
        end

        function testError_nonIntegerN(testCase)
            testCase.verifyError(...
                @() besselyPrimeZeros(0, 1.5), ...
                "MATLAB:validators:mustBeInteger");
        end

        function testError_negativeNu(testCase)
            testCase.verifyError(...
                @() besselyPrimeZeros(-0.1, 1), ...
                "MATLAB:validators:mustBeNonnegative");
        end

        function testError_nonfiniteNu(testCase)
            testCase.verifyError(...
                @() besselyPrimeZeros(inf, 1), ...
                "MATLAB:validators:mustBeFinite");
        end
    end
end