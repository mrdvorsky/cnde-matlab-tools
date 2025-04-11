classdef tester_vectorize < matlab.unittest.TestCase
    % Unit tests for "vectorize" function.
    %
    % Author: Matt Dvorsky

    methods (Test)
        %% Basic Functionality Tests
        function test_defaultDim(testCase)
            arr = [...
                1, 2; ...
                3, 4];
            vec = vectorize(arr);
            testCase.verifyEqual(vec, [1; 3; 2; 4]);
        end

        function test_dim1(testCase)
            arr = [...
                1, 2; ...
                3, 4];
            vec = vectorize(arr, 1);
            testCase.verifyEqual(vec, [1; 3; 2; 4]);
        end

        function test_dim2(testCase)
            arr = [...
                1, 2; ...
                3, 4];
            vec = vectorize(arr, 2);
            testCase.verifyEqual(vec, [1, 3, 2, 4]);
        end

        function test_dim3(testCase)
            arr = rand(2, 2, 2);
            vec = vectorize(arr, 3);
            testCase.verifyEqual(size(vec), [1, 1, 8]);
        end

        %% Edge Case Tests
        function testEdge_emptyInput1(testCase)
            vec = vectorize([], 1);
            testCase.verifyEqual(size(vec), [0, 1]);
        end

        function testEdge_emptyInput2(testCase)
            vec = vectorize([], 2);
            testCase.verifyEqual(size(vec), [1, 0]);
        end

        function testEdge_emptyInput3(testCase)
            vec = vectorize([], 3);
            testCase.verifyEqual(size(vec), [1, 1, 0]);
        end

        function testEdge_singleElement(testCase)
            vec = vectorize(5, 2);
            testCase.verifyEqual(vec, 5);
        end

        %% Error Condition Tests
        function testError_nonIntegerDim(testCase)
            testCase.verifyError(@() vectorize([1, 2], 1.5), ...
                'MATLAB:validators:mustBeInteger');
        end

        function testError_nonPositiveDim(testCase)
            testCase.verifyError(@() vectorize([1, 2], 0), ...
                'MATLAB:validators:mustBePositive');
        end
    end
end