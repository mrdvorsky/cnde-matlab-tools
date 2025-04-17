classdef tester_besseljZeros < matlab.unittest.TestCase
    % Unit tests for "besseljZeros" function.
    %
    % Author: Matt Dvorsky

    properties
        tolVal = 1e-14;

        nu = [0, 1, 2, 10, 0.5, 1000, 10000];
        jzero = [...
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
            n = testCase.nu(:);
            z0Actual = arrayfun(@(n) besseljZeros(n, 1), n);
            z0Exp = testCase.jzero(:);

            tableActual = table(n(:), z0Actual(:), besselj(n(:), z0Actual(:)), ...
                VariableNames=["nu", "z0", "f(z0)"]);

            tableExp = table(n(:), z0Exp, 0*z0Exp(:), ...
                VariableNames=["nu", "z0", "f(z0)"]);

            testCase.verifyEqual(tableActual, tableExp, ...
                RelTol=testCase.tolVal, AbsTol=testCase.tolVal);
        end

        %% Compare Orderings of all Bessel Function Zeros
        function test_compare_jpvm_yvm_ypvm_jvm_nu1(testCase)
            n = 1;
            nZeros = 1000;

            jpvm = besseljPrimeZeros(n, nZeros);
            yvm = besselyZeros(n, nZeros);
            ypvm = besselyPrimeZeros(n, nZeros);
            jvm = besseljZeros(n, nZeros);

            zerosInOrder = reshape([jpvm, yvm, ypvm, jvm].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must be in order relative to each other.");
        end

        function test_compare_jpvm_yvm_ypvm_jvm_nu2(testCase)
            n = 2;
            nZeros = 1000;

            jpvm = besseljPrimeZeros(n, nZeros);
            yvm = besselyZeros(n, nZeros);
            ypvm = besselyPrimeZeros(n, nZeros);
            jvm = besseljZeros(n, nZeros);

            zerosInOrder = reshape([jpvm, yvm, ypvm, jvm].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must be in order relative to each other.");
        end

        function test_compare_jpvm_yvm_ypvm_jvm_nu10(testCase)
            n = 10;
            nZeros = 1000;

            jpvm = besseljPrimeZeros(n, nZeros);
            yvm = besselyZeros(n, nZeros);
            ypvm = besselyPrimeZeros(n, nZeros);
            jvm = besseljZeros(n, nZeros);

            zerosInOrder = reshape([jpvm, yvm, ypvm, jvm].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must be in order relative to each other.");
        end

        function test_compare_jpvm_yvm_ypvm_jvm_nu10000(testCase)
            n = 10000;
            nZeros = 1000;

            jpvm = besseljPrimeZeros(n, nZeros);
            yvm = besselyZeros(n, nZeros);
            ypvm = besselyPrimeZeros(n, nZeros);
            jvm = besseljZeros(n, nZeros);

            zerosInOrder = reshape([jpvm, yvm, ypvm, jvm].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must be in order relative to each other.");
        end

        function test_compare_jpvm_yvm_ypvm_jvm_nuOneHalf(testCase)
            n = 0.5;
            nZeros = 1000;

            jpvm = besseljPrimeZeros(n, nZeros);
            yvm = besselyZeros(n, nZeros);
            ypvm = besselyPrimeZeros(n, nZeros);
            jvm = besseljZeros(n, nZeros);

            zerosInOrder = reshape([jpvm, yvm, ypvm, jvm].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must be in order relative to each other.");
        end

        function test_compare_jpvm_yvm_ypvm_jvm_nuSmall(testCase)
            n = 0.1;
            nZeros = 1000;

            jpvm = besseljPrimeZeros(n, nZeros);
            yvm = besselyZeros(n, nZeros);
            ypvm = besselyPrimeZeros(n, nZeros);
            jvm = besseljZeros(n, nZeros);

            zerosInOrder = reshape([jpvm, yvm, ypvm, jvm].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must be in order relative to each other.");
        end

        function test_compare_jpvm_yvm_ypvm_jvm_nu0(testCase)
            n = 0;
            nZeros = 1000;

            jpvm = besseljPrimeZeros(n, nZeros);
            yvm = besselyZeros(n, nZeros);
            ypvm = besselyPrimeZeros(n, nZeros);
            jvm = besseljZeros(n, nZeros);

            % For zero order, jpvm should be larger, due to the convention
            % of having the first zero of J0'(x) be non-zero.
            zerosInOrder = reshape([yvm, ypvm, jvm, jpvm].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must be in order relative to each other.");
        end

        %% Edge Case Tests
        function testEdge_decreasingSpacing_nuGreaterThanOneHalf(testCase)
            n = 0.51;
            nZeros = 1000;

            jzeros = besseljZeros(n, nZeros);
            testCase.verifyLessThanOrEqual(diff(jzeros, 2), 0, ...
                "Spacing of zeros must be monotonically decreasing.");
        end

        function testEdge_increasingSpacing_nuLessThanOneHalf(testCase)
            n = 0.49;
            nZeros = 1000;

            jzeros = besseljZeros(n, nZeros);
            testCase.verifyGreaterThanOrEqual(diff(jzeros, 2), 0, ...
                "Spacing of zeros must be monotonically increasing.");
        end

        function testEdge_decreasingSpacing_nuLarge(testCase)
            n = 1000;
            nZeros = 1000;

            jzeros = besseljZeros(n, nZeros);
            testCase.verifyLessThanOrEqual(diff(jzeros, 2), 0, ...
                "Spacing of zeros must be monotonically decreasing.");
        end

        function testEdge_increasingSpacing_nuZero(testCase)
            n = 0;
            nZeros = 1000;

            jzeros = besseljZeros(n, nZeros);
            testCase.verifyGreaterThanOrEqual(diff(jzeros, 2), 0, ...
                "Spacing of zeros must be monotonically increasing.");
        end

        %% Error Condition Tests
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