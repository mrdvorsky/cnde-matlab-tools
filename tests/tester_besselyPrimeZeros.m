classdef tester_besselyPrimeZeros < matlab.unittest.TestCase
    % Unit tests for "besselyPrimeZeros" function.
    %
    % Author: Matt Dvorsky

    properties
        tolVal = 1e-14;

        nu = [0, 1, 2, 10, 0.5, 1000, 10000];
        jzero = [...
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
            n = testCase.nu(:);
            z0Actual = arrayfun(@(n) besselyPrimeZeros(n, 1), n);
            z0Exp = testCase.jzero(:);

            tableActual = table(n(:), z0Actual(:), besselyPrime(n(:), z0Actual(:)), ...
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

            jzeros = besselyPrimeZeros(n, nZeros);
            testCase.verifyLessThanOrEqual(diff(jzeros, 2), 0, ...
                "Spacing of zeros must be monotonically decreasing.");
        end

        function testEdge_decreasingSpacing_nuLarge(testCase)
            n = 1000;
            nZeros = 1000;

            jzeros = besselyPrimeZeros(n, nZeros);
            testCase.verifyLessThanOrEqual(diff(jzeros, 2), 0, ...
                "Spacing of zeros must be monotonically decreasing.");
        end

        function testEdge_decreasingSpacing_nuZero(testCase)
            n = 0;
            nZeros = 1000;

            jzeros = besselyPrimeZeros(n, nZeros);
            testCase.verifyLessThanOrEqual(diff(jzeros, 2), 0, ...
                "Spacing of zeros must be monotonically increasing.");
        end

        %% Error Condition Tests
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