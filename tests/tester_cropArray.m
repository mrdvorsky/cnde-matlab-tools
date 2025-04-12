classdef tester_cropArray < matlab.unittest.TestCase
    % Unit tests for the "cropArray" function.
    %
    % Author: Matt Dvorsky

    methods (Test)
        %% Basic Functionality Tests
        function test_basic1DCropping1(testCase)
            x = -10:10;
            Img = ones(numel(x), 1);

            [ImgCrop, xCrop] = cropArray(Img, ...
                x, 3, 7);

            testCase.verifySize(ImgCrop, [5, 1]);
            testCase.verifyEqual(xCrop, (3:7).');
        end

        function test_basic1DCropping2(testCase)
            y = -10:10;
            Img = ones(1, numel(y));

            [ImgCrop, xCrop, yCrop] = cropArray(Img, ...
                [], [], [], ...
                y, 0, 5);

            testCase.verifySize(ImgCrop, [1, 6]);
            testCase.verifyEmpty(xCrop);
            testCase.verifyEqual(yCrop, (0:5));
        end

        function test_basic2DCropping(testCase)
            x = 1:10;
            y = -7:2:9;
            Img = ones(numel(x), numel(y));

            [ImgCrop, xCrop, yCrop] = cropArray(Img, ...
                x, 3, 7, ...
                y, -1, 6);

            testCase.verifySize(ImgCrop, [5, 4]);
            testCase.verifyEqual(xCrop, (3:7).');
            testCase.verifyEqual(yCrop, (-1:2:5));
        end

        function test_emptyMin(testCase)
            x = 1:10;
            y = 1:20;
            Img = ones(numel(x), numel(y));

            [ImgCrop, xCrop, yCrop] = cropArray(Img, ...
                x, [], 7, ...
                y, 1, 6);

            testCase.verifySize(ImgCrop, [7, 6]);
            testCase.verifyEqual(xCrop, (1:7).');
            testCase.verifyEqual(yCrop, (1:6));
        end

        function test_emptyMax(testCase)
            x = 1:10;
            y = 1:20;
            Img = ones(numel(x), numel(y));

            [ImgCrop, xCrop, yCrop] = cropArray(Img, ...
                x, 2, 7, ...
                y, 5, []);

            testCase.verifySize(ImgCrop, [6, 16]);
            testCase.verifyEqual(xCrop, (2:7).');
            testCase.verifyEqual(yCrop, (5:20));
        end

        function test_basic3DCropping(testCase)
            x = -10:2:10;
            y = 0:2:20;
            z = -1:1:4;
            Img = rand(numel(x), numel(y), numel(z));

            [ImgCrop, xCrop, yCrop, zCrop] = cropArray(Img, ...
                x, -2, 7, ...
                y, [], [], ...
                z, [], 3);

            testCase.verifySize(ImgCrop, [5, 11, 5]);
            testCase.verifyEqual(ImgCrop, Img(5:9, :, 1:5));
            testCase.verifyEqual(xCrop, (-2:2:7).');
            testCase.verifyEqual(yCrop, y);
            testCase.verifyEqual(zCrop, reshape(-1:3, 1, 1, []));
        end

        %% Error Condition Tests
        function testError_coordSizeMismatch(testCase)
            x = 1:5;
            y = 1:20;
            Img = ones(numel(x) + 10, numel(y));

            testCase.verifyError(...
                @() cropArray(Img, ...
                x, 1, 5, ...
                y, 1, 5), ...
                "CNDE:mustHaveValidCoordinateVectors");
        end

        function testError_emptyCoordWithMinMax(testCase)
            x = 1:10;
            y = 1:20;
            Img = ones(numel(x), numel(y));

            testCase.verifyError(...
                @() cropArray(Img, ...
                x, 1, 5, ...
                [], 1, 5), ...
                "CNDE:cropArrayEmptyCoordWithMinMaxSpecified");
        end

        %% Edge Case Tests
        function testEdge_emptyOutputDimension(testCase)
            x = -10:2:10;
            y = 0:2:20;
            Img = ones(numel(x), numel(y));

            [ImgCrop, xCrop, yCrop] = cropArray(Img, ...
                x, [], [], ...
                y, 3, 3);

            testCase.verifySize(ImgCrop, [11, 0]);
            testCase.verifyEqual(xCrop, x(:));
            testCase.verifyEmpty(yCrop);
        end

        function testEdge_roundToNearest(testCase)
            x = -10:2:10;
            y = 0:2:20;
            Img = ones(numel(x), numel(y));

            [ImgCrop, xCrop, yCrop] = cropArray(Img, ...
                x, [], [], ...
                y, 3.1, 3.1, ...
                RoundMinMaxToNearestCoord=true);

            testCase.verifySize(ImgCrop, [11, 1]);
            testCase.verifyEqual(xCrop, x(:));
            testCase.verifyEqual(yCrop, 4);
        end

        function testEdge_extraOutputs(testCase)
            x = 1:10;
            y = 1:20;
            Img = ones(numel(x), numel(y));

            [~, ~, ~, zCrop] = cropArray(Img, ...
                x, [], [], ...
                y, [], []);

            testCase.verifyEmpty(zCrop);
        end

        function testEdge_noCoordsSpecified(testCase)
            Img = rand(2, 3, 4);

            [ImgCropped, c1, c2, c3] = cropArray(Img);

            testCase.verifyEqual(ImgCropped, Img);
            testCase.verifyEmpty(c1);
            testCase.verifyEmpty(c2);
            testCase.verifyEmpty(c3);
        end

        function testEdge_extraArrayDimensions(testCase)
            x = -10:2:10;
            y = 0:2:20;
            Img = rand(numel(x), numel(y), 5, 2);

            [ImgCrop, xCrop, yCrop] = cropArray(Img, ...
                x, [], [], ...
                y, [], 6);

            testCase.verifyEqual(ImgCrop, Img(:, 1:4, :, :));
            testCase.verifyEqual(xCrop, x(:));
            testCase.verifyEqual(yCrop, 0:2:6);
        end

        function testEdge_emptyInputArray(testCase)
            x = -10:2:10;
            y = [];
            z = 0:2:20;
            Img = ones(numel(x), numel(y), numel(z));

            [ImgCrop, xCrop, yCrop, zCrop] = cropArray(Img, ...
                x, [], [], ...
                [], 5, 6, ...
                z, 2, 6);

            testCase.verifySize(ImgCrop, [11, 0, 3]);
            testCase.verifyEqual(xCrop, x(:));
            testCase.verifyEmpty(yCrop);
            testCase.verifyEqual(zCrop, reshape(2:2:6, 1, 1, []));
        end
    end
end