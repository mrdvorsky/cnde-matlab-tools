classdef tester_exampleFunction < matlab.unittest.TestCase
    % Unit tests for the exampleFunction function.
    %
    % This class should serve as an example for how to format unit tests
    % for your custom functions.
    %
    % Please use the naming conventions used here. Please prefer the use
    % of descriptive test names rather than comments.
    %   test_{someGeneralTest}
    %   testError_{someTestThatShouldThrowAnError}
    %   testWarning_{someTestThatShouldThrowWarning}
    %   testEdge_{someEdgeCaseTest}
    %
    %
    % Useful links:
    %   https://www.mathworks.com/help/matlab/matlab_prog/types-of-qualifications.html
    %   https://www.mathworks.com/help/matlab/matlab_prog/class-based-unit-tests.html
    %   https://www.mathworks.com/help/matlab/matlab_prog/write-setup-and-teardown-code-using-classes.html
    %
    % Author: Matt Dvorsky

    properties
        % If needed, the class can store any objects required for the unit
        % tests.
        %
        % Make sure to use the teardown and setup methods if needed.
        % https://www.mathworks.com/help/matlab/matlab_prog/write-setup-and-teardown-code-using-classes.html
    end

    methods (Test)
        %% Basic Functionality Tests
        function test_boolTrueWithNamedArgs(testCase)
            [out1, out2] = exampleFunction("hello", [true, true], 5, ...
                PositiveOddInt=7);

            testCase.verifyEqual(out1, "hello");
            testCase.verifyEqual(out2, 7);
        end

        function test_boolFalseUsesOptIn(testCase)
            out1 = exampleFunction("test", [false, true], 3.14);

            testCase.verifyEqual(out1, 3.14);
        end

        function test_stringArrayAssignment(testCase)
            [~, out2] = exampleFunction("a", true, ...
                StringArray=["1", "2"; "3", "4"]);

            testCase.verifyEqual(out2, ["1", "2"; "3", "4"]);
        end

        function testDefault_stringArray(testCase)
            [~, out2] = exampleFunction("b", false);

            testCase.verifyEqual(out2, "");
        end

        %% Error Condition Tests
        function testError_nonScalarStringInput(testCase)
            testCase.verifyError(...
                @() exampleFunction(["multi", "word"], true), ...
                "MATLAB:validation:IncompatibleSize");
        end

        function testError_evenPositiveOddInt(testCase)
            testCase.verifyError(...
                @() exampleFunction("x", true, PositiveOddInt=4), ...
                "exampleFunction:mustBePositiveOddInteger");
        end

        %% Edge Case Tests
        function testEdge_minimalPositiveOddInt(testCase)
            [~, out2] = exampleFunction("x", true, PositiveOddInt=1);
            testCase.verifyEqual(out2, 1);
        end

        function testEdge_emptyBoolVector(testCase)
            out1 = exampleFunction("empty", logical([]), 999);
            testCase.verifyEqual(out1, "empty");
        end
    end
end