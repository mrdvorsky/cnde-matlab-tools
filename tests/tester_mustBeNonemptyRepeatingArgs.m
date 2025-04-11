classdef tester_mustBeNonemptyRepeatingArgs < matlab.unittest.TestCase
    % Unit tests for "mustBeNonemptyRepeatingArgs" function.
    %
    % Author: Matt Dvorsky

    methods (Test)
        %% Basic Functionality Tests
        function test_nonEmpty(testCase)
            testCase.verifyWarningFree(...
                @() mustBeNonemptyRepeatingArgs({0}));
        end

        %% Error Condition Tests
        function testError_emptyInput(testCase)
            testCase.verifyError(...
                @() mustBeNonemptyRepeatingArgs({}), ...
                "CNDE:mustBeNonemptyRepeatingArgs");
        end
    end
end