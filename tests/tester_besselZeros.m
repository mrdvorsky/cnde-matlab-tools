classdef tester_besselZeros < matlab.unittest.TestCase
    % Cross check unit tests for the "bessel(j,y,j',y')Zeros" functions.
    %
    % Author: Matt Dvorsky

    methods (Test)
        %% Compare Orderings of all Bessel(j,y,j',y') Function Zeros
        function test_compare_jpvn_yvn_ypvn_jvn_v1(testCase)
            v = 1;
            n(:, 1) = 1:1000;

            jpvn = besseljPrimeZeros(v, n);
            yvn = besselyZeros(v, n);
            ypvn = besselyPrimeZeros(v, n);
            jvn = besseljZeros(v, n);

            zerosInOrder = reshape([jpvn, yvn, ypvn, jvn].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must be in order relative to each other.");
        end

        function test_compare_jpvn_yvn_ypvn_jvn_v2(testCase)
            v = 2;
            n(:, 1) = 1:1000;

            jpvn = besseljPrimeZeros(v, n);
            yvn = besselyZeros(v, n);
            ypvn = besselyPrimeZeros(v, n);
            jvn = besseljZeros(v, n);

            zerosInOrder = reshape([jpvn, yvn, ypvn, jvn].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must be in order relative to each other.");
        end

        function test_compare_jpvn_yvn_ypvn_jvn_v10(testCase)
            v = 10;
            n(:, 1) = 1:1000;

            jpvn = besseljPrimeZeros(v, n);
            yvn = besselyZeros(v, n);
            ypvn = besselyPrimeZeros(v, n);
            jvn = besseljZeros(v, n);

            zerosInOrder = reshape([jpvn, yvn, ypvn, jvn].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must be in order relative to each other.");
        end

        function test_compare_jpvn_yvn_ypvn_jvn_v10000(testCase)
            v = 10000;
            n(:, 1) = 1:1000;

            jpvn = besseljPrimeZeros(v, n);
            yvn = besselyZeros(v, n);
            ypvn = besselyPrimeZeros(v, n);
            jvn = besseljZeros(v, n);

            zerosInOrder = reshape([jpvn, yvn, ypvn, jvn].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must be in order relative to each other.");
        end

        function test_compare_jpvn_yvn_ypvn_jvn_vOneHalf(testCase)
            v = 0.5;
            n(:, 1) = 1:1000;

            jpvn = besseljPrimeZeros(v, n);
            yvn = besselyZeros(v, n);
            ypvn = besselyPrimeZeros(v, n);
            jvn = besseljZeros(v, n);

            zerosInOrder = reshape([jpvn, yvn, ypvn, jvn].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must be in order relative to each other.");
        end

        function test_compare_jpvn_yvn_ypvn_jvn_vSmall(testCase)
            v = 0.1;
            n(:, 1) = 1:1000;

            jpvn = besseljPrimeZeros(v, n);
            yvn = besselyZeros(v, n);
            ypvn = besselyPrimeZeros(v, n);
            jvn = besseljZeros(v, n);

            zerosInOrder = reshape([jpvn, yvn, ypvn, jvn].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must be in order relative to each other.");
        end

        function test_compare_jpvn_yvn_ypvn_jvn_v0(testCase)
            v = 0;
            n(:, 1) = 1:1000;

            jpvn = besseljPrimeZeros(v, n);
            yvn = besselyZeros(v, n);
            ypvn = besselyPrimeZeros(v, n);
            jvn = besseljZeros(v, n);

            % For zero order, jpvn should be larger, due to the convention
            % of having the first zero of J0'(x) be non-zero.
            zerosInOrder = reshape([yvn, ypvn, jvn, jpvn].', [], 1);
            testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                "Bessel function zeros must be in order relative to each other.");
        end

        function test_compare_jpvn_yvn_ypvn_jvn_vVariable(testCase)
            n(:, 1) = 1:20;
            for v = 0.5:0.5:100
                jpvn = besseljPrimeZeros(v, n);
                yvn = besselyZeros(v, n);
                ypvn = besselyPrimeZeros(v, n);
                jvn = besseljZeros(v, n);

                zerosInOrder = reshape([jpvn, yvn, ypvn, jvn].', [], 1);
                testCase.verifyReturnsTrue(@() issorted(zerosInOrder), ...
                    sprintf("Bessel function zeros (with v = %g) " + ...
                    "must be in order relative to each other.", v));
            end
        end
    end
end