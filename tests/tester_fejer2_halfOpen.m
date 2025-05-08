classdef tester_fejer2_halfOpen < matlab.unittest.TestCase
    % Unit tests for "fejer2_halfOpen" function.
    %
    % Author: Matt Dvorsky

    properties
        tolVal = 1e-8;
    end

    methods (Test)
        %% Basic Functionality Tests
        function test_basicIntegrationNoWeight(testCase)
            N = 60;
            L = 0.5;
            a = 0;

            [nodes, weights] = fejer2_halfOpen(N, L, a);

            f = @(x) exp(-x);

            numerical = sum(f(nodes) .* weights);
            analytical = 1;
            testCase.verifyEqual(numerical, analytical, ...
                AbsTol=testCase.tolVal);
        end

        function test_weightingFunction(testCase)
            N = 10;
            L = 0.5;
            a = 0;

            % Weighting function w(x) = exp(-x)
            w = @(x) exp(-x);
            f = @(x) 1 ./ (1 + x);

            [nodes, weights] = fejer2_halfOpen(N, L, a, ...
                WeightingFunction=w);

            numerical = sum(f(nodes) .* weights);
            analytical = 0.5963473623231940743;
            testCase.verifyEqual(numerical, analytical, ...
                AbsTol=testCase.tolVal);
        end

        function test_weightingFunctionOffset(testCase)
            N = 15;
            L = 0.5;
            a = 1;

            % Weighting function w(x) = exp(-x)
            w = @(x) exp(-x);
            f = @(x) 1 ./ (1 + x);

            [nodes, weights] = fejer2_halfOpen(N, L, a, ...
                WeightingFunction=w);

            numerical = sum(f(nodes) .* weights);
            analytical = 0.13292536966008950088;
            testCase.verifyEqual(numerical, analytical, ...
                AbsTol=testCase.tolVal);
        end

        function test_weightingMoments(testCase)
            N = 3;
            L = 1;
            a = 0;

            w = @(x) sinc(x);
            f = @(x) 1 ./ (1 + x);

            % Moments calculated externally.
            moments = 2*[pi/4, -0.327888, -0.390815];

            [nodes, weights] = fejer2_halfOpen(N, L, a, ...
                WeightingMoments=moments);

            numerical = sum(f(nodes) .* weights);
            analytical = 0.9493467025590832615;
            testCase.verifyEqual(numerical, analytical, ...
                AbsTol=1e-5);   % Lower due to tolerance of moments
        end

        %% Error Estimation Tests
        function test_errorEstimation(testCase)
            N = 10;
            L = 0.5;
            a = 0;

            [x1, w1] = fejer2_halfOpen(N, L, a);
            [x2, w2, ewActual] = fejer2_halfOpen(2*N + 1, L, a);

            ewExpected = w2;
            ewExpected(2:2:end) = ewExpected(2:2:end) - w1;

            testCase.verifyEqual(ewActual, ewExpected, ...
                AbsTol=testCase.tolVal);
            testCase.verifyEqual(x1, x2(2:2:end), ...
                AbsTol=testCase.tolVal);
        end

        %% Edge Case Tests
        function test_largeN(testCase)
            N = 100;
            L = 1;
            a = 0;

            [nodes, weights] = fejer2_halfOpen(N, L, a);

            testCase.verifyNumElements(nodes, N);
            testCase.verifyNumElements(weights, N);

            f = @(x) exp(-x).*sin(x);
            
            numerical = sum(f(nodes) .* weights);
            analytical = 0.5;
            testCase.verifyEqual(numerical, analytical, ...
                AbsTol=testCase.tolVal);
        end

        %% Error Condition Tests
        function testError_nonPositiveN(testCase)
            testCase.verifyError(@() fejer2_halfOpen(0, 1, 0), ...
                "MATLAB:validators:mustBePositive");
            testCase.verifyError(@() fejer2_halfOpen(-1, 1, 0), ...
                "MATLAB:validators:mustBePositive");
        end

        function testError_nonPositiveL(testCase)
            testCase.verifyError(@() fejer2_halfOpen(5, 0, 0), ...
                "MATLAB:validators:mustBePositive");
            testCase.verifyError(@() fejer2_halfOpen(5, -1, 0), ...
                "MATLAB:validators:mustBePositive");
        end

        function testError_nonFiniteA(testCase)
            testCase.verifyError(@() fejer2_halfOpen(5, 1, inf), ...
                "MATLAB:validators:mustBeFinite");
            testCase.verifyError(@() fejer2_halfOpen(5, 1, nan), ...
                "MATLAB:validators:mustBeFinite");
        end
    end
end

