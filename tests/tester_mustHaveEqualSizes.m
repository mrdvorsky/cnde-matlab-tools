classdef tester_mustHaveEqualSizes < matlab.unittest.TestCase
    % Unit tests for "mustHaveEqualSizes" function.
    %
    % Author: Matt Dvorsky
    
    methods (Test)
        %% Basic Functionality Tests
        function test_equalSizes_2DArrays(testCase)
            A = rand(3, 4);
            B = rand(3, 4);
            testCase.verifyWarningFree(@() mustHaveEqualSizes(A, B));
        end
        
        function test_equalSizes_3DArrays(testCase)
            A = rand(2, 3, 4);
            B = rand(2, 3, 4);
            testCase.verifyWarningFree(@() mustHaveEqualSizes(A, B));
        end
        
        function test_equalSizes_repeatingArgs(testCase)
            A = rand(2, 2);
            B = rand(2, 2);
            C = rand(2, 2);
            testCase.verifyWarningFree(@() mustHaveEqualSizes(A, B, C));
        end
        
        %% Dimension Option Tests
        function test_specificDimensions(testCase)
            A = rand(2, 3, 5);
            B = rand(2, 4, 5);
            testCase.verifyWarningFree(...
                @() mustHaveEqualSizes(A, B, Dimensions=[1, 3]));
        end
        
        function test_excludeDimensions(testCase)
            A = rand(2, 3);
            B = rand(4, 3);
            testCase.verifyWarningFree(...
                @() mustHaveEqualSizes(A, B, ExcludeDimensions=1));
        end
        
        function test_allStringDimension(testCase)
            A = rand(2, 3, 4);
            B = rand(2, 3, 4);
            testCase.verifyWarningFree(...
                @() mustHaveEqualSizes(A, B, Dimensions="all"));
        end
        
        %% Error Condition Tests
        function testError_unequalSizes_2D(testCase)
            A = rand(2, 3);
            B = rand(3, 2);
            testCase.verifyError(@() mustHaveEqualSizes(A, B), ...
                "MATLAB:sizeDimensionsMustMatch");
        end
        
        function testError_unequalSizes_specificDimension(testCase)
            A = rand(2, 3, 4);
            B = rand(2, 4, 4);
            testCase.verifyError(...
                @() mustHaveEqualSizes(A, B, Dimensions=2), ...
                "MATLAB:sizeDimensionsMustMatch");
        end
        
        %% Edge Case Tests
        function testEdge_emptyArrays(testCase)
            A = zeros(0, 2);
            B = zeros(0, 2);
            testCase.verifyWarningFree(@() mustHaveEqualSizes(A, B));
        end
        
        function testEdge_singletonDimension(testCase)
            A = rand(1, 3);
            B = rand(2, 3);
            testCase.verifyError(@() mustHaveEqualSizes(A, B), ...
                "MATLAB:sizeDimensionsMustMatch");
        end
        
        function testEdge_scalarInputs(testCase)
            A = 5;
            B = 6;
            testCase.verifyWarningFree(@() mustHaveEqualSizes(A, B));
        end
        
        function testEdge_mixedDimensionInputs(testCase)
            A = rand(2, 3);
            B = rand(2, 3, 1);
            testCase.verifyWarningFree(@() mustHaveEqualSizes(A, B));
        end
        
        function testEdge_highDimensionalArrays(testCase)
            A = rand(2, 3, 4, 5, 6);
            B = rand(2, 3, 4, 5, 6);
            testCase.verifyWarningFree(@() mustHaveEqualSizes(A, B));
        end
    end
end