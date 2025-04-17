classdef tester_mustBeBroadcastable < matlab.unittest.TestCase
    % Unit tests for "mustBeBroadcastable" function.
    %
    % Author: Matt Dvorsky

    methods (Test)
        %% Basic Functionality Tests
        function test_sameSize(testCase)
            A = ones(2, 3);
            B = ones(2, 3);
            testCase.verifyWarningFree(@() mustBeBroadcastable(A, B));
        end

        function test_singletonExpansion(testCase)
            A = ones(3, 1);
            B = ones(1, 4);
            testCase.verifyWarningFree(@() mustBeBroadcastable(A, B));
        end

        function test_higherDimensions(testCase)
            A = ones(2, 3, 4);
            B = ones(2, 1, 4);
            testCase.verifyWarningFree(@() mustBeBroadcastable(A, B));
        end

        function test_manyArgs(testCase)
            A = ones(2, 3, 4);
            B = ones(2, 1, 4);
            C = ones(1, 1, 1);
            testCase.verifyWarningFree(@() mustBeBroadcastable(A, B, C));
        end

        function test_specifiedDimensionsValid(testCase)
            A = ones(2, 2);
            B = ones(1, 3);
            testCase.verifyWarningFree(@() mustBeBroadcastable(A, B, Dimensions=1));
        end

        function test_excludeDimensions(testCase)
            A = ones(2, 3);
            B = ones(2, 4);
            testCase.verifyWarningFree(@() mustBeBroadcastable(A, B, ExcludeDimensions=2));
        end

        %% Error Condition Tests
        function testError_incompatibleSizes(testCase)
            A = ones(2, 3);
            B = ones(3, 2);
            testCase.verifyError(@() mustBeBroadcastable(A, B), ...
                "MATLAB:sizeDimensionsMustMatch");
        end

        function testError_incompatibleSizes_manyArgs(testCase)
            A = ones(2, 3);
            B = ones(1, 3);
            C = ones(3, 1);
            testCase.verifyError(@() mustBeBroadcastable(A, B, C), ...
                "MATLAB:sizeDimensionsMustMatch");
        end

        function testError_specifiedDimensionsWithConflict(testCase)
            A = ones(2, 3);
            B = ones(1, 4);
            testCase.verifyError(@() mustBeBroadcastable(A, B, Dimensions=2), ...
                "MATLAB:sizeDimensionsMustMatch");
        end

        function testError_excludeDimensionsWithConflict(testCase)
            A = ones(2, 3);
            B = ones(3, 4);
            testCase.verifyError(@() mustBeBroadcastable(A, B, ExcludeDimensions=2), ...
                "MATLAB:sizeDimensionsMustMatch");
        end

        %% Edge Case Tests
        function testError_zeroDimensions(testCase)
            A = zeros(0, 5);
            B = zeros(5, 0);
            testCase.verifyError(@() mustBeBroadcastable(A, B), ...
                "MATLAB:sizeDimensionsMustMatch");
        end

        function testEdge_scalar(testCase)
            A = 5;
            B = ones(2, 3);
            testCase.verifyWarningFree(@() mustBeBroadcastable(A, B));
        end

        function testEdge_emptyWithSingleton(testCase)
            A = zeros(0, 1);
            B = zeros(1, 0);
            testCase.verifyWarningFree(@() mustBeBroadcastable(A, B));
        end

        function testEdge_singleArg(testCase)
            testCase.verifyWarningFree(@() mustBeBroadcastable([]));
        end
    end
end