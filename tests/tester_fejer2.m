classdef tester_fejer2 < matlab.unittest.TestCase
    % Unit tests for "fejer2" function.
    %
    % Author: Matt Dvorsky

    properties
        tolVal = 1e-10;
    end

    methods (Test)
        %% Basic Functionality Tests
        function test_basicIntegrationNoWeight(testCase)
            N = 5;
            a = 0;
            b = 1;

            [nodes, weights] = fejer2(N, a, b);

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

            for degree = 0:(N - 1)
                coeffs = rand(1, degree + 1);
                polyFun = @(x) polyval(coeffs, x);

                [nodes, weights] = fejer2(N, a, b);

                numerical = sum(polyFun(nodes) .* weights);
                analytical = diff(polyval(polyint(coeffs), [a, b]));
                testCase.verifyEqual(numerical, analytical, ...
                    sprintf("Failed for degree %d polynomial", degree), ...
                    AbsTol=testCase.tolVal);
            end
        end

        function test_weightingFunction(testCase)
            N = 15;
            a = 0;
            b = pi;

            % Weighting function w(x) = sin(x)
            w = @(x) sin(x);
            f = @(x) x.^2;

            [nodes, weights] = fejer2(N, a, b, WeightingFunction=w, ...
                IntegralRelTol=1e-9);
            numerical = sum(f(nodes) .* weights);
            analytical = pi^2 - 4;
            testCase.verifyEqual(numerical, analytical, ...
                AbsTol=1e-9);
        end

        function test_weightingMoments(testCase)
            N = 10;
            a = -1;
            b = 1;

            % For w(x) = 5, moments are known analytically
            n = (1:N)';
            weightingMoments = 5 * (1 - (-1).^n) ./ n;

            [nodes, weights] = fejer2(N, a, b, ...
                WeightingMoments=weightingMoments);

            numerical = sum(nodes.^2 .* weights);
            analytical = 5 * 2/3;
            testCase.verifyEqual(numerical, analytical, ...
                AbsTol=testCase.tolVal);
        end

        function test_complexInterval(testCase)
            N = 20;
            a = 0;
            b = 1 + 1i;

            fFun = @(z) z.^2;

            [nodes, weights] = fejer2(N, a, b);

            numerical = sum(fFun(nodes) .* weights);
            analytical = (1/3)*(b^3 - a^3);
            testCase.verifyEqual(numerical, analytical, ...
                AbsTol=testCase.tolVal);
        end

        %% Error Estimation Tests
        function test_errorEstimation1(testCase)
            N = 3;
            a = 0;
            b = 1;

            [nodes, ~, errorWeights] = fejer2(N, a, b);

            % For linear function, error should be zero
            f = @(x) x;
            errEst = sum(f(nodes) .* errorWeights);
            testCase.verifyEqual(errEst, 0, ...
                AbsTol=testCase.tolVal);

            % For higher order function, error estimate should be non-zero
            f = @(x) x.^N;
            errEst = sum(f(nodes) .* errorWeights);
            testCase.verifyTrue(abs(errEst) > 0);
        end

        function test_errorEstimation2(testCase)
            N = 50;
            a = 0;
            b = 1;

            [x1, w1] = fejer2(N, a, b);
            [x2, w2, ewActual] = fejer2(2*N + 1, a, b);

            ewExpected = w2;
            ewExpected(2:2:end) = ewExpected(2:2:end) - w1;

            testCase.verifyEqual(ewActual, ewExpected);
            testCase.verifyEqual(x1, x2(2:2:end));
        end

        %% Edge Case Tests
        function testEdge_minimumN(testCase)
            N = 1;
            a = 0;
            b = 1;

            [nodes, weights] = fejer2(N, a, b);

            testCase.verifyNumElements(nodes, 1);
            testCase.verifyNumElements(weights, 1);

            numerical = sum(weights);
            analytical = 1;
            testCase.verifyEqual(numerical, analytical, ...
                AbsTol=testCase.tolVal);
        end

        function testEdge_largeN(testCase)
            N = 1000;
            a = 0;
            b = 1;

            [nodes, weights] = fejer2(N, a, b);

            testCase.verifyNumElements(nodes, N);
            testCase.verifyNumElements(weights, N);

            f = @(x) sin(50*pi*x);
            numerical = sum(f(nodes) .* weights);
            analytical = 0;
            testCase.verifyEqual(numerical, analytical, ...
                AbsTol=testCase.tolVal);
        end

        function testEdge_reversedInterval(testCase)
            N = 5;
            a = 1;
            b = 0;

            [~, weights] = fejer2(N, a, b);

            numerical = sum(weights);
            analytical = 0;
            testCase.verifyEqual(numerical, analytical, ...
                AbsTol=testCase.tolVal);
        end

        %% Error Condition Tests
        function testError_nonPositiveN(testCase)
            testCase.verifyError(@() fejer2(0, 0, 1), ...
                "MATLAB:validators:mustBePositive");
            testCase.verifyError(@() fejer2(-1, 0, 1), ...
                "MATLAB:validators:mustBePositive");
        end

        function testError_nonFiniteBounds(testCase)
            testCase.verifyError(@() fejer2(5, inf, 1), ...
                "MATLAB:validators:mustBeFinite");
            testCase.verifyError(@() fejer2(5, 0, nan), ...
                "MATLAB:validators:mustBeFinite");
        end

        function testError_weightingMomentsWrongSize(testCase)
            testCase.verifyError(@() fejer2(5, 0, 1, ...
                WeightingMoments=ones(3, 1)), ...
                "fejer2:incorrectWeightingMomentsSize");
        end
    end
end