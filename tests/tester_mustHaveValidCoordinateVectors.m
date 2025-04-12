classdef tester_mustHaveValidCoordinateVectors < matlab.unittest.TestCase
    % Unit tests for "mustHaveValidCoordinateVectors" function.
    %
    % Author: Matt Dvorsky

    methods (Test)
        %% Basic Functionality Tests
        function test_validCoordinates_2D(testCase)
            A = rand(5, 10);
            x = 1:5;
            y = 1:10;
            testCase.verifyWarningFree(...
                @() mustHaveValidCoordinateVectors({A}, {x, y}));
        end

        function test_validCoordinates_3D(testCase)
            A = rand(3, 4, 5);
            x = 1:3;
            y = 1:4;
            z = 1:5;
            testCase.verifyWarningFree(...
                @() mustHaveValidCoordinateVectors({A}, {x, y, z}));
        end

        function test_multipleBroadcasting(testCase)
            A = rand(1, 10);
            B = rand(5, 10);
            x = 1:5;
            y = 1:10;
            testCase.verifyWarningFree(...
                @() mustHaveValidCoordinateVectors({A, B}, {x, y}, ...
                AllowBroadcasting=true));
        end

        function test_multipleArraysMatchingSizes(testCase)
            A = rand(5, 10);
            B = rand(5, 10);
            x = 1:5;
            y = 1:10;
            testCase.verifyWarningFree(...
                @() mustHaveValidCoordinateVectors({A, B}, {x, y}));
        end

        function test_broadcastingAndEmpty(testCase)
            A = rand(1, 10, 2, 4);
            x = 1:10;
            y = 1:10;
            z = [];
            w = 1:4;
            testCase.verifyWarningFree(...
                @() mustHaveValidCoordinateVectors({A}, {x, y, z, w}, ...
                AllowBroadcasting=true, AllowEmptyCoord=true));
        end

        function test_4D(testCase)
            A = rand(2, 3, 4, 5);
            x = 1:2;
            y = 1:3;
            z = 1:4;
            w = 1:5;
            testCase.verifyWarningFree(...
                @() mustHaveValidCoordinateVectors({A}, {x, y, z, w}));
        end

        %% Error Condition Tests
        function testError_mismatchedLengths(testCase)
            A = rand(5, 10);
            x = 1:4;    % Wrong size.
            y = 1:10;
            testCase.verifyError(...
                @() mustHaveValidCoordinateVectors({A}, {x, y}), ...
                "CNDE:mustHaveValidCoordinateVectors");
        end

        function testError_emptyCoordinatesWithoutOption(testCase)
            A = rand(5, 10);
            x = [];
            y = 1:10;
            testCase.verifyError(...
                @() mustHaveValidCoordinateVectors({A}, {x, y}), ...
                "CNDE:mustHaveValidCoordinateVectors");
        end

        function testError_multipleArraysMismatchedSizes(testCase)
            A = rand(5, 10);
            B = rand(4, 10);
            x = 1:5;
            y = 1:10;
            testCase.verifyError(...
                @() mustHaveValidCoordinateVectors({A, B}, {x, y}), ...
                "CNDE:mustHaveEqualSizes");
        end

        function testError_invalidBroadcasting(testCase)
            A = rand(3, 10);
            B = rand(5, 10);
            x = 1:5;
            y = 1:10;
            testCase.verifyError(...
                @() mustHaveValidCoordinateVectors({A, B}, {x, y}, ...
                AllowBroadcasting=true), ...
                "CNDE:mustBeBroadcastable");
        end

        function testError_4D(testCase)
            A = rand(2, 3, 4, 5);
            x = 1:2;
            y = 1:3;
            z = 1:5;  % Wrong size
            w = 1:5;
            testCase.verifyError(...
                @() mustHaveValidCoordinateVectors({A}, {x, y, z, w}), ...
                "CNDE:mustHaveValidCoordinateVectors");
        end

        %% Edge Case Tests
        function testEdge_tooFewCoordinates(testCase)
            A = rand(5, 10);
            x = 1:5;
            testCase.verifyWarningFree(...
                @() mustHaveValidCoordinateVectors({A}, {x}));
        end

        function testEdge_tooManyCoordinates(testCase)
            A = rand(5, 10);
            x = 1:5;
            y = 1:10;
            z = 1;
            testCase.verifyWarningFree(...
                @() mustHaveValidCoordinateVectors({A}, {x, y, z}));
        end

        function testEdge_emptyArray(testCase)
            A = zeros(0, 5);
            x = [];
            y = 1:5;
            testCase.verifyWarningFree(...
                @() mustHaveValidCoordinateVectors({A}, {x, y}));
        end

        function testEdge_emptyCoordinatesWithOption(testCase)
            A = rand(5, 10);
            x = [];
            y = 1:10;
            testCase.verifyWarningFree(...
                @() mustHaveValidCoordinateVectors({A}, {x, y}, ...
                AllowEmptyCoord=true));
        end

        function testEdge_singletonDimensions(testCase)
            A = rand(1, 10);
            x = 0;
            y = 1:10;
            testCase.verifyWarningFree(...
                @() mustHaveValidCoordinateVectors({A}, {x, y}));
        end

        function testEdge_scalarInput(testCase)
            A = 5;
            x = 0;
            y = 0;
            testCase.verifyWarningFree(...
                @() mustHaveValidCoordinateVectors({A}, {x, y}));
        end

        function testEdge_scalarInputWithEmptyCoord(testCase)
            A = 5;
            x = 0;
            y = [];
            testCase.verifyWarningFree(...
                @() mustHaveValidCoordinateVectors({A}, {x, y}, ...
                AllowEmptyCoord=true));
        end
    end
end