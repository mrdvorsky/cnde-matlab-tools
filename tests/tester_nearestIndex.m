classdef tester_nearestIndex < matlab.unittest.TestCase
    % Unit tests for "nearestIndex" function.
    %
    % Author: Matt Dvorsky

    methods (Test)
        %% Basic Functionality Tests
        function test_1DVector1(testCase)
            xSearch = 10:10:100;
            x = [12, 25, 38, 99];

            xNearestInd = nearestIndex(xSearch, x);

            testCase.verifyEqual(xNearestInd, [1, 2, 4, 10]);
        end

        function test_1DVector2(testCase)
            xSearch = flip(10:10:100);
            x = [12, 25, 38, 99];

            xNearestInd = nearestIndex(xSearch, x);

            testCase.verifyEqual(xNearestInd, [10, 8, 7, 1]);
        end

        function test_2DMatrix1(testCase)
            xSearch = [1, 3; 2, 4];
            x = [1.1, 2.9, 3.5];

            [row, col] = nearestIndex(xSearch, x);
            [indLinear] = nearestIndex(xSearch, x);

            testCase.verifyEqual(row, [1, 1, 1]);
            testCase.verifyEqual(col, [1, 2, 2]);

            testCase.verifyEqual(indLinear, [1, 3, 3]);
        end

        function test_2DMatrix2(testCase)
            xSearch = [1, 4; 2, 3];
            x = [1.1, 2.9, 3.5].';

            [row, col] = nearestIndex(xSearch, x);
            [indLinear] = nearestIndex(xSearch, x);

            testCase.verifyEqual(row, [1, 2, 1].');
            testCase.verifyEqual(col, [1, 2, 2].');

            testCase.verifyEqual(indLinear, [1, 4, 3].');
        end

        function test_3DArray(testCase)
            xSearch = cat(3, [1 2; 3 4], [5 6; 7 8]);
            x = [1.1, 5.9, 7.5];

            [row, col, page] = nearestIndex(xSearch, x);
            [row2, colPage] = nearestIndex(xSearch, x);
            [indLinear] = nearestIndex(xSearch, x);

            testCase.verifyEqual(row, [1, 1, 2]);
            testCase.verifyEqual(col, [1, 2, 1]);
            testCase.verifyEqual(page, [1, 2, 2]);

            testCase.verifyEqual(row2, [1, 1, 2]);
            testCase.verifyEqual(colPage, [1, 4, 3]);

            testCase.verifyEqual(indLinear, [1, 7, 6]);
        end

        %% Edge Case Tests
        function testEdge_exactMatch(testCase)
            xSearch = [10, 20, 30];
            x = [10, 20, 30];

            xNearestInd = nearestIndex(xSearch, x);

            testCase.verifyEqual(xNearestInd, [1, 2, 3]);
        end

        function testEdge_singleValueSearchSpace(testCase)
            xSearch = 5;
            x = [4, 5, 6];

            xNearestInd = nearestIndex(xSearch, x);

            testCase.verifyEqual(xNearestInd, [1, 1, 1]);
        end

        function testEdge_emptyInput(testCase)
            xSearch = [1, 2, 3];
            x = [];

            xNearestInd = nearestIndex(xSearch, x);

            testCase.verifyEmpty(xNearestInd);
        end

        function testEdge_extraOutputs(testCase)
            xSearch = [1, 2; 3, 4];
            x = [1.1, 2.3, 3.7];

            [row, col, page] = nearestIndex(xSearch, x);

            testCase.verifyEqual(row, [1, 1, 2]);
            testCase.verifyEqual(col, [1, 2, 2]);
            testCase.verifyEqual(page, [1, 1, 1]);
        end

        %% Error Condition Tests
        function testError_emptySearchSpace(testCase)
            testCase.verifyError(@() nearestIndex([], 5), ...
                "MATLAB:validators:mustBeNonempty");
        end
    end
end