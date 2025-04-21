classdef tester_besseljZeros < matlab.unittest.TestCase
    % Unit tests for "besseljZeros" function.
    %
    % Author: Matt Dvorsky

    properties
        tolVal = 1e-14;

        v0 = [0, 1, 2, 10, 0.5, 1000, 10000];
        jzero0 = [...
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
            z0Actual = arrayfun(@(n) besseljZeros(n, 1), v);
            z0Exp = testCase.jzero0(:);

            tableActual = table(v(:), z0Actual(:), besselj(v(:), z0Actual(:)), ...
                VariableNames=["v", "z0", "f(z0)"]);

            tableExp = table(v(:), z0Exp, 0*z0Exp(:), ...
                VariableNames=["v", "z0", "f(z0)"]);

            testCase.verifyEqual(tableActual, tableExp, ...
                RelTol=testCase.tolVal, AbsTol=testCase.tolVal);
        end

        %% Compare Orderings of all Bessel(j,y,j',y') Function Zeros
        function test_compare_jpvm_yvm_ypvm_jvm_v1(testCase)
            v = 1;
            nZeros = 1000;

            jpvm = besseljPrimeZeros(v, nZeros);
            yvm = besselyZeros(v, nZeros);
            ypvm = besselyPrimeZeros(v, nZeros);
            jvm = besseljZeros(v, nZeros);

            zerosInOrder = reshape([jpvm, yvm, ypvm, jvm].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must be in order relative to each other.");
        end

        function test_compare_jpvm_yvm_ypvm_jvm_v2(testCase)
            v = 2;
            nZeros = 1000;

            jpvm = besseljPrimeZeros(v, nZeros);
            yvm = besselyZeros(v, nZeros);
            ypvm = besselyPrimeZeros(v, nZeros);
            jvm = besseljZeros(v, nZeros);

            zerosInOrder = reshape([jpvm, yvm, ypvm, jvm].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must be in order relative to each other.");
        end

        function test_compare_jpvm_yvm_ypvm_jvm_v10(testCase)
            v = 10;
            nZeros = 1000;

            jpvm = besseljPrimeZeros(v, nZeros);
            yvm = besselyZeros(v, nZeros);
            ypvm = besselyPrimeZeros(v, nZeros);
            jvm = besseljZeros(v, nZeros);

            zerosInOrder = reshape([jpvm, yvm, ypvm, jvm].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must be in order relative to each other.");
        end

        function test_compare_jpvm_yvm_ypvm_jvm_v10000(testCase)
            v = 10000;
            nZeros = 1000;

            jpvm = besseljPrimeZeros(v, nZeros);
            yvm = besselyZeros(v, nZeros);
            ypvm = besselyPrimeZeros(v, nZeros);
            jvm = besseljZeros(v, nZeros);

            zerosInOrder = reshape([jpvm, yvm, ypvm, jvm].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must be in order relative to each other.");
        end

        function test_compare_jpvm_yvm_ypvm_jvm_vOneHalf(testCase)
            v = 0.5;
            nZeros = 1000;

            jpvm = besseljPrimeZeros(v, nZeros);
            yvm = besselyZeros(v, nZeros);
            ypvm = besselyPrimeZeros(v, nZeros);
            jvm = besseljZeros(v, nZeros);

            zerosInOrder = reshape([jpvm, yvm, ypvm, jvm].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must be in order relative to each other.");
        end

        function test_compare_jpvm_yvm_ypvm_jvm_vSmall(testCase)
            v = 0.1;
            nZeros = 1000;

            jpvm = besseljPrimeZeros(v, nZeros);
            yvm = besselyZeros(v, nZeros);
            ypvm = besselyPrimeZeros(v, nZeros);
            jvm = besseljZeros(v, nZeros);

            zerosInOrder = reshape([jpvm, yvm, ypvm, jvm].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must be in order relative to each other.");
        end

        function test_compare_jpvm_yvm_ypvm_jvm_v0(testCase)
            v = 0;
            nZeros = 1000;

            jpvm = besseljPrimeZeros(v, nZeros);
            yvm = besselyZeros(v, nZeros);
            ypvm = besselyPrimeZeros(v, nZeros);
            jvm = besseljZeros(v, nZeros);

            % For zero order, jpvm should be larger, due to the convention
            % of having the first zero of J0'(x) be non-zero.
            zerosInOrder = reshape([yvm, ypvm, jvm, jpvm].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must be in order relative to each other.");
        end

        function test_compare_jpvm_yvm_ypvm_jvm_vVariable(testCase)
            for v = 0.5:0.5:100
                nZeros = 20;

                jpvm = besseljPrimeZeros(v, nZeros);
                yvm = besselyZeros(v, nZeros);
                ypvm = besselyPrimeZeros(v, nZeros);
                jvm = besseljZeros(v, nZeros);

                zerosInOrder = reshape([jpvm, yvm, ypvm, jvm].', [], 1);
                testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                    "Bessel function zeros must be in order relative to each other.");
            end
        end

        %% Assert Interleaving Property of Bessel Function Zeros
        function test_compare_jvm_interleaving_v0(testCase)
            v = 0;
            nZeros = 1000;

            jvm = besseljZeros(v, nZeros);
            jvplus1m = besseljZeros(v + 1, nZeros);

            zerosInOrder = reshape([jvm, jvplus1m].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");
        end

        function test_compare_jvm_interleaving_v1(testCase)
            v = 1;
            nZeros = 1000;

            jvm = besseljZeros(v, nZeros);
            jvplus1m = besseljZeros(v + 1, nZeros);

            zerosInOrder = reshape([jvm, jvplus1m].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");
        end

        function test_compare_jvm_interleaving_vOneHalf(testCase)
            v = 0.5;
            nZeros = 1000;

            jvm = besseljZeros(v, nZeros);
            jvplus1m = besseljZeros(v + 1, nZeros);

            zerosInOrder = reshape([jvm, jvplus1m].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");
        end

        function test_compare_jvm_interleaving_v10000(testCase)
            v = 10000;
            nZeros = 1000;

            jvm = besseljZeros(v, nZeros);
            jvplus1m = besseljZeros(v + 1, nZeros);

            zerosInOrder = reshape([jvm, jvplus1m].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");
        end

        function test_compare_jvm_interleaving_vVariable(testCase)
            for v = 0.5:0.5:100
                nZeros = 20;

                jvm = besseljZeros(v, nZeros);
                jvplus1m = besseljZeros(v + 1, nZeros);

                zerosInOrder = reshape([jvm, jvplus1m].', [], 1);
                testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                    "Bessel function zeros must interlace properly.");
            end
        end

        %% Edge Case Tests
        function testEdge_decreasingSpacing_vGreaterThanOneHalf(testCase)
            v = 0.51;
            nZeros = 1000;

            jzeros = besseljZeros(v, nZeros);
            testCase.verifyLessThanOrEqual(diff(jzeros, 2), 0, ...
                "Spacing of zeros must be monotonically decreasing.");
        end

        function testEdge_increasingSpacing_vLessThanOneHalf(testCase)
            v = 0.49;
            nZeros = 1000;

            jzeros = besseljZeros(v, nZeros);
            testCase.verifyGreaterThanOrEqual(diff(jzeros, 2), 0, ...
                "Spacing of zeros must be monotonically increasing.");
        end

        function testEdge_decreasingSpacing_vLarge(testCase)
            v = 1000;
            nZeros = 1000;

            jzeros = besseljZeros(v, nZeros);
            testCase.verifyLessThanOrEqual(diff(jzeros, 2), 0, ...
                "Spacing of zeros must be monotonically decreasing.");
        end

        function testEdge_increasingSpacing_vZero(testCase)
            v = 0;
            nZeros = 1000;

            jzeros = besseljZeros(v, nZeros);
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