classdef tester_trap < matlab.unittest.TestCase
    % Unit tests for "trap" function.
    %
    % Author: Matt Dvorsky

    properties
        tolVal = 1e-10;
    end

    methods (Test)
        %% Basic Functionality Tests
        function test_sumOfWeights(testCase)
            N = 10;
            a = 0;
            b = 1;

            [~, weights] = trap(N, a, b);

            % Test integration of constant function
            numerical = sum(weights);
            analytical = 1;
            testCase.verifyEqual(numerical, analytical, ...
                AbsTol=testCase.tolVal);
        end

        function test_trigonometricExactness(testCase)
            N = 20;
            a = 0;
            b = 2*pi;

            % Should be exact for trigonometric polynomials up to degree N
            for k = 1:(N/2)
                f = @(x) rand(1)*sin(k*x) + rand(1)*cos(k*x);

                [nodes, weights] = trap(N, a, b);

                numerical = sum(f(nodes) .* weights);
                analytical = 0;
                testCase.verifyEqual(numerical, analytical, ...
                    sprintf("Failed for sin(%d*x)", k), ...
                    AbsTol=testCase.tolVal);
            end
        end

        function test_complexInterval(testCase)
            N = 1000;
            a = 0;
            b = 1 + 1i;

            fFun = @(z) z.^2;

            [nodes, weights] = trap(N, a, b);

            numerical = sum(fFun(nodes) .* weights);
            analytical = (1/3)*(b^3 - a^3);
            testCase.verifyEqual(numerical, analytical, ...
                AbsTol=1e-6);   % Lower error due to non-periodicity
        end

        %% Edge Case Tests
        function testEdge_minimumN(testCase)
            N = 2;
            a = 0;
            b = 1;

            [nodes, weights] = trap(N, a, b);

            testCase.verifyNumElements(nodes, N);
            testCase.verifyNumElements(weights, N);

            numerical = sum(weights);
            analytical = 1;
            testCase.verifyEqual(numerical, analytical, ...
                AbsTol=testCase.tolVal);
        end

        function testEdge_largeN(testCase)
            N = 100;
            a = 0;
            b = 2*pi;

            [nodes, weights] = trap(N, a, b);

            testCase.verifyNumElements(nodes, N);
            testCase.verifyNumElements(weights, N);

            f = @(x) sin(10*x);
            numerical = sum(f(nodes) .* weights);
            analytical = 0;
            testCase.verifyEqual(numerical, analytical, ...
                AbsTol=testCase.tolVal);
        end

        function testEdge_reversedInterval(testCase)
            N = 4;
            a = 1;
            b = 0;

            [~, weights] = trap(N, a, b);

            numerical = sum(weights);
            analytical = -1;
            testCase.verifyEqual(numerical, analytical, ...
                AbsTol=testCase.tolVal);
        end

        %% Error Condition Tests
        function testError_nonPositiveN(testCase)
            testCase.verifyError(@() trap(0, 0, 1), ...
                "MATLAB:validators:mustBePositive");
            testCase.verifyError(@() trap(-1, 0, 1), ...
                "MATLAB:validators:mustBePositive");
        end

        function testError_nonFiniteBounds(testCase)
            testCase.verifyError(@() trap(5, inf, 1), ...
                "MATLAB:validators:mustBeFinite");
            testCase.verifyError(@() trap(5, 0, nan), ...
                "MATLAB:validators:mustBeFinite");
        end
    end
end