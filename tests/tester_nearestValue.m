classdef tester_nearestValue < matlab.unittest.TestCase
    % Unit tests for "nearestValue" function.
    %
    % Author: Matt Dvorsky

    methods (Test)
        %% Basic Functionality Tests
        function test_1DVector1(testCase)
            xSearch = 10:10:100;
            x = [12, 25, 38, 99];

            xNearest = nearestValue(xSearch, x);

            testCase.verifyEqual(xNearest, [10, 20, 40, 100]);
        end

        function test_1DVector2(testCase)
            xSearch = flip(10:10:100);
            x = [12, 25, 38, 99];

            xNearest = nearestValue(xSearch, x);

            testCase.verifyEqual(xNearest, [10, 30, 40, 100]);
        end

        function test_2DMatrix1(testCase)
            xSearch = [1, 3; 2, 4];
            x = [1.1, 2.9, 3.5];

            xNearest = nearestValue(xSearch, x);

            testCase.verifyEqual(xNearest, [1, 3, 3]);
        end

        function test_2DMatrix2(testCase)
            xSearch = [1, 2; 4, 3];
            x = [1.1, 2.9, 3.5].';

            xNearest = nearestValue(xSearch, x);

            testCase.verifyEqual(xNearest, [1, 3, 4].');
        end

        function test_outputType(testCase)
            xSearch = single([1, 2, 3]);
            x = 2.1;

            xNearest = nearestValue(xSearch, x);

            testCase.verifyClass(xNearest, "single");
            testCase.verifyEqual(xNearest, single(2));
        end

        %% Edge Case Tests
        function testEdge_exactMatch(testCase)
            xSearch = [10, 20, 30];
            x = [10, 20, 30];

            xNearest = nearestValue(xSearch, x);

            testCase.verifyEqual(xNearest, x);
        end

        function testEdge_singleValueSearchSpace(testCase)
            xSearch = 5;
            x = [4, 5, 6];

            xNearest = nearestValue(xSearch, x);

            testCase.verifyEqual(xNearest, [5, 5, 5]);
        end

        function testEdge_emptyInput(testCase)
            xSearch = [1 2 3];
            x = [];

            xNearest = nearestValue(xSearch, x);

            testCase.verifyEmpty(xNearest);
        end

        %% Error Condition Tests
        function testError_emptySearchSpace(testCase)
            testCase.verifyError(@() nearestValue([], 5), ...
                "MATLAB:validators:mustBeNonempty");
        end
    end
end