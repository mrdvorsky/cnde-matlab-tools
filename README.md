# MATLAB CNDE Research Utilities

![GitLab](https://img.shields.io/badge/GitLab-%23181717.svg?style=flat&logo=gitlab&logoColor=white)
![MATLAB](https://img.shields.io/badge/MATLAB-R2023b%2B-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

A curated collection of MATLAB tools for accelerating research workflows in the CNDE laboratory.

---

## Table of Contents
- [Installation](#installation)
- [Features](#features)
- [Usage Examples](#usage-examples)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

---

## Installation
Open MATLAB and run the following commands (note that this requires git to be installed):
```matlab
cd(userpath());
gitclone("https://git.ece.iastate.edu/amntl/cnde-matlab-utils");
cd(fullfile("cnde-matlab-utils", "install"));
cndeMatlabUtils_install();
```

This will clone this git repository in the "userpath()" folder.

---

## Features

### Core Modules
| Category          | Key Functions                     | Description                                  |
|-------------------|-----------------------------------|----------------------------------------------|
| **Data I/O**      | `importSdt`, `importScan`         | Handle lab-specific file formats             |

---

## Usage Examples

### Import SDT Data File
```matlab
% Load data with metadata
[data, x, y, t, header] = importSdt('experiment.sdt');

% Plot time trace from first pixel
figure;
plot(t{1}, squeeze(data{1}(1,1,:)));
xlabel('Time (ns)');
ylabel('Amplitude (V)');
```

---

## Contributing

To add new utilities:
1. **Fork** or **clone** the repository.
2. Create a feature branch:
   ```bash
   git checkout -b feat/your-feature-name
   ```
3. Follow coding standards:
   - Include documentation headers in functions:
     ```matlab
     function output = exampleFunc(input)
     % EXAMPLEFUNC Brief description
     %   Detailed explanation
     %   Input:  input  - Description
     %   Output: output - Description
     ```
   - Add tests to the `/tests` directory.
4. Submit a merge request with a clear description.

---

## License
Distributed under the MIT License. See [LICENSE](LICENSE) for details.

---

## Contact
- **Maintainer**: Matt Dvorsky – [mdvorsky@iastate.edu](mailto:mdvorsky@iastate.edu)

---

## Troubleshooting
- **"Function not found"**: Verify MATLAB path configuration.
- **SDT import errors**: Check file format compatibility in `importSdt.m`.
- **Missing toolboxes**: Install required toolboxes via MATLAB Add-On Explorer.

Report issues [here](https://git.ece.iastate.edu/amntl/matlab/-/issues).