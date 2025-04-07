classdef tester_mustBeBroadcastable < matlab.unittest.TestCase
    % Unit tests for mustBeBroadcastable function.
    %
    % Author: Matt Dvorsky

    methods (Test)
        %% Basic Functionality Tests
        function test_sameSize(testCase)
            a = ones(2, 3);
            b = ones(2, 3);
            testCase.verifyWarningFree(@() mustBeBroadcastable(a, b));
        end

        function test_singletonExpansion(testCase)
            a = ones(3, 1);
            b = ones(1, 4);
            testCase.verifyWarningFree(@() mustBeBroadcastable(a, b));
        end

        function test_higherDimensions(testCase)
            a = ones(2, 3, 4);
            b = ones(2, 1, 4);
            testCase.verifyWarningFree(@() mustBeBroadcastable(a, b));
        end

        function test_specifiedDimensionsValid(testCase)
            a = ones(2, 2);
            b = ones(1, 3);
            testCase.verifyWarningFree(@() mustBeBroadcastable(a, b, Dimensions=1));
        end

        function test_excludeDimensions(testCase)
            a = ones(2, 3);
            b = ones(2, 4);
            testCase.verifyWarningFree(@() mustBeBroadcastable(a, b, ExcludeDimensions=2));
        end

        %% Error Condition Tests
        function testError_incompatibleSizes(testCase)
            a = ones(2, 3);
            b = ones(3, 2);
            testCase.verifyError(@() mustBeBroadcastable(a, b), ...
                "CNDE:mustBeBroadcastable");
        end

        function testError_specifiedDimensionsInvalid(testCase)
            a = ones(2, 3);
            b = ones(3, 2);
            testCase.verifyError(@() mustBeBroadcastable(a, b, Dimensions=2), ...
                "CNDE:mustBeBroadcastable");
        end

        function testError_excludeDimensionsWithConflict(testCase)
            a = ones(2, 3);
            b = ones(3, 4);
            testCase.verifyError(@() mustBeBroadcastable(a, b, ExcludeDimensions=2), ...
                "CNDE:mustBeBroadcastable");
        end

        %% Edge Case Tests
        function testError_zeroDimensions(testCase)
            a = zeros(0, 5);
            b = zeros(5, 0);
            testCase.verifyError(@() mustBeBroadcastable(a, b), ...
                "CNDE:mustBeBroadcastable");
        end

        function testEdge_scalar(testCase)
            a = 5;
            b = ones(2, 3);
            testCase.verifyWarningFree(@() mustBeBroadcastable(a, b));
        end

        function testEdge_emptyWithSingleton(testCase)
            a = zeros(0, 1);
            b = zeros(1, 0);
            testCase.verifyWarningFree(@() mustBeBroadcastable(a, b));
        end
    end
end