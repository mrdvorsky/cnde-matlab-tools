classdef tester_tableToArray < matlab.unittest.TestCase
    % Unit tests for "tableToArray" function.
    %
    % Author: Matt Dvorsky

    methods (Test)
        %% Basic Functionality Tests
        function test_basic2D(testCase)
            x = 1:2;
            y = 3:5;
            D = rand(2, 3);

            [X, Y] = ndgrid(x, y);
            DataTable = table(X(:), Y(:), D(:));

            % Test with table input
            [DataOut, xOut, yOut] = tableToArray(2, DataTable);
            testCase.verifyEqual(DataOut, D);
            testCase.verifyEqual(xOut, x.');
            testCase.verifyEqual(yOut, y);

            % Test with array input
            [DataOut, xOut, yOut] = tableToArray(2, table2array(DataTable));
            testCase.verifyEqual(DataOut, D);
            testCase.verifyEqual(xOut, x(:));
            testCase.verifyEqual(yOut, y(:).');
        end

        function test_basic3D_withCellOutput(testCase)
            x = 1:2;
            y = 3:5;
            z = 6:9;
            D1 = rand(2, 3, 4);
            D2 = rand(2, 3, 4) + 1j*rand(2, 3, 4);

            [X, Y, Z] = ndgrid(x, y, z);
            DataTable = table(X(:), Y(:), Z(:), D1(:), D2(:));

            % Test with table input
            [DataOut, xOut, yOut, zOut] = tableToArray(3, DataTable);
            testCase.verifyEqual(DataOut{1}, D1);
            testCase.verifyEqual(DataOut{2}, D2);
            testCase.verifyEqual(xOut, x.');
            testCase.verifyEqual(yOut, y);
            testCase.verifyEqual(zOut, reshape(z, 1, 1, []));

            % Test with array input
            [DataOut, xOut, yOut, zOut] = tableToArray(3, table2array(DataTable));
            testCase.verifyEqual(DataOut{1}, D1);
            testCase.verifyEqual(DataOut{2}, D2);
            testCase.verifyEqual(xOut, x.');
            testCase.verifyEqual(yOut, y);
            testCase.verifyEqual(zOut, reshape(z, 1, 1, []));
        end

        function test_nonNumericData(testCase)
            x = ["a", "b"];
            y = ["x", "y", "z"];
            D = rand(2, 3);

            [X, Y] = ndgrid(x, y);
            DataTable = table(X(:), Y(:), D(:));

            [DataOut, xOut, yOut] = tableToArray(2, DataTable);
            testCase.verifyEqual(DataOut, D);
            testCase.verifyEqual(xOut, x(:));
            testCase.verifyEqual(yOut, y(:).');
        end

        function test_gridColumnsOption(testCase)
            x = 1:2;
            y = 3:5;
            D = rand(2, 3);

            [X, Y] = ndgrid(x, y);
            DataTable = table(D(:), Y(:), X(:));   % Mixed Order

            [DataOut, xOut, yOut] = tableToArray(2, DataTable, ...
                GridColumns=[3, 2]);
            testCase.verifyEqual(DataOut, D);
            testCase.verifyEqual(xOut, x.');
            testCase.verifyEqual(yOut, y);
        end

        function test_gridColumnsOptionWithMultipleDataColumns(testCase)
            x = 1:2;
            y = 3:5;
            D1 = rand(2, 3);
            D2 = rand(2, 3);

            [X, Y] = ndgrid(x, y);
            DataTable = table(D1(:), Y(:), X(:), D2(:));   % Mixed order

            [DataOut, xOut, yOut] = tableToArray(2, DataTable, ...
                GridColumns=[3, 2]);
            testCase.verifyEqual(DataOut{1}, D1);
            testCase.verifyEqual(DataOut{2}, D2);
            testCase.verifyEqual(xOut, x.');
            testCase.verifyEqual(yOut, y);
        end

        function test_nonConsecutiveGridColumns1(testCase)
            x = 1:2;
            y = 3:5;
            D = rand(2, 3);

            [X, Y] = ndgrid(x, y);
            DataTable = table(D(:), X(:), Y(:));   % Out of order

            % Test with table input
            [DataOut, xOut, yOut] = tableToArray(2, DataTable, ...
                GridColumns=[2, 3]);
            testCase.verifyEqual(DataOut, D);
            testCase.verifyEqual(xOut, x(:));
            testCase.verifyEqual(yOut, y(:).');

            % Test with array input
            [DataOut, xOut, yOut] = tableToArray(2, table2array(DataTable), ...
                GridColumns=[2, 3]);
            testCase.verifyEqual(DataOut, D);
            testCase.verifyEqual(xOut, x(:));
            testCase.verifyEqual(yOut, y(:).');
        end

        function test_nonConsecutiveGridColumns2(testCase)
            x = 1:2;
            y = 3:5;
            D = rand(2, 3);

            [X, Y] = ndgrid(x, y);
            DataTable = table(Y(:), D(:), X(:));   % Out of order

            % Test with table input
            [DataOut, xOut, yOut] = tableToArray(2, DataTable, ...
                GridColumns=[3, 1]);
            testCase.verifyEqual(DataOut, D);
            testCase.verifyEqual(xOut, x(:));
            testCase.verifyEqual(yOut, y(:).');

            % Test with array input
            [DataOut, xOut, yOut] = tableToArray(2, table2array(DataTable), ...
                GridColumns=[3, 1]);
            testCase.verifyEqual(DataOut, D);
            testCase.verifyEqual(xOut, x(:));
            testCase.verifyEqual(yOut, y(:).');
        end

        %% Error Condition Tests
        function testError_tooFewColumns(testCase)
            x = 1:2;
            y = 3:5;
            D = rand(2, 3);

            [X, Y] = ndgrid(x, y);
            DataTable = table(X(:), Y(:), D(:));

            testCase.verifyError(@() tableToArray(3, DataTable), ...
                "CNDE:tableToArrayTooFewColumns");
        end

        function testError_InvalidGridColumns(testCase)
            x = 1:2;
            y = 3:5;
            D = rand(2, 3);

            [X, Y] = ndgrid(x, y);
            DataTable = table(X(:), Y(:), D(:));

            % Invalid GridColumns specification
            testCase.verifyError(...
                @() tableToArray(2, DataTable, GridColumns=[1, 1]), ...
                "CNDE:tableToArrayInvalidGridColumn");
            testCase.verifyError...
                (@() tableToArray(2, DataTable, GridColumns=[1, 4]), ...
                "CNDE:tableToArrayInvalidGridColumn");
            testCase.verifyError(...
                @() tableToArray(2, DataTable, GridColumns=[1]), ...
                "CNDE:tableToArrayInvalidGridColumn");
        end

        function testError_nonuniformData1(testCase)
            % Create non-uniform data that can't be arranged into a grid
            x = [1, 1, 2].';
            y = [3, 4, 3].';
            D = rand(3, 1);
            DataTable = table(x, y, D);

            testCase.verifyError(@() tableToArray(2, DataTable), ...
                "CNDE:tableToArrayNonuniformData");
        end

        function testError_nonuniformData2(testCase)
            % Create non-uniform data that can't be arranged into a grid
            x = [1, 1, 2, 2].';
            y = [3, 4, 3, 3].';
            D = rand(4, 1);
            DataTable = table(x, y, D);

            testCase.verifyError(@() tableToArray(2, DataTable), ...
                "CNDE:tableToArrayNonuniformData");
        end

        function testError_nonuniformData3(testCase)
            % Create non-uniform data that can't be arranged into a grid
            x = [1, 1, 2, 2, 3].';
            y = [3, 4, 3, 4, 5].';
            D = rand(5, 1);
            DataTable = table(x, y, D);

            testCase.verifyError(@() tableToArray(2, DataTable), ...
                "CNDE:tableToArrayNonuniformData");
        end

        function testError_nonScalarTableElements(testCase)
            x = {[1 2], [1 2], [3 4], [3 4]};
            y = {3, 4, 3, 4};
            D = rand(4, 1);

            DataTable = table(x(:), y(:), D(:));

            testCase.verifyError(@() tableToArray(2, DataTable), ...
                "MATLAB:table:sortrows:SortrowsOnVarFailed");
        end

        %% Warning Tests
        function testWarning_extraData(testCase)
            % Create data with an extra dimension to trigger a warning
            x = 1:2;
            y = 3:5;
            z = 6:7;
            [X, Y] = ndgrid(x, y);
            D = rand(2, 3, 2);    % Extra dimension

            % Flatten with extra dimension last
            DataTable = table(...
                repmat(X(:), 2, 1), ...
                repmat(Y(:), 2, 1), ...
                D(:));

            % Verify warning is issued
            [DataOut, xOut, yOut] = testCase.verifyWarning(...
                @() tableToArray(2, DataTable), ...
                "CNDE:tableToArrayExtraDataWarning");

            % Verify output is still correct
            testCase.verifyEqual(DataOut, D);
            testCase.verifyEqual(xOut, x(:));
            testCase.verifyEqual(yOut, y(:).');
        end

        %% Edge Cases
        function testEdge_mixedDataTypesComplexStrings(testCase)
            x = ["a", "b"];
            y = ["x", "y", "z"];
            z = sort([1, 1j, 0, -1]);
            D = rand(2, 3, 4);

            [X, Y, Z] = ndgrid(x, y, z);
            DataTable = table(X(:), Y(:), Z(:), D(:));

            [DataOut, xOut, yOut, zOut] = tableToArray(3, DataTable);
            testCase.verifyEqual(DataOut, D);
            testCase.verifyEqual(xOut, x(:));
            testCase.verifyEqual(yOut, y(:).');
            testCase.verifyEqual(zOut, reshape(z, 1, 1, []));
        end

        function testEdge_singlePoint(testCase)
            DataTable = table(1, 2, 3);

            % Test with table input
            [DataOut, xOut, yOut] = tableToArray(2, DataTable);
            testCase.verifyEqual(DataOut, 3);
            testCase.verifyEqual(xOut, 1);
            testCase.verifyEqual(yOut, 2);

            % Test with array input
            [DataOut, xOut, yOut] = tableToArray(2, table2array(DataTable));
            testCase.verifyEqual(DataOut, 3);
            testCase.verifyEqual(xOut, 1);
            testCase.verifyEqual(yOut, 2);
        end

        function testEdge_emptyInput(testCase)
            DataTable = table([], [], []);
            testCase.verifyError(...
                @() tableToArray(2, DataTable), ...
                "MATLAB:validators:mustBeNonempty");
            testCase.verifyError(...
                @() tableToArray(2, table2array(DataTable)), ...
                "MATLAB:validators:mustBeNonempty");
        end

        function testEdge_rowOrderIndependence2D(testCase)
            x = [1, 2, 1, 2].';
            y = [3, 3, 4, 4].';
            D = rand(4, 1);

            % Create table with rows in different orders
            orders = {
                [1, 2, 3, 4];
                [4, 3, 2, 1];
                [2, 1, 4, 3];
                [3, 1, 4, 2]
                };

            % Store first result for comparison
            DataTable = table(x(orders{1}), y(orders{1}), D(orders{1}));
            [DataRef, xRef, yRef] = tableToArray(2, DataTable);

            % Test all other orderings
            for i = 2:numel(orders)
                DataTable = table(x(orders{i}), y(orders{i}), D(orders{i}));
                [DataOut, xOut, yOut] = tableToArray(2, DataTable);

                testCase.verifyEqual(DataOut, DataRef);
                testCase.verifyEqual(xOut, xRef);
                testCase.verifyEqual(yOut, yRef);
            end
        end

        function testEdge_rowOrderIndependence3D(testCase)
            x = [1, 2, 1, 2, 1, 2, 1, 2].';
            y = [3, 3, 4, 4, 3, 3, 4, 4].';
            z = [5, 5, 5, 5, 6, 6, 6, 6].';
            D = rand(8, 1);

            % Create table with rows in different orders
            orders = {
                [1, 2, 3, 4, 5, 6, 7, 8];
                [8, 7, 6, 5, 4, 3, 2, 1];
                [2, 5, 3, 7, 1, 6, 4, 8];
                [4, 1, 6, 3, 8, 5, 2, 7]
                };

            % Store first result for comparison
            DataTable = table(x(orders{1}), y(orders{1}), z(orders{1}), D(orders{1}));
            [DataRef, xRef, yRef, zRef] = tableToArray(3, DataTable);

            % Test all other orderings
            for i = 2:numel(orders)
                DataTable = table(x(orders{i}), y(orders{i}), z(orders{i}), D(orders{i}));
                [DataOut, xOut, yOut, zOut] = tableToArray(3, DataTable);

                testCase.verifyEqual(DataOut, DataRef);
                testCase.verifyEqual(xOut, xRef);
                testCase.verifyEqual(yOut, yRef);
                testCase.verifyEqual(zOut, zRef);
            end
        end

        function testEdge_rowOrderIndependenceWithNonNumericData(testCase)
            x = ["a", "b", "a", "b"].';
            y = ["x", "x", "y", "y"].';
            D = rand(4, 1);

            % Create table with rows in different orders
            orders = {
                [1, 2, 3, 4];
                [4, 3, 2, 1];
                [2, 1, 4, 3];
                [3, 1, 4, 2]
                };

            % Store first result for comparison
            DataTable = table(x(orders{1}), y(orders{1}), D(orders{1}));
            [DataRef, xRef, yRef] = tableToArray(2, DataTable);

            % Test all other orderings
            for i = 2:numel(orders)
                DataTable = table(x(orders{i}), y(orders{i}), D(orders{i}));
                [DataOut, xOut, yOut] = tableToArray(2, DataTable);

                testCase.verifyEqual(DataOut, DataRef);
                testCase.verifyEqual(xOut, xRef);
                testCase.verifyEqual(yOut, yRef);
            end
        end

        function testEdge_rowOrderIndependenceWithMixedData(testCase)
            x = ["a", "b", "a", "b", "a", "b"].';
            y = sort([0, 0, 1j, 1j, -1j, -1j]).';
            D = rand(6, 1);

            % Create table with rows in different orders
            orders = {
                [1, 2, 3, 4];
                [4, 3, 2, 1];
                [2, 1, 4, 3];
                [3, 1, 4, 2]
                };

            % Store first result for comparison
            DataTable = table(x(orders{1}), y(orders{1}), D(orders{1}));
            [DataRef, xRef, yRef] = tableToArray(2, DataTable);

            % Test all other orderings
            for i = 2:numel(orders)
                DataTable = table(x(orders{i}), y(orders{i}), D(orders{i}));
                [DataOut, xOut, yOut] = tableToArray(2, DataTable);

                testCase.verifyEqual(DataOut, DataRef);
                testCase.verifyEqual(xOut, xRef);
                testCase.verifyEqual(yOut, yRef);
            end
        end
    end
end