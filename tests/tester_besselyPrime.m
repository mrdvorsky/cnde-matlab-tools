classdef tester_besselyPrime < matlab.unittest.TestCase
    % Unit tests for "besselyPrime" function.
    %
    % Author: Matt Dvorsky

    properties
        tolVal = 1e-14;

        besselFun = @(v, z, scale) besselyPrime(v, z, scale);
        expectedFun = @(v, z, scale) 0.5 * (bessely(v - 1, z, scale) ...
            - bessely(v + 1, z, scale));
    end

    methods (Test)
        %% Basic Functionality Tests
        function test_randomValuesScale0(testCase)
            N = 200;

            v = 20 * (rand(N, 1) - 0.5);
            z = 20 * ((rand(N, 1) - 0.5) + 1j*(rand(N, 1) - 0.5));

            % Test with scale = 0
            besselActual = testCase.besselFun(v, z, 0);
            expectedVal = testCase.expectedFun(v, z, 0);
            testCase.verifyEqual(...
                table(v, z, besselActual, VariableNames=["v", "z", "Jv(z)"]), ...
                table(v, z, expectedVal, VariableNames=["v", "z", "Jv(z)"]), ...
                AbsTol=testCase.tolVal, RelTol=testCase.tolVal);
        end

        function test_randomValuesScale1(testCase)
            N = 200;

            v = 20 * (rand(N, 1) - 0.5);
            z = 20 * ((rand(N, 1) - 0.5) + 1j*(rand(N, 1) - 0.5));

            % Test with scale = 1
            besselActual = testCase.besselFun(v, z, 1);
            expectedVal = testCase.expectedFun(v, z, 1);
            testCase.verifyEqual(...
                table(v, z, besselActual, VariableNames=["v", "z", "Jv(z)"]), ...
                table(v, z, expectedVal, VariableNames=["v", "z", "Jv(z)"]), ...
                AbsTol=testCase.tolVal, RelTol=testCase.tolVal);
        end

        %% Edge Case Tests
        function testError_incompatibleSizes1(testCase)
            testCase.verifyError(...
                @() testCase.besselFun(1:5, 1:10, 0), ...
                "MATLAB:bessely:NUAndZSizeMismatch");
        end

        function testError_incompatibleSizes2(testCase)
            testCase.verifyError(...
                @() testCase.besselFun((1:10).', (1:10), 0), ...
                "MATLAB:bessely:NUAndZSizeMismatch");
        end

        %% Error Condition Tests
        function testEdge_emptyInput1(testCase)
            val = testCase.besselFun([], 1, 0);

            testCase.verifySize(val, [0, 0]);
        end

        function testEdge_emptyInput2(testCase)
            val = testCase.besselFun(1, [], 0);

            testCase.verifySize(val, [0, 0]);
        end

        function testEdge_emptyInput3(testCase)
            val = testCase.besselFun([], [], 0);

            testCase.verifySize(val, [0, 0]);
        end

    end
end