classdef tester_mustBeBroadcastable < matlab.unittest.TestCase
    % Unit tests for mustBeBroadcastable function.
    %
    % Author: Matt Dvorsky

    methods (Test)
        function test_sameSize(testCase)
            % Test arrays with identical sizes
            a = ones(2, 3);
            b = ones(2, 3);
            testCase.verifyWarningFree(@() mustBeBroadcastable(a, b));
        end

        function test_singletonExpansion(testCase)
            % Test arrays with singleton dimensions that can expand
            a = ones(3, 1);
            b = ones(1, 4);
            testCase.verifyWarningFree(@() mustBeBroadcastable(a, b));
        end

        function test_higherDimensions(testCase)
            % Test higher-dimensional compatible arrays
            a = ones(2, 3, 4);
            b = ones(2, 1, 4);
            testCase.verifyWarningFree(@() mustBeBroadcastable(a, b));
        end

        function test_specifiedDimensionsValid(testCase)
            % Test valid case with specific dimensions checked
            a = ones(2, 2);
            b = ones(1, 3);
            testCase.verifyWarningFree(@() mustBeBroadcastable(a, b, Dimensions=1));
        end

        function test_excludeDimensions(testCase)
            % Test exclusion of conflicting dimension
            a = ones(2, 3);
            b = ones(2, 4);
            testCase.verifyWarningFree(@() mustBeBroadcastable(a, b, ExcludeDimensions=2));
        end

        function testError_incompatibleSizes(testCase)
            % Test arrays with incompatible non-singleton dimensions
            a = ones(2, 3);
            b = ones(3, 2);
            testCase.verifyError(@() mustBeBroadcastable(a, b), ...
                "CNDE:mustBeBroadcastable");
        end

        function testError_specifiedDimensionsInvalid(testCase)
            % Test invalid case with specific dimensions checked
            a = ones(2, 3);
            b = ones(3, 2);
            testCase.verifyError(@() mustBeBroadcastable(a, b, Dimensions=2), ...
                "CNDE:mustBeBroadcastable");
        end

        function testError_ExcludeDimensionsWithConflict(testCase)
            % Test exclusion does not hide other conflicts
            a = ones(2, 3);
            b = ones(3, 4);
            testCase.verifyError(@() mustBeBroadcastable(a, b, ExcludeDimensions=2), ...
                "CNDE:mustBeBroadcastable");
        end

        function testError_ZeroDimensions(testCase)
            % Test arrays with zero dimensions (incompatible)
            a = zeros(0, 5);
            b = zeros(5, 0);
            testCase.verifyError(@() mustBeBroadcastable(a, b), ...
                "CNDE:mustBeBroadcastable");
        end

        function testEdge_scalar(testCase)
            % Test scalar with array
            a = 5;
            b = ones(2, 3);
            testCase.verifyWarningFree(@() mustBeBroadcastable(a, b));
        end

        function testEdge_EmptyWithSingleton(testCase)
            % Test empty array with singleton in another
            a = zeros(0, 1);
            b = zeros(1, 0);
            testCase.verifyWarningFree(@() mustBeBroadcastable(a, b));
        end
    end
end