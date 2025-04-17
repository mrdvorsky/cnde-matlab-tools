classdef tester_mustBeCallable < matlab.unittest.TestCase
    % Unit tests for the "mustBeCallable" function.
    %
    % Author: Matt Dvorsky

    methods (Test)
        %% Basic Functionality Tests
        function test_validFunctionWithArgs(testCase)
            testCase.verifyWarningFree(@() mustBeCallable(@sin, {0}, "x"));
        end

        function test_validFunctionWithMultipleArgs(testCase)
            testCase.verifyWarningFree(@() mustBeCallable(@plus, {1, 2}, "a, b"));
        end

        function test_validAnonymousFunction(testCase)
            testCase.verifyWarningFree(@() mustBeCallable(@(x) x^2, {3}, "x"));
        end

        %% Error Condition Tests
        function testError_nonFunctionNumeric(testCase)
            testCase.verifyError(...
                @() mustBeCallable(42, {1}, "x"), ...
                "validators:mustBeCallable");
        end

        function testError_nonFunctionCell(testCase)
            testCase.verifyError(...
                @() mustBeCallable({1, 2, 3}, {1}, "x"), ...
                "validators:mustBeCallable");
        end

        function testError_wrongNumberOfArgs(testCase)
            testCase.verifyError(...
                @() mustBeCallable(@sin, {1, 2}, "x, y"), ...
                "validators:mustBeCallable");
        end

        function testError_wrongArgTypes(testCase)
            testCase.verifyError(...
                @() mustBeCallable(@abs, {"not_a_number"}, "str"), ...
                "validators:mustBeCallable");
        end

        %% Edge Case Tests
        function testEdge_emptyArgs(testCase)
            testCase.verifyWarningFree(@() mustBeCallable(@now, {}, ""));
        end

        function testEdge_multipleOutputs(testCase)
            testCase.verifyWarningFree(@() mustBeCallable(@size, {magic(3)}, "A"));
        end

        function testEdge_defaultCallArgString(testCase)
            testCase.verifyWarningFree(@() mustBeCallable(@cos, {0}));
        end

        function testEdge_cellArrayArg(testCase)
            testCase.verifyWarningFree(@() mustBeCallable(@iscell, {{1,2,3}}, "C"));
        end
    end
end