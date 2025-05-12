classdef tester_gaussLegendre < matlab.unittest.TestCase
    % Unit tests for "gaussLegendre" function.
    %
    % Author: Matt Dvorsky

    properties
        tolVal = 1e-10;
    end

    methods (Test)
        %% Basic Functionality Tests
        function test_basicIntegration(testCase)
            N = 5;
            a = 0;
            b = 1;

            [nodes, weights] = gaussLegendre(N, a, b);

            % Test integration of constant function
            numerical = sum(weights);
            analytical = 1;
            testCase.verifyEqual(numerical, analytical, ...
                AbsTol=testCase.tolVal);

            % Test integration of linear function
            f = @(x) x;
            numerical = sum(f(nodes) .* weights);
            analytical = 0.5;
            testCase.verifyEqual(numerical, analytical, ...
                AbsTol=testCase.tolVal);
        end

        function test_polynomialExactness(testCase)
            N = 7;
            a = -1;
            b = 2;

            % Gauss-Legendre should be exact for polys up to degree 2N-1
            for degree = 0:(2*N - 1)
                coeffs = rand(1, degree + 1);
                polyFun = @(x) polyval(coeffs, x);

                [nodes, weights] = gaussLegendre(N, a, b);

                numerical = sum(polyFun(nodes) .* weights);
                analytical = diff(polyval(polyint(coeffs), [a, b]));
                testCase.verifyEqual(numerical, analytical, ...
                    sprintf("Failed for degree %d polynomial", degree), ...
                    AbsTol=testCase.tolVal);
            end
        end

        function test_complexInterval(testCase)
            N = 10;
            a = 0;
            b = 1 + 1i;

            fFun = @(z) z.^2;

            [nodes, weights] = gaussLegendre(N, a, b);

            numerical = sum(fFun(nodes) .* weights);
            analytical = (1/3)*(b^3 - a^3);
            testCase.verifyEqual(numerical, analytical, ...
                AbsTol=testCase.tolVal);
        end

        %% Edge Case Tests
        function testEdge_minimumN(testCase)
            N = 1;
            a = 0;
            b = 1;

            [nodes, weights] = gaussLegendre(N, a, b);

            testCase.verifyNumElements(nodes, 1);
            testCase.verifyNumElements(weights, 1);

            numerical = sum(weights);
            analytical = 1;
            testCase.verifyEqual(numerical, analytical, ...
                AbsTol=testCase.tolVal);
        end

        function testEdge_largeN(testCase)
            N = 100;
            a = 0;
            b = 1;

            [nodes, weights] = gaussLegendre(N, a, b);

            testCase.verifyNumElements(nodes, N);
            testCase.verifyNumElements(weights, N);

            f = @(x) exp(x);
            numerical = sum(f(nodes) .* weights);
            analytical = exp(1) - 1;
            testCase.verifyEqual(numerical, analytical, ...
                AbsTol=testCase.tolVal);
        end

        function testEdge_reversedInterval(testCase)
            N = 5;
            a = 1;
            b = 0;

            [~, weights] = gaussLegendre(N, a, b);

            numerical = sum(weights);
            analytical = -1;
            testCase.verifyEqual(numerical, analytical, ...
                AbsTol=testCase.tolVal);
        end

        %% Error Condition Tests
        function testError_nonPositiveN(testCase)
            testCase.verifyError(@() gaussLegendre(0, 0, 1), ...
                "MATLAB:validators:mustBePositive");
            testCase.verifyError(@() gaussLegendre(-1, 0, 1), ...
                "MATLAB:validators:mustBePositive");
        end

        function testError_nonFiniteBounds(testCase)
            testCase.verifyError(@() gaussLegendre(5, inf, 1), ...
                "MATLAB:validators:mustBeFinite");
            testCase.verifyError(@() gaussLegendre(5, 0, nan), ...
                "MATLAB:validators:mustBeFinite");
        end
    end
end