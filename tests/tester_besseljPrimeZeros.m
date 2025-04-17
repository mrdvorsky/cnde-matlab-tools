classdef tester_besseljPrimeZeros < matlab.unittest.TestCase
    % Unit tests for "besseljPrimeZeros" function.
    %
    % Author: Matt Dvorsky

    properties
        tolVal = 1e-14;

        nu = [0, 1, 2, 10, 0.5, 1000, 10000];
        jzero = [...
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
            n = testCase.nu(:);
            z0Actual = arrayfun(@(n) besseljPrimeZeros(n, 1), n);
            z0Exp = testCase.jzero(:);

            tableActual = table(n(:), z0Actual(:), besseljPrime(n(:), z0Actual(:)), ...
                VariableNames=["nu", "z0", "f(z0)"]);

            tableExp = table(n(:), z0Exp, 0*z0Exp(:), ...
                VariableNames=["nu", "z0", "f(z0)"]);

            testCase.verifyEqual(tableActual, tableExp, ...
                RelTol=testCase.tolVal, AbsTol=testCase.tolVal);
        end

        %% Edge Case Tests
        function testEdge_decreasingSpacing_nuGreaterThanOneHalf(testCase)
            n = 0.51;
            nZeros = 1000;

            jzeros = besseljPrimeZeros(n, nZeros);
            testCase.verifyLessThanOrEqual(diff(jzeros, 2), 0, ...
                "Spacing of zeros must be monotonically decreasing.");
        end

        function testEdge_decreasingSpacing_nuLarge(testCase)
            n = 1000;
            nZeros = 1000;

            jzeros = besseljPrimeZeros(n, nZeros);
            testCase.verifyLessThanOrEqual(diff(jzeros, 2), 0, ...
                "Spacing of zeros must be monotonically decreasing.");
        end

        function testEdge_decreasingSpacing_nuZero(testCase)
            n = 0;
            nZeros = 1000;

            jzeros = besseljPrimeZeros(n, nZeros);
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