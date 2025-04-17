classdef tester_besselFunctions < matlab.unittest.TestCase
    % Unit test base class for all custom bessel functions.
    %
    % Author: Matt Dvorsky

    properties
        tolVal = 1e-14;
        filename = "data/besselFunctions.json";

        besselTableData;
        besselFunsToTest;
    end

    methods (TestMethodSetup)
        function setup(testCase)
            testCase.besselTableData = jsondecode(fileread(testCase.filename));

            testCase.besselFunsToTest = cell(numel(testCase.besselTableData), 1);
            for ii = 1:numel(testCase.besselTableData)
                testCase.besselFunsToTest{ii} = ...
                    eval(testCase.besselTableData(ii).FunctionString);
            end
        end
    end

    methods (Test)
        %% Basic Functionality Tests
        function test_besselValues(testCase)
            for ii = 1:numel(testCase.besselFunsToTest)
                n0 = testCase.besselTableData(ii).n0;
                z0 = testCase.besselTableData(ii).z0_real ...
                    + 1j*testCase.besselTableData(ii).z0_imag;
                vExpected = testCase.besselTableData(ii).v_real ...
                    + 1j*testCase.besselTableData(ii).v_imag;

                [n, z] = ndgrid(n0, z0);
                vActual = testCase.besselFunsToTest{ii}(n, z);
                vTableActualExp = table(n(:), z(:), vActual(:), vExpected(:), ...
                    vActual(:) - vExpected(:), ...
                    VariableNames=["n", "z", ...
                    testCase.besselTableData(ii).FunctionString, ...
                    "Expected Value", "Difference"]);

                notEqualCases = abs(vActual(:) - vExpected(:)) > testCase.tolVal;
                testCase.verifyEmpty(vTableActualExp(notEqualCases, :));
            end
        end
    end
end