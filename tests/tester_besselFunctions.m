classdef tester_besselFunctions < matlab.unittest.TestCase
    % Unit tests for the Bessel function library.
    %
    % Author: [Your Name]
    
    properties
        tolVal = 1e-10;  % Tolerance value for comparisons
    end
    
    methods (Test)
        %% Tests for besseljprime
        function test_besseljprime_basic(testCase)
            % Test basic functionality against numerical derivative
            nu = 0;
            z = 1.5;
            
            % Theoretical value from the recurrence relation
            expected = 0.5 * (besselj(nu - 1, z) - besselj(nu + 1, z));
            actual = besseljprime(nu, z);
            
            testCase.verifyEqual(actual, expected, AbsTol=testCase.tolVal);
        end
        
        function test_besseljprime_vectorized(testCase)
            % Test with vector inputs
            nu = [0, 1, 2];
            z = [0.5, 1.0, 1.5];
            
            % Computing expected values
            expected = zeros(size(nu));
            for i = 1:length(nu)
                expected(i) = 0.5 * (besselj(nu(i) - 1, z(i)) - besselj(nu(i) + 1, z(i)));
            end
            
            actual = besseljprime(nu, z);
            
            testCase.verifyEqual(actual, expected, AbsTol=testCase.tolVal);
        end
        
        function test_besseljprime_scaled(testCase)
            % Test with scaling option
            nu = 1;
            z = 1.5 + 2i;
            
            % Scaled expected value
            expected = 0.5 * (besselj(nu - 1, z, true) - besselj(nu + 1, z, true));
            actual = besseljprime(nu, z, true);
            
            testCase.verifyEqual(actual, expected, AbsTol=testCase.tolVal);
        end
        
        %% Tests for besselyprime
        function test_besselyprime_basic(testCase)
            % Test basic functionality against theoretical value
            nu = 0;
            z = 1.5;
            
            % Theoretical value from the recurrence relation
            expected = 0.5 * (bessely(nu - 1, z) - bessely(nu + 1, z));
            actual = besselyprime(nu, z);
            
            testCase.verifyEqual(actual, expected, AbsTol=testCase.tolVal);
        end
        
        function test_besselyprime_vectorized(testCase)
            % Test with vector inputs
            nu = [0, 1, 2];
            z = [0.5, 1.0, 1.5];
            
            % Computing expected values
            expected = zeros(size(nu));
            for i = 1:length(nu)
                expected(i) = 0.5 * (bessely(nu(i) - 1, z(i)) - bessely(nu(i) + 1, z(i)));
            end
            
            actual = besselyprime(nu, z);
            
            testCase.verifyEqual(actual, expected, AbsTol=testCase.tolVal);
        end
        
        function test_besselyprime_scaled(testCase)
            % Test with scaling option
            nu = 1;
            z = 1.5 + 2i;
            
            % Scaled expected value
            expected = 0.5 * (bessely(nu - 1, z, true) - bessely(nu + 1, z, true));
            actual = besselyprime(nu, z, true);
            
            testCase.verifyEqual(actual, expected, AbsTol=testCase.tolVal);
        end
        
        %% Tests for besselhprime
        function test_besselhprime_kind1(testCase)
            % Test basic functionality for kind 1
            nu = 0;
            z = 1.5;
            kind = 1;
            
            % Theoretical value from the recurrence relation
            expected = 0.5 * (besselh(nu - 1, kind, z) - besselh(nu + 1, kind, z));
            actual = besselhprime(nu, kind, z);
            
            testCase.verifyEqual(actual, expected, AbsTol=testCase.tolVal);
        end
        
        function test_besselhprime_kind2(testCase)
            % Test basic functionality for kind 2
            nu = 1;
            z = 1.5;
            kind = 2;
            
            % Theoretical value from the recurrence relation
            expected = 0.5 * (besselh(nu - 1, kind, z) - besselh(nu + 1, kind, z));
            actual = besselhprime(nu, kind, z);
            
            testCase.verifyEqual(actual, expected, AbsTol=testCase.tolVal);
        end
        
        function test_besselhprime_scaled(testCase)
            % Test with scaling option
            nu = 1;
            z = 1.5 + 2i;
            kind = 1;
            
            % Scaled expected value
            expected = 0.5 * (besselh(nu - 1, kind, z, true) - besselh(nu + 1, kind, z, true));
            actual = besselhprime(nu, kind, z, true);
            
            testCase.verifyEqual(actual, expected, AbsTol=testCase.tolVal);
        end
        
        %% Tests for besseljy
        function test_besseljy_basic(testCase)
            % Test basic functionality
            alpha = 2.0;
            beta = 3.0;
            nu = 1;
            z = 1.5;
            
            % Expected linear combination
            expected = alpha * besselj(nu, z) + beta * bessely(nu, z);
            actual = besseljy(alpha, beta, nu, z);
            
            testCase.verifyEqual(actual, expected, AbsTol=testCase.tolVal);
        end
        
        function test_besseljy_vectorized(testCase)
            % Test with vector inputs
            alpha = [1.0, 2.0, 3.0];
            beta = [3.0, 2.0, 1.0];
            nu = [0, 1, 2];
            z = [0.5, 1.0, 1.5];
            
            % Computing expected values
            expected = zeros(size(nu));
            for i = 1:length(nu)
                expected(i) = alpha(i) * besselj(nu(i), z(i)) + beta(i) * bessely(nu(i), z(i));
            end
            
            actual = besseljy(alpha, beta, nu, z);
            
            testCase.verifyEqual(actual, expected, AbsTol=testCase.tolVal);
        end
        
        function test_besseljy_scaled(testCase)
            % Test with scaling option
            alpha = 2.0;
            beta = 3.0;
            nu = 1;
            z = 1.5 + 2i;
            
            % Scaled expected value
            expected = alpha * besselj(nu, z, true) + beta * bessely(nu, z, true);
            actual = besseljy(alpha, beta, nu, z, true);
            
            testCase.verifyEqual(actual, expected, AbsTol=testCase.tolVal);
        end
        
        %% Tests for besseljyprime
        function test_besseljyprime_basic(testCase)
            % Test basic functionality
            alpha = 2.0;
            beta = 3.0;
            nu = 1;
            z = 1.5;
            
            % Expected derivative from recurrence relation
            expected = 0.5 * (besseljy(alpha, beta, nu - 1, z) - besseljy(alpha, beta, nu + 1, z));
            actual = besseljyprime(alpha, beta, nu, z);
            
            testCase.verifyEqual(actual, expected, AbsTol=testCase.tolVal);
        end
        
        function test_besseljyprime_vectorized(testCase)
            % Test with vector inputs
            alpha = [1.0, 2.0, 3.0];
            beta = [3.0, 2.0, 1.0];
            nu = [0, 1, 2];
            z = [0.5, 1.0, 1.5];
            
            % Computing expected values
            expected = zeros(size(nu));
            for i = 1:length(nu)
                expected(i) = 0.5 * (besseljy(alpha(i), beta(i), nu(i) - 1, z(i)) - ...
                                     besseljy(alpha(i), beta(i), nu(i) + 1, z(i)));
            end
            
            actual = besseljyprime(alpha, beta, nu, z);
            
            testCase.verifyEqual(actual, expected, AbsTol=testCase.tolVal);
        end
        
        function test_besseljyprime_scaled(testCase)
            % Test with scaling option
            alpha = 2.0;
            beta = 3.0;
            nu = 1;
            z = 1.5 + 2i;
            
            % Scaled expected value
            expected = 0.5 * (besseljy(alpha, beta, nu - 1, z, true) - ...
                             besseljy(alpha, beta, nu + 1, z, true));
            actual = besseljyprime(alpha, beta, nu, z, true);
            
            testCase.verifyEqual(actual, expected, AbsTol=testCase.tolVal);
        end
        
        %% Tests for besselj_spherical
        function test_besselj_spherical_basic(testCase)
            % Test basic functionality
            nu = 0;
            z = 1.5;
            
            % Expected spherical Bessel function
            expected = sqrt(0.5*pi) / sqrt(z) * besselj(0.5 + nu, z);
            actual = besselj_spherical(nu, z);
            
            testCase.verifyEqual(actual, expected, AbsTol=testCase.tolVal);
        end
        
        function test_besselj_spherical_nu0_at_origin(testCase)
            % Test special case at z=0 for nu=0
            nu = 0;
            z = 0;
            
            % Expected value at origin for nu=0 is 1
            expected = 1;
            actual = besselj_spherical(nu, z);
            
            testCase.verifyEqual(actual, expected);
        end
        
        function test_besselj_spherical_nu1_at_origin(testCase)
            % Test special case at z=0 for nu=1
            nu = 1;
            z = 0;
            
            % Expected value at origin for nu=1 is 0
            expected = 0;
            actual = besselj_spherical(nu, z);
            
            testCase.verifyEqual(actual, expected);
        end
        
        function test_besselj_spherical_vectorized(testCase)
            % Test with vector inputs
            nu = [0, 1, 2];
            z = [0.5, 1.0, 1.5];
            
            % Computing expected values
            expected = zeros(size(nu));
            for i = 1:length(nu)
                if abs(z(i)) <= eps
                    expected(i) = (nu(i) == 0);
                else
                    expected(i) = sqrt(0.5*pi) / sqrt(z(i)) * besselj(0.5 + nu(i), z(i));
                end
            end
            
            actual = besselj_spherical(nu, z);
            
            testCase.verifyEqual(actual, expected, AbsTol=testCase.tolVal);
        end
        
        function test_besselj_spherical_scaled(testCase)
            % Test with scaling option
            nu = 1;
            z = 1.5 + 2i;
            
            % Scaled expected value
            expected = sqrt(0.5*pi) / sqrt(z) * besselj(0.5 + nu, z, true);
            actual = besselj_spherical(nu, z, true);
            
            testCase.verifyEqual(actual, expected, AbsTol=testCase.tolVal);
        end
        
        function test_besselj_spherical_non_integer_error(testCase)
            % Test error for non-integer nu
            nu = 1.5;
            z = 1.5;
            
            % Expect validation error
            testCase.verifyError(@() besselj_spherical(nu, z), "MATLAB:validators:mustBeInteger");
        end
        
        %% Tests for bessely_spherical
        function test_bessely_spherical_basic(testCase)
            % Test basic functionality
            nu = 0;
            z = 1.5;
            
            % Expected spherical Bessel function
            expected = sqrt(0.5*pi) / sqrt(z) * bessely(0.5 + nu, z);
            actual = bessely_spherical(nu, z);
            
            testCase.verifyEqual(actual, expected, AbsTol=testCase.tolVal);
        end
        
        function test_bessely_spherical_vectorized(testCase)
            % Test with vector inputs
            nu = [0, 1, 2];
            z = [0.5, 1.0, 1.5];
            
            % Computing expected values
            expected = zeros(size(nu));
            for i = 1:length(nu)
                expected(i) = sqrt(0.5*pi) / sqrt(z(i)) * bessely(0.5 + nu(i), z(i));
            end
            
            actual = bessely_spherical(nu, z);
            
            testCase.verifyEqual(actual, expected, AbsTol=testCase.tolVal);
        end
        
        function test_bessely_spherical_scaled(testCase)
            % Test with scaling option
            nu = 1;
            z = 1.5 + 2i;
            
            % Scaled expected value
            expected = sqrt(0.5*pi) / sqrt(z) * bessely(0.5 + nu, z, true);
            actual = bessely_spherical(nu, z, true);
            
            testCase.verifyEqual(actual, expected, AbsTol=testCase.tolVal);
        end
        
        function test_bessely_spherical_non_integer_error(testCase)
            % Test error for non-integer nu
            nu = 1.5;
            z = 1.5;
            
            % Expect validation error
            testCase.verifyError(@() bessely_spherical(nu, z), "MATLAB:validators:mustBeInteger");
        end
        
        %% Tests for besselh_spherical
        function test_besselh_spherical_kind1(testCase)
            % Test basic functionality for kind 1
            nu = 0;
            z = 1.5;
            kind = 1;
            
            % Expected spherical Hankel function
            expected = sqrt(0.5*pi) / sqrt(z) * besselh(0.5 + nu, kind, z);
            actual = besselh_spherical(nu, kind, z);
            
            testCase.verifyEqual(actual, expected, AbsTol=testCase.tolVal);
        end
        
        function test_besselh_spherical_kind2(testCase)
            % Test basic functionality for kind 2
            nu = 1;
            z = 1.5;
            kind = 2;
            
            % Expected spherical Hankel function
            expected = sqrt(0.5*pi) / sqrt(z) * besselh(0.5 + nu, kind, z);
            actual = besselh_spherical(nu, kind, z);
            
            testCase.verifyEqual(actual, expected, AbsTol=testCase.tolVal);
        end
        
        function test_besselh_spherical_vectorized(testCase)
            % Test with vector inputs
            nu = [0, 1, 2];
            z = [0.5, 1.0, 1.5];
            kind = 1;
            
            % Computing expected values
            expected = zeros(size(nu));
            for i = 1:length(nu)
                expected(i) = sqrt(0.5*pi) / sqrt(z(i)) * besselh(0.5 + nu(i), kind, z(i));
            end
            
            actual = besselh_spherical(nu, kind, z);
            
            testCase.verifyEqual(actual, expected, AbsTol=testCase.tolVal);
        end
        
        function test_besselh_spherical_scaled(testCase)
            % Test with scaling option
            nu = 1;
            z = 1.5 + 2i;
            kind = 1;
            
            % Scaled expected value
            expected = sqrt(0.5*pi) / sqrt(z) * besselh(0.5 + nu, kind, z, true);
            actual = besselh_spherical(nu, kind, z, true);
            
            testCase.verifyEqual(actual, expected, AbsTol=testCase.tolVal);
        end
        
        function test_besselh_spherical_invalid_kind(testCase)
            % Test error for invalid kind value
            nu = 1;
            z = 1.5;
            kind = 3; % Invalid, must be 1 or 2
            
            % Expect validation error
            testCase.verifyError(@() besselh_spherical(nu, kind, z), ...
                               "MATLAB:validators:mustBeMember");
        end
        
        function test_besselh_spherical_non_integer_error(testCase)
            % Test error for non-integer nu
            nu = 1.5;
            z = 1.5;
            kind = 1;
            
            % Expect validation error
            testCase.verifyError(@() besselh_spherical(nu, kind, z), ...
                               "MATLAB:validators:mustBeInteger");
        end
        
        %% Edge Cases and Special Values
        function test_besseljprime_zero(testCase)
            % Test derivative at z=0 for various orders
            testCase.verifyEqual(besseljprime(0, 0), 0.5, AbsTol=testCase.tolVal);
            testCase.verifyEqual(besseljprime(1, 0), 0.5, AbsTol=testCase.tolVal);
            testCase.verifyEqual(besseljprime(2, 0), 0, AbsTol=testCase.tolVal);
        end
        
        function test_relationship_between_functions(testCase)
            % Test relationship between besseljy and besseljyprime
            alpha = 2;
            beta = 3;
            nu = 1;
            z = 1.5;
            
            % Derivative of linear combination equals linear combination of derivatives
            jyPrime = besseljyprime(alpha, beta, nu, z);
            jprime = besseljprime(nu, z);
            yprime = besselyprime(nu, z);
            
            testCase.verifyEqual(jyPrime, alpha * jprime + beta * yprime, AbsTol=testCase.tolVal);
        end
        
        function test_special_identity(testCase)
            % Test special identity for Bessel functions (J_{-n}(z) = (-1)^n J_n(z) for integer n)
            n = 2;
            z = 1.5;
            
            j_neg = besselj(-n, z);
            j_pos = (-1)^n * besselj(n, z);
            
            testCase.verifyEqual(j_neg, j_pos, AbsTol=testCase.tolVal);
        end
    end
end