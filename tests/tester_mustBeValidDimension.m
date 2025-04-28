classdef tester_mustBeValidDimension < matlab.unittest.TestCase
    % Unit tests for "mustBeValidDimension" function.
    %
    % Author: Matt Dvorsky

    methods (Test)
        %% Valid Input Tests
        function test_scalarPositiveInteger(testCase)
            testCase.verifyWarningFree(@() mustBeValidDimension(1));
            testCase.verifyWarningFree(@() mustBeValidDimension(3));
        end

        function test_vectorPositiveIntegers(testCase)
            testCase.verifyWarningFree(@() mustBeValidDimension([1, 3, 5]));
            testCase.verifyWarningFree(@() mustBeValidDimension([2, 4, 6]));
        end

        function test_allStringInput(testCase)
            testCase.verifyWarningFree(@() mustBeValidDimension("all"));
            testCase.verifyWarningFree(@() mustBeValidDimension('all'));
        end

        %% Error Condition Tests
        function testError_nonIntegerInput(testCase)
            testCase.verifyError(@() mustBeValidDimension(1.5), ...
                "validators:mustBeValidDimension");
            testCase.verifyError(@() mustBeValidDimension(inf), ...
                "validators:mustBeValidDimension");
        end

        function testError_nonPositiveInput(testCase)
            testCase.verifyError(@() mustBeValidDimension(0), ...
                "validators:mustBeValidDimension");
            testCase.verifyError(@() mustBeValidDimension(-1), ...
                "validators:mustBeValidDimension");
        end

        function testError_nonUniqueInput(testCase)
            testCase.verifyError(@() mustBeValidDimension([1, 2, 1]), ...
                "validators:mustBeValidDimension");
        end

        function testError_invalidStringInput(testCase)
            testCase.verifyError(@() mustBeValidDimension("invalid"), ...
                "validators:mustBeValidDimension");
        end

        %% Allow Vector Option Tests
        function test_allowVectorOption_true(testCase)
            testCase.verifyWarningFree(...
                @() mustBeValidDimension([1, 2], AllowVector=true));
        end

        function testError_allowVectorOption_false(testCase)
            testCase.verifyError(...
                @() mustBeValidDimension([1, 2], AllowVector=false), ...
                "validators:mustBeValidDimension");
        end

        %% Edge Case Tests
        function testEdge_minimalValue(testCase)
            testCase.verifyWarningFree(@() mustBeValidDimension(1));
        end

        function testEdge_largeValue(testCase)
            testCase.verifyWarningFree(@() mustBeValidDimension(intmax));
        end

        function testEdge_emptyInput(testCase)
            testCase.verifyWarningFree(@() mustBeValidDimension([]), ...
                "validators:mustBeValidDimension");
        end
    end
end