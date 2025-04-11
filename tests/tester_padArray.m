classdef tester_padArray < matlab.unittest.TestCase
    % Unit tests for updated "padArray" function.
    %
    % Author: Matt Dvorsky

    methods (Test)
        %% Basic Functionality Tests
        function test_basic1DPadding1(testCase)
            A = [1, 2, 3].';
            x = [0, 10, 20];

            [A_pad, x_pad] = padArray(A, x, PadCount=2);

            testCase.verifySize(A_pad, [5, 1]);
            testCase.verifyEqual(A_pad, [0, 1, 2, 3, 0].');
            testCase.verifySize(x_pad, [5, 1]);
            testCase.verifyEqual(x_pad, [-10, 0, 10, 20, 30].');
        end

        function test_basic1DPadding2(testCase)
            A = [1, 2, 3];
            y = [0, 10, 20];

            [A_pad, ~, y_pad] = padArray(A, [], y, PadCount=[0, 2]);

            testCase.verifySize(A_pad, [1, 5]);
            testCase.verifyEqual(A_pad, [0, 1, 2, 3, 0]);
            testCase.verifySize(y_pad, [1, 5]);
            testCase.verifyEqual(y_pad, [-10, 0, 10, 20, 30]);
        end

        function test_basic2DPadding(testCase)
            A = [1, 2; 3, 4];
            x = [10, 20];
            y = [30, 40];

            [A_pad, x_pad, y_pad] = padArray(A, x, y, PadCount=[1, 2]);

            testCase.verifySize(A_pad, [3, 4]);
            testCase.verifyEqual(A_pad, [0, 0, 0, 0; 0, 1, 2, 0; 0, 3, 4, 0]);
            testCase.verifyEqual(x_pad, [0, 10, 20].');
            testCase.verifyEqual(y_pad, [20, 30, 40, 50]);
        end

        %% Direction Option Tests
        function test_preDirection(testCase)
            A = [1, 2, 3].';
            x = [10, 20, 30];

            [A_pad, x_pad] = padArray(A, x, PadCount=2, Direction="pre");

            testCase.verifyEqual(A_pad, [0, 0, 1, 2, 3].');
            testCase.verifyEqual(x_pad, [-10, 0, 10, 20, 30].');
        end

        function test_postDirection(testCase)
            A = [1, 2, 3].';
            x = [10, 20, 30];

            [A_pad, x_pad] = padArray(A, x, PadCount=2, Direction="post");

            testCase.verifyEqual(A_pad, [1, 2, 3, 0, 0].');
            testCase.verifyEqual(x_pad, [10, 20, 30, 40, 50].');
        end

        function test_bothDirection(testCase)
            A = [1, 2, 3].';
            x = [10, 20, 30];

            [A_pad, x_pad] = padArray(A, x, PadCount=2, Direction="both");

            testCase.verifyEqual(A_pad, [0, 0, 1, 2, 3, 0, 0].');
            testCase.verifyEqual(x_pad, [-10, 0, 10, 20, 30, 40, 50].');
        end

        function test_mixedDirections(testCase)
            A = [1, 2; 3, 4];
            x = [0, 5];
            y = [30, 40];

            [A_pad, x_pad, y_pad] = padArray(A, x, y, ...
                PadCount=[1, 3], Direction=["both", "split"]);

            testCase.verifyEqual(A_pad, [...
                0, 0, 0, 0, 0; ...
                0, 0, 1, 2, 0; ...
                0, 0, 3, 4, 0; ...
                0, 0, 0, 0, 0]);
            testCase.verifyEqual(x_pad, [-5, 0, 5, 10].');
            testCase.verifyEqual(y_pad, [10, 20, 30, 40, 50]);
        end

        function test_percentPadding(testCase)
            A = [1, 2, 3; 4, 5, 6];
            x = [10, 20];
            y = [30, 40, 50];

            [A_pad, x_pad, y_pad] = padArray(A, x, y, PadPercent=100);

            testCase.verifyEqual(A_pad, [...
                0, 0, 0, 0, 0, 0; ...
                0, 0, 1, 2, 3, 0; ...
                0, 0, 4, 5, 6, 0; ...
                0, 0, 0, 0, 0, 0]);
            testCase.verifyEqual(x_pad, [0, 10, 20, 30].');
            testCase.verifyEqual(y_pad, [10, 20, 30, 40, 50, 60]);
        end

        %% Error Condition Tests
        function testError_coordSizeMismatch(testCase)
            A = [1, 2, 3; 4, 5, 6];
            x = [10, 20, 30];  % Wrong size (should be 2 elements)

            testCase.verifyError(...
                @() padArray(A, x), ...
                "CNDE:mustHaveValidCoordinateVectors");
        end

        function testError_invalidPadSpec(testCase)
            A = [1, 2; 3, 4];
            x = [10, 20];
            y = [30, 40];

            testCase.verifyError(...
                @() padArray(A, x, y, PadCount=[1, 2, 3]), ...
                "CNDE:padArrayMustBeValidPadSpec");
        end

        function testError_tooManyOutputs(testCase)
            function testFun()
                [~, ~, ~, ~] = padArray(zeros(2, 3, 4), [], [], PadCount=2);
            end

            testCase.verifyError(@testFun, ...
                "MATLAB:unassignedOutputs")
        end

        function testError_tooManyInputCoords(testCase)
            testCase.verifyError(@() padArray(zeros(2), [], [], [], 1:2, PadCount=2), ...
                "CNDE:mustHaveValidCoordinateVectors")
        end

        %% Edge Case Tests
        function testEdge_noPadding(testCase)
            A = [1, 2, 3].';
            x = [10, 20, 30].';

            [A_pad, x_pad] = padArray(A, x, PadCount=0);

            testCase.verifyEqual(A_pad, A);
            testCase.verifyEqual(x_pad, x);
        end

        function testEdge_emptyCoords(testCase)
            A = [1, 2, 3].';

            [A_pad, x_pad] = padArray(A, [], PadCount=2);

            testCase.verifyEqual(A_pad, [0, 1, 2, 3, 0].');
            testCase.verifyEmpty(x_pad);
        end

        function testEdge_3DPadding(testCase)
            A = rand(2, 3, 4);
            x = [10, 20];
            y = [30, 40, 50];
            z = [60, 70, 80, 90];

            [A_pad, x_pad, y_pad, z_pad] = padArray(A, x, y, z, ...
                PadPercent=[50, 100, 0], Direction=["split", "both", "pre"]);

            testCase.verifySize(A_pad, [3, 9, 4]);
            testCase.verifyEqual(x_pad, [0, 10, 20].');
            testCase.verifyEqual(y_pad, 0:10:80);
            testCase.verifySize(z_pad, [1, 1, 4]);
            testCase.verifyEqual(z_pad(:), z(:));
        end

        function testEdge_emptyArray(testCase)
            A = zeros(0, 3, 0);
            y = [10, 20, 30];

            [A_pad, x_pad, y_pad] = padArray(A, [], y, PadCount=2);

            testCase.verifySize(A_pad, [2, 5, 0]);
            testCase.verifyEmpty(x_pad);
            testCase.verifyEqual(y_pad, [0, 10, 20, 30, 40]);
        end

        function testEdge_extraDims(testCase)
            A = zeros(2, 3, 4);
            x = [10, 20];
            y = [10, 20, 30];

            [A_pad, ~, ~] = padArray(A, x, y, PadCount=2);

            testCase.verifySize(A_pad, [4, 5, 4]);
        end

        function testEdge_singletonDims(testCase)
            A = zeros(1, 3, 4);
            x = 10;
            y = [10, 20, 30];

            [A_pad, ~, ~] = padArray(A, x, y, PadCount=2);

            testCase.verifySize(A_pad, [3, 5, 4]);
        end

        function testEdge_zerosDimsWithOutput(testCase)
            A = zeros(0, 3, 4);
            x = [];
            y = [10, 20, 30];

            [A_pad, x_pad, ~] = padArray(A, x, y, PadCount=2);

            testCase.verifyEqual(A_pad, zeros(2, 5, 4));
            testCase.verifyEmpty(x_pad);
        end
    end
end