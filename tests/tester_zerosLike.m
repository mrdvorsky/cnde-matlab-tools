classdef tester_zerosLike < matlab.unittest.TestCase
    % Unit tests for "zerosLike" function.
    %
    % Author: Matt Dvorsky

    methods (Test)
        %% Basic Functionality Tests
        function test_singleInputDefaultType(testCase)
            arr = single([1, 2; 3, 4]);

            zerosArr = zerosLike(arr);

            testCase.verifyClass(zerosArr, "single");
            testCase.verifyEqual(size(zerosArr), size(arr));
            testCase.verifyEqual(zerosArr, zeros(size(arr), "single"));
        end

        function test_multipleInputsInferType1(testCase)
            arr1 = int8([1, 2]);
            arr2 = int8([3; 4]);

            zerosArr = zerosLike(arr1, arr2);

            testCase.verifyClass(zerosArr, "int8");
            testCase.verifySize(zerosArr, [2, 2]);
        end

        function test_multipleInputsInferType2(testCase)
            arr1 = int8([1, 2, 3]);
            arr2 = double([3; 4]);

            zerosArr = zerosLike(arr1, arr2);

            testCase.verifyClass(zerosArr, "int8");
            testCase.verifySize(zerosArr, [2, 3]);
        end

        function test_multipleInputsInferType3(testCase)
            arr1 = int8([1, 2]);
            arr2 = int16([3; 4; 5]);

            zerosArr = zerosLike(arr1, arr2);

            testCase.verifyClass(zerosArr, "double");
            testCase.verifySize(zerosArr, [3, 2]);
        end

        function test_specifiedType(testCase)
            arr = magic(3);

            zerosArr = zerosLike(arr, Type="uint8");

            testCase.verifyClass(zerosArr, "uint8");
            testCase.verifyEqual(zerosArr, zeros(3, 3, "uint8"));
        end

        %% Edge Case Tests
        function testEdge_emptyInput(testCase)
            arr = [];

            zerosArr = zerosLike(arr);

            testCase.verifyEmpty(zerosArr);
            testCase.verifySize(zerosArr, [0, 0]);
        end

        function testEdge_scalarInput(testCase)
            arr = 5;

            zerosArr = zerosLike(arr);

            testCase.verifyEqual(zerosArr, 0);
            testCase.verifySize(zerosArr, size(arr));
        end

        function testEdge_logicalInput(testCase)
            arr = true(2, 3);

            zerosArr = zerosLike(arr);

            testCase.verifyClass(zerosArr, "logical");
            testCase.verifyEqual(zerosArr, false(2, 3));
        end

        %% Error Condition Tests
        function testError_noInputs(testCase)
            testCase.verifyError(@() zerosLike(), ...
                "MATLAB:narginchk:notEnoughInputs");
        end

        function testError_invalidTypeOption(testCase)
            arr = [1, 2, 3];
            testCase.verifyError(@() zerosLike(arr, Type="invalid"), ...
                "MATLAB:validators:mustBeMember");
        end
    end
end