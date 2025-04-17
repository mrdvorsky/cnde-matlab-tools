classdef tester_besselyZeros < matlab.unittest.TestCase
    % Unit tests for "besselyZeros" function.
    %
    % Author: Matt Dvorsky

    properties
        tolVal = 1e-14;

        nu = [0, 1, 2, 10, 0.5, 1000, 10000];
        jzero = [...
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
            n = testCase.nu(:);
            z0Actual = arrayfun(@(n) besselyZeros(n, 1), n);
            z0Exp = testCase.jzero(:);

            tableActual = table(n(:), z0Actual(:), bessely(n(:), z0Actual(:)), ...
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

            jzeros = besselyZeros(n, nZeros);
            testCase.verifyLessThanOrEqual(diff(jzeros, 2), 0, ...
                "Spacing of zeros must be monotonically decreasing.");
        end

        function testEdge_increasingSpacing_nuLessThanOneHalf(testCase)
            n = 0.49;
            nZeros = 1000;

            jzeros = besselyZeros(n, nZeros);
            testCase.verifyGreaterThanOrEqual(diff(jzeros, 2), 0, ...
                "Spacing of zeros must be monotonically increasing.");
        end

        function testEdge_decreasingSpacing_nuLarge(testCase)
            n = 1000;
            nZeros = 1000;

            jzeros = besselyZeros(n, nZeros);
            testCase.verifyLessThanOrEqual(diff(jzeros, 2), 0, ...
                "Spacing of zeros must be monotonically decreasing.");
        end

        function testEdge_increasingSpacing_nuZero(testCase)
            n = 0;
            nZeros = 1000;

            jzeros = besselyZeros(n, nZeros);
            testCase.verifyGreaterThanOrEqual(diff(jzeros, 2), 0, ...
                "Spacing of zeros must be monotonically increasing.");
        end

        %% Error Condition Tests
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