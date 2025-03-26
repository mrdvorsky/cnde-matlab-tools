classdef test_fejer2 < matlab.unittest.TestCase
    % Unit tests for the fejer2 function.
    %
    % Author: Matt Dvorsky

    methods (Test)
        function testPolynomialIntegration(testCase)
            % Test 1: Integrate x^2 over [0, 1] (exact for N >= 3)
            N = 5;
            a = 0;
            b = 1;
            f = @(x) x.^2;
            [nodes, weights] = fejer2(N, a, b);
            q = sum(weights .* f(nodes));
            exact = 1/3;
            testCase.verifyEqual(q, exact, 'AbsTol', 1e-10, ...
                'Polynomial integration failed.');
        end

        function testWeightedIntegration(testCase)
            % Test 2: Integrate sin(x) * exp(-x) over [0, pi]
            N = 10;
            a = 0;
            b = pi;
            f = @(x) sin(x);
            w = @(x) exp(-x);
            [nodes, weights] = fejer2(N, a, b, WeightingFunction=w);
            q = sum(weights .* f(nodes));
            exact = (1 + exp(-pi)) / 2;
            testCase.verifyEqual(q, exact, 'AbsTol', 1e-6, ...
                'Weighted integration failed.');
        end

        function testComplexIntegration(testCase)
            % Test 3: Complex integration of z^2 from 1+i to 2+2i
            N = 10;
            a = 1 + 1i;
            b = 2 + 2i;
            f = @(z) z.^2;
            [nodes, weights] = fejer2(N, a, b);
            q = sum(weights .* f(nodes));
            exact = (1/3) * (b^3 - a^3);
            testCase.verifyEqual(q, exact, 'AbsTol', 1e-10, ...
                'Complex integration failed.');
        end

        function testErrorWeights(testCase)
            % Test 4: Error weights for x^3 over [0, 1]
            N = 7; % Must be odd for error weights
            a = 0;
            b = 1;
            f = @(x) x.^3;
            [nodes, weights, errorWeights] = fejer2(N, a, b);
            q = sum(weights .* f(nodes));
            qErr = sum(errorWeights .* f(nodes));
            exact = 1/4;
            testCase.verifyEqual(q, exact, 'AbsTol', 1e-10, ...
                'Polynomial integration with error weights failed.');
            testCase.verifyLessThan(abs(qErr), 1e-6, ...
                'Error weights failed.');
        end
    end
end