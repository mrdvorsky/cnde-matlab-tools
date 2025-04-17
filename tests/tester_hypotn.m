classdef tester_hypotn < matlab.unittest.TestCase
    % Unit tests for "hypotn" function.
    %
    % Author: Matt Dvorsky

    methods (Test)
        %% Basic Functionality Tests
        function test_singleInput(testCase)
            x = 5;
            y = hypotn(x);

            testCase.verifyEqual(y, abs(x));
        end

        function test_twoInputs(testCase)
            x = 3;
            y = 4;

            result = hypotn(x, y);
            expected = hypot(x, y);

            testCase.verifyEqual(result, expected);
        end

        function test_threeInputs(testCase)
            x = 3;
            y = 4;
            z = 12;

            result = hypotn(x, y, z);
            expected = hypot(hypot(x, y), z);

            testCase.verifyEqual(result, expected);
            testCase.verifyEqual(result, 13);
        end

        function test_multipleInputs(testCase)
            result = hypotn(2, 3, 6, 7);
            expected = sqrt(2^2 + 3^2 + 6^2 + 7^2);

            testCase.verifyEqual(result, expected, "AbsTol", 1e-14);
        end

        %% Vector/Matrix Input Tests
        function test_vectorInputs(testCase)
            x = [1, 2, 3];
            y = [4, 5, 6];

            result = hypotn(x, y);
            expected = hypot(x, y);

            testCase.verifyEqual(result, expected);
        end

        function test_matrixInputs(testCase)
            x = [1, 2; 3, 4];
            y = [5, 6; 7, 8];

            result = hypotn(x, y);
            expected = hypot(x, y);

            testCase.verifyEqual(result, expected);
        end

        function test_mixedSizeInputs(testCase)
            x = [1, 2, 3];
            y = 4;

            result = hypotn(x, y);
            expected = hypot(x, y);

            testCase.verifyEqual(result, expected);
        end

        function test_broadcasting(testCase)
            x = rand(3, 4, 1);
            y = rand(1, 4, 2);
            z = rand(3, 1, 2) + 1j*rand(3, 1, 2);

            result = hypotn(x, y, z);
            expected = hypot(hypot(x, y), z);

            testCase.verifyEqual(result, expected);
        end

        %% Complex Input Tests
        function test_complexInputs(testCase)
            x = 3 + 4i;

            result = hypotn(x);
            expected = abs(x);

            testCase.verifyEqual(result, expected);
            testCase.verifyEqual(result, 5);
        end

        function test_multipleComplexInputs(testCase)
            x = 3 + 4i;
            y = 5 - 2i;

            result = hypotn(x, y);
            expected = hypot(x, y);

            testCase.verifyEqual(result, expected);
        end

        %% Data Type Tests
        function test_differentDataTypes1(testCase)
            x = single(3 + 4i);
            y = 5 - 2i;
            z = 5;

            result = hypotn(x, y, z);
            expected = hypot(hypot(x, y), z);

            testCase.verifyEqual(result, expected);
        end

        function test_differentDataTypes2(testCase)
            x = 3 + 4i;
            y = 5 - 2i;
            z = single(5);

            result = hypotn(x, y, z);
            expected = hypot(hypot(x, y), z);

            testCase.verifyEqual(result, expected);
        end

        %% Edge Case Tests
        function testEdge_zeroInputs(testCase)
            result = hypotn(0, 0, 0);

            testCase.verifyEqual(result, 0);
        end

        function testEdge_largeInputs(testCase)
            x = 1e150;
            y = 1e150;

            result = hypotn(x, y);
            expected = hypot(x, y);

            testCase.verifyEqual(result, expected);
        end

        function testEdge_smallInputs(testCase)
            x = 1e-150;
            y = 1e-150;

            result = hypotn(x, y);
            expected = hypot(x, y);

            testCase.verifyEqual(result, expected);
        end

        function testEdge_zeroSizeInputs(testCase)
            a = rand(3, 4, 1);
            b = rand(3, 4, 1);
            c = rand(3, 4, 0);

            result = hypotn(a, b, c);
            expected = hypot(hypot(a, b), c);

            testCase.verifyEqual(result, expected);
        end

        %% Error Condition Tests
        function testError_noInputs(testCase)
            testCase.verifyError(@() hypotn(), ...
                "validators:mustHaveAtLeastOneRepeatingArg");
        end

        function testError_incompatibleInputs(testCase)
            a = ones(3, 4, 2);
            b = ones(3, 4, 2);
            c = ones(4, 4, 4);

            testCase.verifyError(@() hypotn(a, b, c), ...
                "MATLAB:sizeDimensionsMustMatch");
        end

        function testError_incompatibleInputsOneEmpty(testCase)
            a = ones(3, 4, 2);
            b = ones(3, 4, 1);
            c = ones(3, 4, 0);

            testCase.verifyError(@() hypotn(a, b, c), ...
                "MATLAB:sizeDimensionsMustMatch");
        end
    end
end