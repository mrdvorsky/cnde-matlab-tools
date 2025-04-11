classdef tester_broadcastSize < matlab.unittest.TestCase
    % Unit tests for "broadcastSize" function.
    %
    % Author: Matt Dvorsky

    methods (Test)
        %% Basic Functionality Tests
        function test_basicBroadcast(testCase)
            A = ones(3, 1);
            B = ones(1, 4);
            dimSizes = broadcastSize(A, B);
            testCase.verifyEqual(dimSizes, [3, 4]);
        end

        function test_specifiedDimensions(testCase)
            A = ones(3, 1, 5);
            B = ones(1, 4, 1);
            dimSizes = broadcastSize(A, B, Dimensions=[1, 2]);
            testCase.verifyEqual(dimSizes, [3, 4]);
        end

        function test_allDimensions(testCase)
            A = ones(3, 1, 5);
            B = ones(1, 4, 5);
            dimSizes = broadcastSize(A, B, Dimensions="all");
            testCase.verifyEqual(dimSizes, [3, 4, 5]);
        end

        function test_allDimensions_manyArgs(testCase)
            A = ones(3, 1, 5);
            B = ones(1, 4, 5);
            C = ones(1, 1, 1);
            dimSizes = broadcastSize(A, B, C, Dimensions="all");
            testCase.verifyEqual(dimSizes, [3, 4, 5]);
        end

        %% Error Condition Tests
        function testError_incompatibleSizes(testCase)
            testCase.verifyError(@() broadcastSize(ones(3, 2), ones(4, 1)), ...
                "CNDE:mustBeBroadcastable");
        end

        function testError_incompatibleSizes_manyArgs(testCase)
            testCase.verifyError(@() broadcastSize(ones(3, 2), ones(3, 1), ones(1, 3)), ...
                "CNDE:mustBeBroadcastable");
        end

        function testError_invalidDimension(testCase)
            testCase.verifyError(@() broadcastSize(ones(2, 2), Dimensions=0), ...
                "CNDE:mustBeValidDimension");
        end

        function testError_noArgs(testCase)
            testCase.verifyError(@() broadcastSize(), ...
                "CNDE:mustBeNonemptyRepeatingArgs");
        end

        function testError_noArgsWithDimensionSpec(testCase)
            testCase.verifyError(@() broadcastSize(Dimensions=1), ...
                "CNDE:mustBeNonemptyRepeatingArgs");
        end

        %% Edge Case Tests
        function testEdge_emptyArrays(testCase)
            dimSizes = broadcastSize([], []);
            testCase.verifyEqual(dimSizes, [0, 0]);
        end

        function testEdge_mixedEmpty(testCase)
            dimSizes = broadcastSize(ones(0, 3, 1), ones(0, 1, 2));
            testCase.verifyEqual(dimSizes, [0, 3, 2]);
        end

        function testEdge_singleArg(testCase)
            dimSizes = broadcastSize(ones(2, 3));
            testCase.verifyEqual(dimSizes, [2, 3]);
        end
    end
end