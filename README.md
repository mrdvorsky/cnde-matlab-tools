# MATLAB Research Utilities 🧬🔧

![GitLab](https://img.shields.io/badge/GitLab-%23181717.svg?style=flat&logo=gitlab&logoColor=white)
![MATLAB](https://img.shields.io/badge/MATLAB-R2023b%2B-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

A curated collection of MATLAB tools for accelerating research workflows in the [Your Lab Name] laboratory. 

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

### 1. Clone the Repository
```bash
git clone https://gitlab.com/your-lab-name/matlab-utilities.git
```

### 2. Add to MATLAB Path
In MATLAB:
```matlab
addpath(genpath('/path/to/matlab-utilities'));
savepath; % Optional: Save path for future sessions
```

### 3. Verify Dependencies
Ensure required toolboxes are installed:
```matlab
ver  % Check for:
%   - Signal Processing Toolbox
%   - Instrument Control Toolbox
%   - Statistics and Machine Learning Toolbox
```

---

## Features

### Core Modules
| Category          | Key Functions                     | Description                                  |
|-------------------|-----------------------------------|----------------------------------------------|
| **Data I/O**      | `importSdt`, `exportToCSV`        | Handle lab-specific file formats             |
| **Visualization** | `plot_spectra`, `createHeatmap`   | Publication-ready figures                    |
| **Analysis**      | `normalizeData`, `batchFFT`       | Signal processing and statistics             |
| **Instrument**    | `oscilloscopeControl`             | Interface with lab hardware                  |

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

### Batch Process Folder of CSVs
```matlab
results = batch_process_data(...
    'InputDir', 'raw_data/', ...
    'Function', @(x) normalizeData(x, 'method', 'zscore'), ...
    'OutputDir', 'processed/');
```

---

## Contributing

To add new utilities:
1. **Fork** the repository.
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
Distributed under the MIT License. See [LICENSE.md](LICENSE.md) for details.

---

## Contact
- **Lab Lead**: Dr. Jane Doe – [jane.doe@lab.edu](mailto:jane.doe@lab.edu)
- **Maintainer**: John Smith – [john.smith@lab.edu](mailto:john.smith@lab.edu)
- **Lab Website**: [https://lab.edu](https://lab.edu)

---

## Troubleshooting
- **"Function not found"**: Verify MATLAB path configuration.
- **SDT import errors**: Check file format compatibility in `importSdt.m`.
- **Missing toolboxes**: Install required toolboxes via MATLAB Add-On Explorer.

Report issues [here](https://gitlab.com/your-lab-name/matlab-utilities/-/issues).