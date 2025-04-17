classdef tester_mustHaveAtLeastOneRepeatingArg < matlab.unittest.TestCase
    % Unit tests for "mustHaveAtLeastOneRepeatingArg" function.
    %
    % Author: Matt Dvorsky

    methods (Test)
        %% Basic Functionality Tests
        function test_nonEmpty(testCase)
            testCase.verifyWarningFree(...
                @() mustHaveAtLeastOneRepeatingArg({0}));
        end

        %% Error Condition Tests
        function testError_emptyInput(testCase)
            testCase.verifyError(...
                @() mustHaveAtLeastOneRepeatingArg({}), ...
                "validators:mustHaveAtLeastOneRepeatingArg");
        end
    end
end