classdef tester_broadcastArrays < matlab.unittest.TestCase
    % Unit tests for "broadcastArrays" function.
    %
    % Author: Matt Dvorsky

    methods (Test)
        %% Basic Functionality Tests
        function test_basicBroadcast(testCase)
            A = ones(5, 1);
            B = ones(1, 5);
            [Aout, Bout] = broadcastArrays(A, B);
            testCase.verifyEqual(size(Aout), [5, 5]);
            testCase.verifyEqual(size(Bout), [5, 5]);
        end

        function test_3dBroadcast(testCase)
            A = ones(5, 6, 1);
            B = ones(5, 1, 7);
            [Aout, Bout] = broadcastArrays(A, B);
            testCase.verifyEqual(size(Aout), [5, 6, 7]);
            testCase.verifyEqual(size(Bout), [5, 6, 7]);
        end

        function test_3dBroadcast_multipleArgs(testCase)
            A = ones(5, 6, 1);
            B = ones(5, 1, 7);
            C = ones(5, 1, 1);
            [Aout, Bout, Cout] = broadcastArrays(A, B, C);
            testCase.verifyEqual(size(Aout), [5, 6, 7]);
            testCase.verifyEqual(size(Bout), [5, 6, 7]);
            testCase.verifyEqual(size(Cout), [5, 6, 7]);
        end

        function test_argClassPreservation(testCase)
            A = ones(5, 6, "int8");
            B = ones(5, 1, "single");
            C = true(5, 1);
            [Aout, Bout, Cout] = broadcastArrays(A, B, C);
            testCase.verifyClass(Aout, "int8");
            testCase.verifyClass(Bout, "single");
            testCase.verifyClass(Cout, "logical");
        end

        %% Error Condition Tests
        function testError_incompatibleSizes(testCase)
            testCase.verifyError(@() broadcastArrays(ones(5, 6), ones(1, 5)), ...
                "MATLAB:sizeDimensionsMustMatch");
        end

        function testError_incompatibleSizes_manyArgs(testCase)
            testCase.verifyError(@() broadcastArrays(ones(5, 6), ones(1, 6), ones(2, 1)), ...
                "MATLAB:sizeDimensionsMustMatch");
        end

        function testError_moreOutputsThanInputs1(testCase)
            function testFun()
                [~] = broadcastArrays();
            end

            testCase.verifyError(@testFun, ...
                "MATLAB:unassignedOutputs");
        end

        function testError_moreOutputsThanInputs2(testCase)
            function testFun()
                [~, ~] = broadcastArrays(0);
            end

            testCase.verifyError(@testFun, ...
                "MATLAB:unassignedOutputs");
        end

        %% Edge Case Tests
        function testEdge_noArgs(testCase)
            testCase.verifyWarningFree(@() broadcastArrays());
        end

        function testEdge_singleArg(testCase)
            Aout = broadcastArrays(ones(2, 1));
            testCase.verifyEqual(size(Aout), [2, 1]);
        end

        function testEdge_emptyArray1(testCase)
            [Aout, Bout] = broadcastArrays(ones(0, 1), ones(1, 0));
            testCase.verifyEqual(size(Aout), [0, 0]);
            testCase.verifyEqual(size(Bout), [0, 0]);
        end

        function testEdge_emptyArray2(testCase)
            [Aout, Bout] = broadcastArrays(ones(1, 1), ones(1, 0));
            testCase.verifyEqual(size(Aout), [1, 0]);
            testCase.verifyEqual(size(Bout), [1, 0]);
        end

        function testEdge_customTypes(testCase)
            [Aout, Bout] = broadcastArrays(ones(1, 1), ones(1, 0));
            testCase.verifyEqual(size(Aout), [1, 0]);
            testCase.verifyEqual(size(Bout), [1, 0]);
        end
    end
end