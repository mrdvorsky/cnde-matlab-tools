classdef tester_besselCylinder < matlab.unittest.TestCase
    % Unit tests for "besselCylinder" function.
    %
    % Author: Matt Dvorsky

    properties
        tolVal = 1e-12;

        besselFun = @(v, t, z, scale) besselCylinder(v, t, z, scale);
        expectedFun = @(v, t, z, scale) real(t).*besselj(v, z, scale) ...
            + imag(t).*bessely(v, z, scale);
    end

    methods (Test)
        %% Basic Functionality Tests
        function test_randomValuesScale0(testCase)
            N = 200;

            t = exp(1j * 20 * (rand(N, 1) - 0.5));
            v = 20 * (rand(N, 1) - 0.5);
            z = 20 * ((rand(N, 1) - 0.5) + 1j*(rand(N, 1) - 0.5));

            % Test with scale = 0
            besselActual = testCase.besselFun(v, t, z, 0);
            expectedVal = testCase.expectedFun(v, t, z, 0);
            testCase.verifyEqual(...
                table(t, v, z, besselActual, ...
                VariableNames=["phase", "v", "z", "Jv(z)"]), ...
                table(t, v, z, expectedVal, ...
                VariableNames=["phase", "v", "z", "Jv(z)"]), ...
                AbsTol=testCase.tolVal, RelTol=testCase.tolVal);
        end

        function test_randomValuesScale1(testCase)
            N = 200;

            t = exp(1j * 20 * (rand(N, 1) - 0.5));
            v = 20 * (rand(N, 1) - 0.5);
            z = 20 * ((rand(N, 1) - 0.5) + 1j*(rand(N, 1) - 0.5));

            % Test with scale = 1
            besselActual = testCase.besselFun(v, t, z, 1);
            expectedVal = testCase.expectedFun(v, t, z, 1);
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

            % Test with t = 1, should be equivalent to besselj
            besselActual = testCase.besselFun(v, 1, z, 0);
            expectedVal = besselj(v, z, 0);
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

            % Test with t = 1j, should be equivalent to bessely
            besselActual = testCase.besselFun(v, 1j, z, 0);
            expectedVal = bessely(v, z, 0);
            testCase.verifyEqual(...
                table(v, z, besselActual, ...
                VariableNames=["v", "z", "Jv(z)"]), ...
                table(v, z, expectedVal, ...
                VariableNames=["v", "z", "Jv(z)"]), ...
                AbsTol=testCase.tolVal, RelTol=testCase.tolVal);
        end

        %% Broadcasting Tests
        function test_broadcasting(testCase)
            v = 1 + rand(1, 3, 4);
            t = exp(1j * rand(2, 3, 1));
            z = rand(2, 1, 4);

            zeroSize = 0*(v + t + z);

            besselActual = testCase.besselFun(v, t, z, 0);

            v = v + zeroSize;
            t = t + zeroSize;
            z = z + zeroSize;
            expectedVal = testCase.expectedFun(v, t, z, 0);
            testCase.verifyEqual(...
                table(t(:), v(:), z(:), besselActual(:), ...
                VariableNames=["phase", "v", "z", "Jv(z)"]), ...
                table(t(:), v(:), z(:), expectedVal(:), ...
                VariableNames=["phase", "v", "z", "Jv(z)"]), ...
                AbsTol=testCase.tolVal, RelTol=testCase.tolVal);
        end

        %% Edge Case Tests
        function testError_incompatibleSizes(testCase)
            v = 1 + rand(3, 3, 4);
            t = exp(1j * rand(2, 3, 4));
            z = rand(2, 1, 4);
            testCase.verifyError(...
                @() testCase.besselFun(v, t, z, 0), ...
                "MATLAB:sizeDimensionsMustMatch");
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