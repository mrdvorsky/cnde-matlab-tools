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
            % Test integration of constant function
            N = 5;
            [nodes, weights] = fejer2(N, 0, 1);
            integral = sum(weights);
            testCase.verifyEqual(integral, 1, ...
                AbsTol=testCase.tolVal);

            % Test integration of linear function
            f = @(x) x;
            integral = sum(f(nodes) .* weights);
            testCase.verifyEqual(integral, 0.5, ...
                AbsTol=testCase.tolVal);
        end

        function test_polynomialExactness(testCase)
            % Test exact integration of polynomials up to degree N-1
            N = 7;
            a = -1;
            b = 2;

            for degree = 0:N-1
                coeffs = rand(1, degree + 1);
                polyFun = @(x) polyval(coeffs, x);

                [nodes, weights] = fejer2(N, a, b);
                numerical = sum(polyFun(nodes) .* weights);

                % Analytical integral
                analytical = diff(polyval(polyint(coeffs), [a, b]));

                testCase.verifyEqual(numerical, analytical, ...
                    sprintf("Failed for degree %d polynomial", degree), ...
                    AbsTol=testCase.tolVal);
            end
        end

        function test_weightingFunction(testCase)
            % Test integration with weighting function
            N = 15;
            a = 0;
            b = pi;

            % Weighting function w(x) = sin(x)
            wFun = @(x) sin(x);
            fFun = @(x) x.^2;  % Function to integrate

            [nodes, weights] = fejer2(N, a, b, WeightingFunction=wFun, ...
                IntegralRelTol=1e-9);
            numerical = sum(fFun(nodes) .* weights);

            % Analytical integral of x^2 * sin(x) from 0 to pi
            analytical = pi^2 - 4;

            testCase.verifyEqual(numerical, analytical, ...
                AbsTol=1e-9);  % Lower tolerance due to numerical integration
        end

        function test_weightingMoments(testCase)
            % Test integration with precomputed moments
            N = 10;
            a = -1;
            b = 1;

            % For w(x) = 1, moments are known analytically
            n = (1:N)';
            weightingMoments = (1 - (-1).^n) ./ n;

            [nodes, weights] = fejer2(N, a, b, ...
                WeightingMoments=weightingMoments);

            % Integrate x^2
            integral = sum(nodes.^2 .* weights);
            testCase.verifyEqual(integral, 2/3, ...
                AbsTol=testCase.tolVal);
        end

        function test_complexInterval(testCase)
            % Test integration along complex path
            N = 20;
            a = 0;
            b = 1 + 1i;

            f = @(z) z.^2;

            [nodes, weights] = fejer2(N, a, b);
            numerical = sum(f(nodes) .* weights);

            % Analytical integral of z^2 from 0 to 1+i
            analytical = (1/3)*(b^3 - a^3);

            testCase.verifyEqual(numerical, analytical, ...
                AbsTol=testCase.tolVal);
        end

        %% Error Estimation Tests
        function test_errorEstimation(testCase)
            % Test error estimation weights
            N = 21;  % Must be odd for error weights
            a = 0;
            b = 1;

            [nodes, ~, errorWeights] = fejer2(N, a, b);

            % For a linear function, error should be zero
            f = @(x) x;
            errEst = sum(f(nodes) .* errorWeights);
            testCase.verifyEqual(errEst, 0, ...
                AbsTol=testCase.tolVal);

            % For a higher order function, error estimate should be non-zero
            f = @(x) x.^N;  % Function with degree N
            errEst = sum(f(nodes) .* errorWeights);
            testCase.verifyTrue(abs(errEst) > 0);
        end

        %% Edge Case Tests
        function test_minimumN(testCase)
            % Test with minimum N value (N=1)
            N = 1;
            [nodes, weights] = fejer2(N, 0, 1);

            testCase.verifyNumElements(nodes, 1);
            testCase.verifyNumElements(weights, 1);

            % Should integrate constants exactly
            integral = sum(weights);
            testCase.verifyEqual(integral, 1, ...
                AbsTol=testCase.tolVal);
        end

        function test_largeN(testCase)
            % Test with large N value
            N = 101;
            [nodes, weights] = fejer2(N, 0, 1);

            testCase.verifyNumElements(nodes, N);
            testCase.verifyNumElements(weights, N);

            % Should integrate oscillatory function well
            f = @(x) sin(50*pi*x);
            integral = sum(f(nodes) .* weights);
            testCase.verifyEqual(integral, 0, ...
                AbsTol=testCase.tolVal);
        end

        function test_reversedInterval(testCase)
            % Test with reversed interval (b < a)
            N = 5;
            a = 1;
            b = 0;

            [~, weights] = fejer2(N, a, b);
            integral = sum(weights);

            testCase.verifyEqual(integral, -1, ...
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

        function testError_insufficientWeightingMoments(testCase)
            % Should error if WeightingMoments has wrong size
            testCase.verifyError(@() fejer2(5, 0, 1, ...
                WeightingMoments=ones(3, 1)), ...
                "fejer2:incorrectWeightingMomentsSize");
        end
    end
end