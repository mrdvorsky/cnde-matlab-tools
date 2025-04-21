classdef tester_besseljyPrime < matlab.unittest.TestCase
    % Unit tests for "besseljyPrime" function.
    %
    % Author: Matt Dvorsky

    properties
        tolVal = 1e-12;

        besselFun = @(t, v, z, scale) besseljyPrime(t, v, z, scale);
        expectedFun = @(t, v, z, scale) cos(t).*besseljPrime(v, z, scale) ...
            + sin(t).*besselyPrime(v, z, scale);
    end

    methods (Test)
        %% Basic Functionality Tests
        function test_randomValuesScale0(testCase)
            N = 200;

            t = 20 * (rand(N, 1) - 0.5);
            v = 20 * (rand(N, 1) - 0.5);
            z = 20 * ((rand(N, 1) - 0.5) + 1j*(rand(N, 1) - 0.5));

            % Test with scale = 0
            besselActual = testCase.besselFun(t, v, z, 0);
            expectedVal = testCase.expectedFun(t, v, z, 0);
            testCase.verifyEqual(...
                table(t, v, z, besselActual, ...
                    VariableNames=["phase", "v", "z", "Jv(z)"]), ...
                table(t, v, z, expectedVal, ...
                    VariableNames=["phase", "v", "z", "Jv(z)"]), ...
                AbsTol=testCase.tolVal, RelTol=testCase.tolVal);
        end

        function test_randomValuesScale1(testCase)
            N = 200;

            t = 20 * (rand(N, 1) - 0.5);
            v = 20 * (rand(N, 1) - 0.5);
            z = 20 * ((rand(N, 1) - 0.5) + 1j*(rand(N, 1) - 0.5));

            % Test with scale = 1
            besselActual = testCase.besselFun(t, v, z, 1);
            expectedVal = testCase.expectedFun(t, v, z, 1);
            testCase.verifyEqual(...
                table(t, v, z, besselActual, ...
                    VariableNames=["phase", "v", "z", "Jv(z)"]), ...
                table(t, v, z, expectedVal, ...
                    VariableNames=["phase", "v", "z", "Jv(z)"]), ...
                AbsTol=testCase.tolVal, RelTol=testCase.tolVal);
        end

        function test_randomValuesT0(testCase)
            N = 200;

            v = 20 * (rand(N, 1) - 0.5);
            z = 20 * ((rand(N, 1) - 0.5) + 0.1j*(rand(N, 1) - 0.5));

            % Test with t = 0, should be equivalent to besseljPrime
            besselActual = testCase.besselFun(0, v, z, 0);
            expectedVal = besseljPrime(v, z, 0);
            testCase.verifyEqual(...
                table(v, z, besselActual, ...
                    VariableNames=["v", "z", "Jv(z)"]), ...
                table(v, z, expectedVal, ...
                    VariableNames=["v", "z", "Jv(z)"]), ...
                AbsTol=testCase.tolVal, RelTol=testCase.tolVal);
        end

        function test_randomValuesTpiOver2(testCase)
            N = 200;

            v = 20 * (rand(N, 1) - 0.5);
            z = 20 * ((rand(N, 1) - 0.5) + 0.001j*(rand(N, 1) - 0.5));

            % Test with t = pi/2, should be equivalent to bessely
            besselActual = testCase.besselFun(pi/2, v, z, 0);
            expectedVal = besselyPrime(v, z, 0);
            testCase.verifyEqual(...
                table(v, z, besselActual, ...
                    VariableNames=["v", "z", "Jv(z)"]), ...
                table(v, z, expectedVal, ...
                    VariableNames=["v", "z", "Jv(z)"]), ...
                AbsTol=testCase.tolVal, RelTol=testCase.tolVal);
        end

        %% Edge Case Tests
        function testError_incompatibleSizes1(testCase)
            testCase.verifyError(...
                @() testCase.besselFun(0, 1:5, 1:10, 0), ...
                "MATLAB:besselj:NUAndZSizeMismatch");
        end

        function testError_incompatibleSizes2(testCase)
            testCase.verifyError(...
                @() testCase.besselFun(0, (1:10).', (1:10), 0), ...
                "MATLAB:besselj:NUAndZSizeMismatch");
        end

        %% Error Condition Tests
        function testEdge_emptyInput1(testCase)
            val = testCase.besselFun(0, [], 1, 0);

            testCase.verifySize(val, [0, 0]);
        end

        function testEdge_emptyInput2(testCase)
            val = testCase.besselFun(0, 0, [], 0);

            testCase.verifySize(val, [0, 0]);
        end

        function testEdge_emptyInput3(testCase)
            val = testCase.besselFun([], [], [], 0);

            testCase.verifySize(val, [0, 0]);
        end

    end
end