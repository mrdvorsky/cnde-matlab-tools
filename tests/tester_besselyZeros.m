classdef tester_besselyZeros < matlab.unittest.TestCase
    % Unit tests for "besselyZeros" function.
    %
    % Author: Matt Dvorsky

    properties
        tolVal = 1e-14;

        v0 = [0, 1, 2, 10, 0.5, 1000, 10000];
        jzero0 = [...
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
            v = testCase.v0(:);
            z0Actual = arrayfun(@(n) besselyZeros(n, 1), v);
            z0Exp = testCase.jzero0(:);

            tableActual = table(v(:), z0Actual(:), bessely(v(:), z0Actual(:)), ...
                VariableNames=["v", "z0", "f(z0)"]);

            tableExp = table(v(:), z0Exp, 0*z0Exp(:), ...
                VariableNames=["v", "z0", "f(z0)"]);

            testCase.verifyEqual(tableActual, tableExp, ...
                RelTol=testCase.tolVal, AbsTol=testCase.tolVal);
        end

        %% Assert Interleaving Property of Bessel Function Zeros
        function test_compare_jvm_interleaving_v0(testCase)
            v = 0;
            nZeros = 1000;

            yvm = besselyZeros(v, nZeros);
            yvplus1m = besselyZeros(v + 1, nZeros);

            zerosInOrder = reshape([yvm, yvplus1m].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");
        end

        function test_compare_jvm_interleaving_v1(testCase)
            v = 1;
            nZeros = 1000;

            yvm = besselyZeros(v, nZeros);
            yvplus1m = besselyZeros(v + 1, nZeros);

            zerosInOrder = reshape([yvm, yvplus1m].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");
        end

        function test_compare_jvm_interleaving_vOneHalf(testCase)
            v = 0.5;
            nZeros = 1000;

            yvm = besselyZeros(v, nZeros);
            yvplus1m = besselyZeros(v + 1, nZeros);

            zerosInOrder = reshape([yvm, yvplus1m].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");
        end

        function test_compare_jvm_interleaving_v10000(testCase)
            v = 10000;
            nZeros = 1000;

            yvm = besselyZeros(v, nZeros);
            yvplus1m = besselyZeros(v + 1, nZeros);

            zerosInOrder = reshape([yvm, yvplus1m].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");
        end

        function test_compare_yvm_interleaving_vVariable(testCase)
            for v = 0.5:0.5:100
                nZeros = 20;

                yvm = besselyZeros(v, nZeros);
                yvplus1m = besselyZeros(v + 1, nZeros);

                zerosInOrder = reshape([yvm, yvplus1m].', [], 1);
                testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                    "Bessel function zeros must interlace properly.");
            end
        end

        %% Edge Case Tests
        function testEdge_decreasingSpacing_vGreaterThanOneHalf(testCase)
            v = 0.51;
            nZeros = 1000;

            jzeros = besselyZeros(v, nZeros);
            testCase.verifyLessThanOrEqual(diff(jzeros, 2), 0, ...
                "Spacing of zeros must be monotonically decreasing.");
        end

        function testEdge_increasingSpacing_vLessThanOneHalf(testCase)
            v = 0.49;
            nZeros = 1000;

            jzeros = besselyZeros(v, nZeros);
            testCase.verifyGreaterThanOrEqual(diff(jzeros, 2), 0, ...
                "Spacing of zeros must be monotonically increasing.");
        end

        function testEdge_decreasingSpacing_vLarge(testCase)
            v = 1000;
            nZeros = 1000;

            jzeros = besselyZeros(v, nZeros);
            testCase.verifyLessThanOrEqual(diff(jzeros, 2), 0, ...
                "Spacing of zeros must be monotonically decreasing.");
        end

        function testEdge_increasingSpacing_vZero(testCase)
            v = 0;
            nZeros = 1000;

            jzeros = besselyZeros(v, nZeros);
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