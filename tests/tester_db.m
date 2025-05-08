classdef tester_db < matlab.unittest.TestCase
    % Unit tests for "db" function.
    %
    % Author: Matt Dvorsky

    methods (Test)
        %% Basic Functionality Tests
        function test_basicValue(testCase)
            val = [-0.1, 0.1, 0.01, 1, 10, -10];
            val_db = [-20, -20, -40, 0, 20, 20];

            val_db_actual = db(val);

            testCase.verifyEqual(val_db_actual, val_db);
        end

        %% Edge Case Tests
        function testEdge_infiniteInputs(testCase)
            val = [-inf, inf];
            val_db = [inf, inf];

            val_db_actual = db(val);

            testCase.verifyEqual(val_db_actual, val_db);
        end

        function testEdge_infiniteOutput(testCase)
            val = 0;
            val_db = -inf;

            val_db_actual = db(val);

            testCase.verifyEqual(val_db_actual, val_db);
        end

        %% Error Condition Tests
        function testError_emptyInputs(testCase)
            testCase.verifyError(@() db(), ...
                "MATLAB:minrhs");
        end
    end
end