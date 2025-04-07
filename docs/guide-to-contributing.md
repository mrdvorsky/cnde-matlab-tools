# CNDE MATLAB Tools Contribution Guide

## 1. File Naming & Organization
### Function Files
- Name files as `lowerCamelCase.m` (e.g., `exampleFunction.m`)
- Store related functions in packages (`+packageName` folders)
- Place custom validation helpers at the end of files:
```matlab
%% Custom Validation (indent 4 spaces)
function mustBePositiveOddInteger(num)
    % Validation logic here
end
```

### Test Files
- Prefix with `tester_` (e.g., `tester_exampleFunction.m`)
- Mirror function structure with test methods:
```matlab
classdef tester_exampleFunction < matlab.unittest.TestCase
    methods (Test)
        function test_basicBehavior(testCase)
            % Test logic
        end
        function testError_invalidInput(testCase)
            % Error testing
        end
    end
end
```

---

## 2. Function Documentation
### Header Template
```matlab
function [out1, out2] = exampleFunction(stringIn, boolIn, optIn, options)
% Brief description of primary functionality.
%
% Examples:
%   [out1] = exampleFunction("test", true)
%   [out1, out2] = exampleFunction('a', false, 3, StringArray=["x"])
%   exampleFunction(0, true)  % Error example
%
% Inputs:
%   stringIn - (1×1 string) Description
%   boolIn   - (N×1 logical) Description
%   optIn (default=1) - (1×1 numeric) Optional input
%
% Outputs:
%   out1 - Description
%   out2 - Description
%
% Named Arguments:
%   PositiveOddInt - (Required) No default
%   StringArray ("") - Default value shown
%
% Author: Name (email)
% Last modified: YYYY-MM-DD
```

### Requirements
- Show **error-triggering examples** in comments
- Specify dimensions/type constraints (e.g., `N×1 logical`)
- Document defaults in parentheses

---

## 3. Unit Testing Standards
### Method Naming
| Prefix         | Purpose                          |
|----------------|----------------------------------|
| `test_`        | Normal functionality            |
| `testError_`   | Expected error conditions       | 
| `testWarning_` | Expected warnings               |
| `testEdge_`    | Boundary/empty/special cases    |

### Example Test
```matlab
function testEdge_minimalValue(testCase)
    [~, out2] = exampleFunction("x", true, PositiveOddInt=1);
    testCase.verifyEqual(out2, 1);
end

function testError_invalidType(testCase)
    testCase.verifyError(...
        @() exampleFunction(123, true), ... % Numeric instead of string
        "MATLAB:validation:IncompatibleSize");
end
```

### Verification Methods
- `verifyEqual` - Check output values
- `verifyError` - Confirm expected errors
- `verifyWarning` - Confirm warnings
- `verifyEmpty` - Check for empty outputs

---

## 4. Argument Validation
### Standard Pattern
```matlab
arguments
    % Required
    stringIn(1,1) string
    boolIn(:,1) logical
    
    % Optional (with defaults)
    optIn(1,1) {mustBeReal} = 1.0
    
    % Named arguments (Capitalized)
    options.PositiveOddInt(1,1) {mustBePositiveOddInteger}
    options.StringArray(:,:,:) string = ""
end
```

### Key Rules
1. Capitalize first letter of named arguments
2. Specify dimensions: `(1,1)`, `(:,:)`, etc.
3. Use `mustBe*` validators or custom functions
4. Always include defaults for optional arguments

---

## 5. Error Handling
### Custom Errors
```matlab
function mustBePositiveOddInteger(num)
    mustBeInteger(num);
    mustBePositive(num);
    if mod(num, 2) ~= 1
        throwAsCaller(MException("CNDE:mustBePositiveOddInteger",...
            "Value must be positive odd integer"));
    end
end
```
- Use project-specific error IDs (`CNDE:` prefix)
- Test all custom errors in unit tests

---

## 6. Code Style
### Formatting
- Indent with 4 spaces (no tabs)
- Align related arguments:
```matlab
% Good
arguments
    stringIn(1,1) string
    boolIn(:,1)   logical
    optIn(1,1)    {mustBeReal} = 1.0
end
```

### Naming
- Variables: `lowerCamelCase`
- Functions: `lowerCamelCase`
- Test Classes: `tester_FunctionName`
- Error IDs: `ProjectPrefix:description`

---

## 7. Pull Request Checklist
- [ ] All new functions have complete doc headers
- [ ] Unit tests cover:
  - Normal use cases
  - All error conditions
  - Edge cases
  - Default arguments
- [ ] Custom validation functions exist for complex checks
- [ ] Code follows naming conventions
- [ ] No linting warnings (`mlint` clean)

--- 

[MATLAB Unit Testing Docs](https://www.mathworks.com/help/matlab/matlab_prog/class-based-unit-tests.html)  
[Argument Validation Reference](https://www.mathworks.com/help/matlab/matlab_prog/function-argument-validation-1.html)
