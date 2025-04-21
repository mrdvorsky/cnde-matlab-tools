classdef tester_besseljPrimeZeros < matlab.unittest.TestCase
    % Unit tests for "besseljPrimeZeros" function.
    %
    % Author: Matt Dvorsky

    properties
        tolVal = 1e-14;

        v0 = [0, 1, 2, 10, 0.5, 1000, 10000];
        jzero0 = [...
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
            z0Actual = arrayfun(@(n) besseljPrimeZeros(n, 1), v);
            z0Exp = testCase.jzero0(:);

            tableActual = table(v(:), z0Actual(:), besseljPrime(v(:), z0Actual(:)), ...
                VariableNames=["v", "z0", "f(z0)"]);

            tableExp = table(v(:), z0Exp, 0*z0Exp(:), ...
                VariableNames=["v", "z0", "f(z0)"]);

            testCase.verifyEqual(tableActual, tableExp, ...
                RelTol=testCase.tolVal, AbsTol=testCase.tolVal);
        end

        %% Assert Interleaving Property of Bessel Function Zeros
        function test_compare_jpvm_interleaving_v0(testCase)
            v = 0;
            nZeros = 1000;

            jpvm = besseljPrimeZeros(v, nZeros);
            jpvplus1m = besseljPrimeZeros(v + 1, nZeros);

            % For zero order, jpvm should be larger, due to the convention
            % of having the first zero of J0'(x) be non-zero.
            zerosInOrder = reshape([jpvplus1m, jpvm].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");
        end

        function test_compare_jpvm_interleaving_v1(testCase)
            v = 1;
            nZeros = 1000;

            jpvm = besseljPrimeZeros(v, nZeros);
            jpvplus1m = besseljPrimeZeros(v + 1, nZeros);

            zerosInOrder = reshape([jpvm, jpvplus1m].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");
        end

        function test_compare_jpvm_interleaving_vOneHalf(testCase)
            v = 0.5;
            nZeros = 1000;

            jpvm = besseljPrimeZeros(v, nZeros);
            jpvplus1m = besseljPrimeZeros(v + 1, nZeros);

            zerosInOrder = reshape([jpvm, jpvplus1m].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");
        end

        function test_compare_jpvm_interleaving_v10000(testCase)
            v = 10000;
            nZeros = 1000;

            jpvm = besseljPrimeZeros(v, nZeros);
            jpvplus1m = besseljPrimeZeros(v + 1, nZeros);

            zerosInOrder = reshape([jpvm, jpvplus1m].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");
        end

        function test_compare_jpvm_interleaving_vVariable(testCase)
            for v = 0.5:0.5:100
                nZeros = 20;

                jpvm = besseljPrimeZeros(v, nZeros);
                jpvplus1m = besseljPrimeZeros(v + 1, nZeros);

                zerosInOrder = reshape([jpvm, jpvplus1m].', [], 1);
                testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                    "Bessel function zeros must interlace properly.");
            end
        end

        %% Edge Case Tests
        function testEdge_decreasingSpacing_vGreaterThanOneHalf(testCase)
            v = 0.51;
            nZeros = 1000;

            jzeros = besseljPrimeZeros(v, nZeros);
            testCase.verifyLessThanOrEqual(diff(jzeros, 2), 0, ...
                "Spacing of zeros must be monotonically decreasing.");
        end

        function testEdge_decreasingSpacing_vLarge(testCase)
            v = 1000;
            nZeros = 1000;

            jzeros = besseljPrimeZeros(v, nZeros);
            testCase.verifyLessThanOrEqual(diff(jzeros, 2), 0, ...
                "Spacing of zeros must be monotonically decreasing.");
        end

        function testEdge_decreasingSpacing_vZero(testCase)
            v = 0;
            nZeros = 1000;

            jzeros = besseljPrimeZeros(v, nZeros);
            testCase.verifyLessThanOrEqual(diff(jzeros, 2), 0, ...
                "Spacing of zeros must be monotonically increasing.");
        end

        %% Error Condition Tests
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