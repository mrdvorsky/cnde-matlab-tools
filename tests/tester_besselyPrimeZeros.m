classdef tester_besselyPrimeZeros < matlab.unittest.TestCase
    % Unit tests for "besselyPrimeZeros" function.
    %
    % Author: Matt Dvorsky

    properties
        tolVal = 1e-14;

        v0 = [0, 1, 2, 10, 0.5, 1000, 10000];
        jzero0 = [...
            2.197141326031017, ...
            3.683022856585178, ...
            5.002582931446064, ...
            14.35301374369987, ...
            2.975086321688279, ...
            1018.304921954356, ...
            10039.27799214372, ...
            ];
    end

    methods (Test)
        %% Basic Functionality Tests
        function test_firstZero(testCase)
            v = testCase.v0(:);
            z0Actual = arrayfun(@(n) besselyPrimeZeros(n, 1), v);
            z0Exp = testCase.jzero0(:);

            tableActual = table(v(:), z0Actual(:), besselyPrime(v(:), z0Actual(:)), ...
                VariableNames=["v", "z0", "f(z0)"]);

            tableExp = table(v(:), z0Exp, 0*z0Exp(:), ...
                VariableNames=["v", "z0", "f(z0)"]);

            testCase.verifyEqual(tableActual, tableExp, ...
                RelTol=testCase.tolVal, AbsTol=testCase.tolVal);
        end

        %% Edge Case Tests
        function testEdge_decreasingSpacing_vGreaterThanOneHalf(testCase)
            v = 0.51;
            nZeros = 1000;

            jzeros = besselyPrimeZeros(v, nZeros);
            testCase.verifyLessThanOrEqual(diff(jzeros, 2), 0, ...
                "Spacing of zeros must be monotonically decreasing.");
        end

        function testEdge_decreasingSpacing_vLarge(testCase)
            v = 1000;
            nZeros = 1000;

            jzeros = besselyPrimeZeros(v, nZeros);
            testCase.verifyLessThanOrEqual(diff(jzeros, 2), 0, ...
                "Spacing of zeros must be monotonically decreasing.");
        end

        function testEdge_decreasingSpacing_vZero(testCase)
            v = 0;
            nZeros = 1000;

            jzeros = besselyPrimeZeros(v, nZeros);
            testCase.verifyLessThanOrEqual(diff(jzeros, 2), 0, ...
                "Spacing of zeros must be monotonically increasing.");
        end

        %% Assert Interleaving Property of Bessel Function Zeros
        function test_compare_ypvm_interleaving_v0(testCase)
            v = 0;
            nZeros = 1000;

            ypvm = besselyPrimeZeros(v, nZeros);
            ypvplus1m = besselyPrimeZeros(v + 1, nZeros);

            zerosInOrder = reshape([ypvm, ypvplus1m].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");
        end

        function test_compare_ypvm_interleaving_v1(testCase)
            v = 1;
            nZeros = 1000;

            ypvm = besselyPrimeZeros(v, nZeros);
            ypvplus1m = besselyPrimeZeros(v + 1, nZeros);

            zerosInOrder = reshape([ypvm, ypvplus1m].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");
        end

        function test_compare_ypvm_interleaving_vOneHalf(testCase)
            v = 0.5;
            nZeros = 1000;

            ypvm = besselyPrimeZeros(v, nZeros);
            ypvplus1m = besselyPrimeZeros(v + 1, nZeros);

            zerosInOrder = reshape([ypvm, ypvplus1m].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");
        end

        function test_compare_ypvm_interleaving_v10000(testCase)
            v = 10000;
            nZeros = 1000;

            ypvm = besselyPrimeZeros(v, nZeros);
            ypvplus1m = besselyPrimeZeros(v + 1, nZeros);

            zerosInOrder = reshape([ypvm, ypvplus1m].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must interlace properly.");
        end

        function test_compare_ypvm_interleaving_vVariable(testCase)
            for v = 0.5:0.5:100
                nZeros = 20;

                ypvm = besselyPrimeZeros(v, nZeros);
                ypvplus1m = besselyPrimeZeros(v + 1, nZeros);

                zerosInOrder = reshape([ypvm, ypvplus1m].', [], 1);
                testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                    "Bessel function zeros must interlace properly.");
            end
        end

        %% Error Condition Tests
        function testError_nonPositiveN(testCase)
            testCase.verifyError(@() besselyPrimeZeros(0, 0), ...
                "MATLAB:validators:mustBePositive");
            testCase.verifyError(@() besselyPrimeZeros(0, -1), ...
                "MATLAB:validators:mustBePositive");
        end

        function testError_nonIntegerN(testCase)
            testCase.verifyError(...
                @() besselyPrimeZeros(0, 1.5), ...
                "MATLAB:validators:mustBeInteger");
        end

        function testError_negativeNu(testCase)
            testCase.verifyError(...
                @() besselyPrimeZeros(-0.1, 1), ...
                "MATLAB:validators:mustBeNonnegative");
        end

        function testError_nonfiniteNu(testCase)
            testCase.verifyError(...
                @() besselyPrimeZeros(inf, 1), ...
                "MATLAB:validators:mustBeFinite");
        end
    end
end