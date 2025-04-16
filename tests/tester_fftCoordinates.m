classdef tester_fftCoordinates < matlab.unittest.TestCase
    % Unit tests for "fftCoordinates" function.
    %
    % Author: Matt Dvorsky

    properties
        tolVal = 1e-13;
    end

    methods (Test)
        %% Basic Functionality Tests
        function test_1DCoordinates_Odd(testCase)
            dx = 0.31;
            Nx = 5;
            x = dx * (1:Nx);

            kxExpected = pi * ifftshift(-(Nx-1):2:(Nx-1)).' ./ (Nx * dx);

            kx = fftCoordinates(x);
            testCase.verifyEqual(kx, kxExpected, ...
                AbsTol=testCase.tolVal);

            kx = fftCoordinates(x, ApplyFftShift=true);
            testCase.verifyEqual(kx, fftshift(kxExpected), ...
                AbsTol=testCase.tolVal);

            kx = fftCoordinates(x, PositiveOutput=true);
            testCase.verifyEqual(kx, fftshift(kxExpected + abs(min(kxExpected))), ...
                AbsTol=testCase.tolVal);

            kx = fftCoordinates(x, ApplyFftShift=true, PositiveOutput=true);
            testCase.verifyEqual(kx, fftshift(fftshift(kxExpected + abs(min(kxExpected)))), ...
                AbsTol=testCase.tolVal);
        end

        function test_1DCoordinates_Even(testCase)
            dx = 0.31;
            Nx = 4;
            x = dx * (1:Nx);

            kxExpected = pi * ifftshift(-(Nx-0):2:(Nx-2)).' ./ (Nx * dx);

            kx = fftCoordinates(x);
            testCase.verifyEqual(kx, kxExpected, ...
                AbsTol=testCase.tolVal);

            kx = fftCoordinates(x, ApplyFftShift=true);
            testCase.verifyEqual(kx, fftshift(kxExpected), ...
                AbsTol=testCase.tolVal);

            kx = fftCoordinates(x, PositiveOutput=true);
            testCase.verifyEqual(kx, fftshift(kxExpected + abs(min(kxExpected))), ...
                AbsTol=testCase.tolVal);

            kx = fftCoordinates(x, ApplyFftShift=true, PositiveOutput=true);
            testCase.verifyEqual(kx, fftshift(fftshift(kxExpected + abs(min(kxExpected)))), ...
                AbsTol=testCase.tolVal);
        end

        function test_2DCoordinates_EvenOdd(testCase)
            dx = 0.31;
            Nx = 4;
            x = dx * (1:Nx);

            dy = 0.41;
            Ny = 5;
            y = dy * (1:Ny);

            kxExpected(:, 1) = pi * ifftshift(-(Nx):2:(Nx-2)).' ./ (Nx * dx);
            kyExpected(1, :) = pi * ifftshift(-(Ny-1):2:(Ny-1)).' ./ (Ny * dy);


            [kx, ky] = fftCoordinates(x, y);
            testCase.verifyEqual(kx, kxExpected, ...
                AbsTol=testCase.tolVal);
            testCase.verifyEqual(ky, kyExpected, ...
                AbsTol=testCase.tolVal);

            [kx, ky] = fftCoordinates(x, y, ApplyFftShift=true);
            testCase.verifyEqual(kx, fftshift(kxExpected), ...
                AbsTol=testCase.tolVal);
            testCase.verifyEqual(ky, fftshift(kyExpected), ...
                AbsTol=testCase.tolVal);

            [kx, ky] = fftCoordinates(x, y, PositiveOutput=true);
            testCase.verifyEqual(kx, fftshift(kxExpected + abs(min(kxExpected))), ...
                AbsTol=testCase.tolVal);
            testCase.verifyEqual(ky, fftshift(kyExpected + abs(min(kyExpected))), ...
                AbsTol=testCase.tolVal);

            [kx, ky] = fftCoordinates(x, y, ApplyFftShift=true, PositiveOutput=true);
            testCase.verifyEqual(kx, fftshift(fftshift(kxExpected + abs(min(kxExpected)))), ...
                AbsTol=testCase.tolVal);
            testCase.verifyEqual(ky, fftshift(fftshift(kyExpected + abs(min(kyExpected)))), ...
                AbsTol=testCase.tolVal);
        end

        %% Error Condition Tests
        function testError_moreOutputsThanInputs(testCase)
            x = 1:10;
            y = 1:5;

            [~, ~, ~] = testCase.verifyError(...
                @() fftCoordinates(x, y), ...
                "MATLAB:unassignedOutputs");
        end

        function testError_nonVectorInput(testCase)
            x = rand(10, 10);
            y = 1:5;

            [~, ~, ~] = testCase.verifyError(...
                @() fftCoordinates(x, y), ...
                "MATLAB:validation:IncompatibleSize");
        end

        function testError_nonFiniteInput(testCase)
            x = [1:10, inf];
            y = 1:5;

            [~, ~, ~] = testCase.verifyError(...
                @() fftCoordinates(x, y), ...
                "MATLAB:validators:mustBeFinite");
        end

        function testError_complexInput(testCase)
            x = [1:10, 11 + 1j];
            y = 1:5;

            [~, ~, ~] = testCase.verifyError(...
                @() fftCoordinates(x, y), ...
                "MATLAB:validators:mustBeReal");
        end

        %% Edge Case Tests
        function testEdge_singletonElement(testCase)
            x = 5;
            y = 1:4;
            [kx, ky] = fftCoordinates(x, y);

            testCase.verifyEqual(kx, 0);
            testCase.verifySize(ky, [1, numel(y)]);
        end

        function testEdge_singletonElementMultiple(testCase)
            x = 5;
            y = 6;
            [kx, ky] = fftCoordinates(x, y);

            testCase.verifyEqual(kx, 0);
            testCase.verifyEqual(ky, 0);
        end

        function testEdge_2elements(testCase)
            dx = 0.31;
            Nx = 2;
            x = dx * (1:Nx);

            kxExpected = pi * ifftshift(-(Nx-0):2:(Nx-2)).' ./ (Nx * dx);

            kx = fftCoordinates(x);
            testCase.verifyEqual(kx, kxExpected, ...
                AbsTol=testCase.tolVal);

            kx = fftCoordinates(x, ApplyFftShift=true);
            testCase.verifyEqual(kx, fftshift(kxExpected), ...
                AbsTol=testCase.tolVal);

            kx = fftCoordinates(x, PositiveOutput=true);
            testCase.verifyEqual(kx, fftshift(kxExpected + abs(min(kxExpected))), ...
                AbsTol=testCase.tolVal);

            kx = fftCoordinates(x, ApplyFftShift=true, PositiveOutput=true);
            testCase.verifyEqual(kx, fftshift(fftshift(kxExpected + abs(min(kxExpected)))), ...
                AbsTol=testCase.tolVal);
        end

        function testEdge_3elements(testCase)
            dx = 0.31;
            Nx = 3;
            x = dx * (1:Nx);

            kxExpected = pi * ifftshift(-(Nx-1):2:(Nx-1)).' ./ (Nx * dx);

            kx = fftCoordinates(x);
            testCase.verifyEqual(kx, kxExpected, ...
                AbsTol=testCase.tolVal);

            kx = fftCoordinates(x, ApplyFftShift=true);
            testCase.verifyEqual(kx, fftshift(kxExpected), ...
                AbsTol=testCase.tolVal);

            kx = fftCoordinates(x, PositiveOutput=true);
            testCase.verifyEqual(kx, fftshift(kxExpected + abs(min(kxExpected))), ...
                AbsTol=testCase.tolVal);

            kx = fftCoordinates(x, ApplyFftShift=true, PositiveOutput=true);
            testCase.verifyEqual(kx, fftshift(fftshift(kxExpected + abs(min(kxExpected)))), ...
                AbsTol=testCase.tolVal);
        end

        function testEdge_emptyInput(testCase)
            x = [];
            [k] = fftCoordinates(x);

            testCase.verifySize(k, [0, 1]);
        end

        function testEdge_emptyInputMultiArg(testCase)
            x = 5;
            y = [];
            z = [];
            w = 1:10;
            [kx, ky, kz, kw] = fftCoordinates(x, y, z, w);

            testCase.verifySize(kx, [numel(x), 1]);
            testCase.verifySize(ky, [1, 0]);
            testCase.verifySize(kz, [1, 1, 0]);
            testCase.verifySize(kw, [1, 1, 1, numel(w)]);
        end
    end
end