classdef tester_arrayToTable < matlab.unittest.TestCase
    % Unit tests for "arrayToTable" function.
    %
    % Author: Matt Dvorsky

    methods (Test)
        %% Basic Functionality Tests
        function test_basic2D(testCase)
            x = compose("%d", 1:2);
            y = uint8(3:5);
            D = rand(2, 3);

            DataTable = arrayToTable(D, x, y);

            [x_exp, y_exp] = ndgrid(x, y);
            Table_exp = table(x_exp(:), y_exp(:), D(:), ...
                VariableNames=DataTable.Properties.VariableNames);

            testCase.verifyEqual(DataTable, Table_exp);
        end

        function test_basic3D_cellInput(testCase)
            x = compose("%d", 1:2);
            y = uint8(3:5);
            z = single(11:14);
            D1 = rand(2, 3, 4);
            D2 = rand(2, 3, 4) + 1j*rand(2, 3, 4);

            DataTable = arrayToTable({D1, D2}, x, y, z);

            [x_exp, y_exp, z_exp] = ndgrid(x, y, z);
            Table_exp = table(x_exp(:), y_exp(:), z_exp(:), D1(:), D2(:), ...
                VariableNames=DataTable.Properties.VariableNames);

            testCase.verifyEqual(DataTable, Table_exp);
        end

        function test_basic3D_cellInputBroadcast(testCase)
            x = compose("%d", 1:2);
            y = uint8(3:5);
            z = single(11:14);
            D1 = rand(1, 3, 4);
            D2 = rand(2, 1, 4) + 1j*rand(2, 1, 4);

            DataTable = arrayToTable({D1, D2}, x, y, z);

            [x_exp, y_exp, z_exp] = ndgrid(x, y, z);
            D1_exp = repmat(D1, [2, 1, 1]);
            D2_exp = repmat(D2, [1, 3, 1]);
            Table_exp = table(x_exp(:), y_exp(:), z_exp(:), ...
                D1_exp(:), D2_exp(:), ...
                VariableNames=DataTable.Properties.VariableNames);

            testCase.verifyEqual(DataTable, Table_exp);
        end

        function test_mixedDataTypes(testCase)
            x = ["a", "b"];
            y = datetime(["2020-01-01", "2020-01-02"]);
            D1 = rand(2, 2);
            D2 = {1, 2; 3, 4};

            DataTable = arrayToTable({D1, D2}, x, y);

            [x_exp, y_exp] = ndgrid(x, y);
            Table_exp = table(x_exp(:), y_exp(:), D1(:), D2(:), ...
                VariableNames=DataTable.Properties.VariableNames);

            testCase.verifyEqual(DataTable, Table_exp);
        end

        function test_highDimensionalInput(testCase)
            dims = {1:2, 1:3, 1:4, 1:5, 1:6};
            D = rand(2, 3, 4, 5, 6);

            DataTable = arrayToTable(D, dims{:});

            % Create expected table using ndgrid
            grid = cell(1, numel(dims));
            [grid{:}] = ndgrid(dims{:});
            grid = cellfun(@(x) x(:), grid, UniformOutput=false);
            Table_exp = table(grid{:}, D(:), ...
                VariableNames=DataTable.Properties.VariableNames);

            testCase.verifyEqual(DataTable, Table_exp);
        end

        %% Error Condition Tests
        function testError_sizeMismatch_GridData(testCase)
            x = 1:3;
            y = 1:4;
            D = rand(2, 4); % Wrong size in first dimension

            testCase.verifyError(@() arrayToTable(D, x, y), ...
                "CNDE:mustHaveValidCoordinateVectors");
        end

        function testError_nonBroadcastableData(testCase)
            x = 1:2;
            y = 1:3;
            D1 = rand(2, 3);
            D2 = rand(2, 4); % Incompatible size

            testCase.verifyError(@() arrayToTable({D1, D2}, x, y), ...
                "CNDE:mustBeBroadcastable");
        end

        function testError_nonVectorCoordinates(testCase)
            x = 1:2;
            y = rand(2, 3); % y should be a vector
            D = rand(2, 3);

            testCase.verifyError(@() arrayToTable(D, x, y), ...
                "MATLAB:validation:IncompatibleSize");
        end

        %% Warning Tests
        function testWarning_missingGridVectors(testCase)
            x = 1:2;
            y = 1:3;
            D = rand(2, 3, 4);

            % Verify warning is issued
            DataTable = testCase.verifyWarning(...
                @() arrayToTable(D, x, y), ...
                "CNDE:arrayToTableMissingGridVectors");

            % Verify the function still works correctly
            [x_exp, y_exp, z_exp] = ndgrid(x, y, 1:size(D, 3));
            Table_exp = table(x_exp(:), y_exp(:), z_exp(:), D(:), ...
                VariableNames=DataTable.Properties.VariableNames);

            testCase.verifyEqual(DataTable, Table_exp);
        end

        %% Edge Case Tests
        function testEdge_emptyInput(testCase)
            x = [];
            y = [];
            D = zeros(0, 0);

            DataTable = arrayToTable(D, x, y);

            testCase.verifyEqual(height(DataTable), 0);
            testCase.verifyEqual(width(DataTable), 3);
        end

        function testEdge_singletonDimensions(testCase)
            x = 1;
            y = 2;
            z = 3;
            D = rand(1, 1, 1);

            DataTable = arrayToTable(D, x, y, z);

            Table_exp = table(x, y, z, D, ...
                VariableNames=DataTable.Properties.VariableNames);

            testCase.verifyEqual(DataTable, Table_exp);
        end
    end
end