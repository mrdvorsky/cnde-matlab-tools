classdef tester_innerProduct < matlab.unittest.TestCase
    % Unit tests for "innerProduct" function.
    %
    % Author: Matt Dvorky

    properties
        tolVal = 1e-14;
    end

    methods (Test)
        %% Basic Functionality Tests
        function test_basicVectorInput1(testCase)
            a = [1, 2, 3];
            b = [4, 5, 6];

            % Test sum mode
            result = innerProduct(a, b, 2);
            expected = sum(a.*b);
            testCase.verifyEqual(result, expected, ...
                AbsTol=testCase.tolVal);

            % Test mean mode
            result = innerProduct(a, b, 2, SummationMode="mean");
            expected = mean(a.*b);
            testCase.verifyEqual(result, expected, ...
                AbsTol=testCase.tolVal);
        end

        function test_basicVectorInput2(testCase)
            a = [1, 2, 3].';
            b = [4, 5, 6].';

            % Test sum mode
            result = innerProduct(a, b, 2);
            expected = sum(a.*b, 2);
            testCase.verifyEqual(result, expected, ...
                AbsTol=testCase.tolVal);

            % Test mean mode
            result = innerProduct(a, b, 2, SummationMode="mean");
            expected = mean(a.*b, 2);
            testCase.verifyEqual(result, expected, ...
                AbsTol=testCase.tolVal);
        end

        function test_basicVectorInput3(testCase)
            a = [1, 2, 3].';
            b = [4, 5, 6].';

            % Test sum mode
            result = innerProduct(a, b, 1);
            expected = sum(a.*b, 1);
            testCase.verifyEqual(result, expected, ...
                AbsTol=testCase.tolVal);

            % Test mean mode
            result = innerProduct(a, b, 1, SummationMode="mean");
            expected = mean(a.*b, 1);
            testCase.verifyEqual(result, expected, ...
                AbsTol=testCase.tolVal);
        end

        function test_basicMatrixInput(testCase)
            A = [1, 2; 3, 4];
            B = [5, 6; 7, 8];

            % Test sum mode
            result = innerProduct(A, B, 2);
            expected = sum(A.*B, 2);
            testCase.verifyEqual(result, expected, ...
                AbsTol=testCase.tolVal);

            % Test mean mode
            result = innerProduct(A, B, 2, SummationMode="mean");
            expected = mean(A.*B, 2);
            testCase.verifyEqual(result, expected, ...
                AbsTol=testCase.tolVal);
        end

        function test_multipleDimensions(testCase)
            A = rand(3, 4, 5);
            B = rand(3, 4, 5);

            % Test sum mode
            result = innerProduct(A, B, [1, 3]);
            expected = sum(A.*B, [1, 3]);
            testCase.verifyEqual(result, expected, ...
                AbsTol=testCase.tolVal);

            % Test mean mode
            result = innerProduct(A, B, [1, 3], SummationMode="mean");
            expected = mean(A.*B, [1, 3]);
            testCase.verifyEqual(result, expected, ...
                AbsTol=testCase.tolVal);
        end

        function test_allDimensions(testCase)
            A = rand(2, 3, 4);
            B = rand(2, 3, 4);

            % Test sum mode
            result = innerProduct(A, B, "all");
            expected = sum(A.*B, "all");
            testCase.verifyEqual(result, expected,...
                AbsTol=testCase.tolVal);

            % Test mean mode
            result = innerProduct(A, B, "all", SummationMode="mean");
            expected = mean(A.*B, "all");
            testCase.verifyEqual(result, expected, ...
                AbsTol=testCase.tolVal);
        end

        %% Broadcasting Tests
        function test_broadcasting(testCase)
            A = rand(3, 1, 5);
            B = rand(1, 4, 5);

            % Test sum mode
            result = innerProduct(A, B, 3);
            expected = sum(A.*B, 3);
            testCase.verifyEqual(result, expected, ...
                AbsTol=testCase.tolVal);

            % Test mean mode
            result = innerProduct(A, B, 3, SummationMode="mean");
            expected = mean(A.*B, 3);
            testCase.verifyEqual(result, expected, ...
                AbsTol=testCase.tolVal);
        end

        %% Data Type Tests
        function test_intDataTypes1(testCase)
            A = randi([-3, 3], 1, 4, 1, 5, "int16");
            B = randi([-3, 3], 3, 1, 2, 5, "int16");

            % Test sum mode
            result = innerProduct(A, B, 4);
            expected = sum(double(A).*double(B), 4);
            testCase.verifyEqual(result, expected, ...
                AbsTol=testCase.tolVal);

            % Test mean mode
            result = innerProduct(A, B, 4, SummationMode="mean");
            expected = mean(double(A).*double(B), 4);
            testCase.verifyEqual(result, expected, ...
                AbsTol=testCase.tolVal);
        end

        function test_intDataTypes2(testCase)
            A = randi([0, 3], 1, 4, 1, 5, "uint16");
            B = randi([-3, 3], 3, 1, 2, 5, "int16");

            % Test sum mode
            result = innerProduct(A, B, [1, 4]);
            expected = sum(double(A).*double(B), [1, 4]);
            testCase.verifyEqual(result, expected, ...
                AbsTol=testCase.tolVal);

            % Test mean mode
            result = innerProduct(A, B, [1, 4], SummationMode="mean");
            expected = mean(double(A).*double(B), [1, 4]);
            testCase.verifyEqual(result, expected, ...
                AbsTol=testCase.tolVal);
        end

        function test_singlePrecType(testCase)
            A = randi([0, 3], 1, 4, 1, 5, "single");
            B = randi([-3, 3], 3, 1, 2, 5, "double");

            % Test sum mode
            result = innerProduct(A, B, [1, 4]);
            expected = sum(A.*B, [1, 4]);
            testCase.verifyEqual(result, expected, ...
                AbsTol=testCase.tolVal);

            % Test mean mode
            result = innerProduct(A, B, [1, 4], SummationMode="mean");
            expected = mean(A.*B, [1, 4]);
            testCase.verifyEqual(result, expected, ...
                AbsTol=testCase.tolVal);
        end

        %% Edge Case Tests
        function testEdge_dimensionArgGreaterThanNumDims(testCase)
            A = rand(3, 4);
            B = rand(3, 4);

            % Test sum mode
            result = innerProduct(A, B, 3);
            expected = A.*B;
            testCase.verifyEqual(result, expected, ...
                AbsTol=testCase.tolVal);

            % Test mean mode (should be same as sum since no summation occurs)
            result = innerProduct(A, B, 3, SummationMode="mean");
            testCase.verifyEqual(result, expected, ...
                AbsTol=testCase.tolVal);
        end

        function testEdge_emptyInputDimToSum(testCase)
            A = zeros(3, 0, 2);
            B = rand(3, 0, 2);

            % Test sum mode
            result = innerProduct(A, B, 2);
            testCase.verifySize(result, [3, 1, 2]);
            testCase.verifyEqual(result, zeros(3, 1, 2));

            % Test mean mode (should be nan)
            result = innerProduct(A, B, 2, SummationMode="mean");
            testCase.verifySize(result, [3, 1, 2]);
            testCase.verifyEqual(result, nan(3, 1, 2));
        end

        function testEdge_emptyInputDimNotSummed(testCase)
            A = zeros(3, 1, 2, 1);
            B = rand(1, 0, 2, 4);

            % Test sum mode
            result = innerProduct(A, B, 3);
            testCase.verifySize(result, [3, 0, 1, 4]);

            % Test mean mode
            result = innerProduct(A, B, 3, SummationMode="mean");
            testCase.verifySize(result, [3, 0, 1, 4]);
        end

        function testEdge_emptyDims(testCase)
            A = rand(3, 4);
            B = rand(3, 4);

            % Test sum mode
            result = innerProduct(A, B, []);
            expected = A.*B;
            testCase.verifyEqual(result, expected);

            % Test mean mode (should be same as sum)
            result = innerProduct(A, B, [], SummationMode="mean");
            testCase.verifyEqual(result, expected);
        end

        function testEdge_singletonDimensions(testCase)
            A = rand(1, 4, 1, 5);
            B = rand(3, 1, 2, 5);

            % Test sum mode
            result = innerProduct(A, B, 4);
            expected = sum(A.*B, 4);
            testCase.verifyEqual(result, expected, ...
                AbsTol=testCase.tolVal);

            % Test mean mode
            result = innerProduct(A, B, 4, SummationMode="mean");
            expected = mean(A.*B, 4);
            testCase.verifyEqual(result, expected, ...
                AbsTol=testCase.tolVal);
        end

        function testEdge_complexInputs(testCase)
            A = [1+2i, 3+4i];
            B = [5-6i, 7-8i];

            % Test sum mode
            result = innerProduct(A, B, 2);
            expected = sum(A.*B, 2);
            testCase.verifyEqual(result, expected);

            % Test mean mode
            result = innerProduct(A, B, 2, SummationMode="mean");
            expected = mean(A.*B, 2);
            testCase.verifyEqual(result, expected);
        end

        %% Error Condition Tests
        function testError_incompatibleSizes(testCase)
            A = rand(3, 4);
            B = rand(3, 5);

            testCase.verifyError(@() innerProduct(A, B, 2), ...
                "MATLAB:sizeDimensionsMustMatch");
            testCase.verifyError(@() innerProduct(A, B, 2, SummationMode="mean"), ...
                "MATLAB:sizeDimensionsMustMatch");
        end

        function testError_invalidSummationMode(testCase)
            testCase.verifyError(@() innerProduct([], [], 1, ...
                SummationMode="invalid"), ...
                "MATLAB:validators:mustBeMember");
        end
    end
end