classdef tester_onesLike < matlab.unittest.TestCase
    % Unit tests for "onesLike" function.
    %
    % Author: Matt Dvorsky

    methods (Test)
        %% Basic Functionality Tests
        function test_singleInputDefaultType(testCase)
            arr = single([1, 2; 3, 4]);

            zerosArr = onesLike(arr);

            testCase.verifyClass(zerosArr, "single");
            testCase.verifyEqual(size(zerosArr), size(arr));
            testCase.verifyEqual(zerosArr, ones(size(arr), "single"));
        end

        function test_multipleInputsInferType1(testCase)
            arr1 = int8([1, 2]);
            arr2 = int8([3; 4]);

            zerosArr = onesLike(arr1, arr2);

            testCase.verifyClass(zerosArr, "int8");
            testCase.verifySize(zerosArr, [2, 2]);
        end

        function test_multipleInputsInferType2(testCase)
            arr1 = int8([1, 2, 3]);
            arr2 = double([3; 4]);

            zerosArr = onesLike(arr1, arr2);

            testCase.verifyClass(zerosArr, "int8");
            testCase.verifySize(zerosArr, [2, 3]);
        end

        function test_multipleInputsInferType3(testCase)
            arr1 = int8([1, 2]);
            arr2 = int16([3; 4; 5]);

            zerosArr = onesLike(arr1, arr2);

            testCase.verifyClass(zerosArr, "double");
            testCase.verifySize(zerosArr, [3, 2]);
        end

        function test_specifiedType(testCase)
            arr = magic(3);

            zerosArr = onesLike(arr, Type="uint8");

            testCase.verifyClass(zerosArr, "uint8");
            testCase.verifyEqual(zerosArr, ones(3, 3, "uint8"));
        end

        %% Edge Case Tests
        function testEdge_emptyInput(testCase)
            arr = [];

            zerosArr = onesLike(arr);

            testCase.verifyEmpty(zerosArr);
            testCase.verifySize(zerosArr, [0, 0]);
        end

        function testEdge_scalarInput(testCase)
            arr = 5;

            zerosArr = onesLike(arr);

            testCase.verifyEqual(zerosArr, 1);
            testCase.verifySize(zerosArr, size(arr));
        end

        function testEdge_logicalInput(testCase)
            arr = true(2, 3);

            zerosArr = onesLike(arr);

            testCase.verifyClass(zerosArr, "logical");
            testCase.verifyEqual(zerosArr, true(2, 3));
        end

        %% Error Condition Tests
        function testError_noInputs(testCase)
            testCase.verifyError(@() onesLike(), ...
                "MATLAB:narginchk:notEnoughInputs");
        end

        function testError_invalidTypeOption(testCase)
            arr = [1, 2, 3];
            testCase.verifyError(@() onesLike(arr, Type="invalid"), ...
                "MATLAB:validators:mustBeMember");
        end
    end
end