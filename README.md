# CNDE MATLAB Research Tools

![version](https://img.shields.io/badge/version-1.0.0-blue)
![MATLAB](https://img.shields.io/badge/MATLAB-R2023b%2B-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

A curated collection of MATLAB tools for accelerating research workflows in the CNDE laboratory.

---

## Table of Contents
- [Installation](#installation)
- [License](#license)
- [Contact](#contact)

---

## Installation
Open MATLAB and run the following commands in the command window (note that this requires git to be installed on your system):
```matlab
cd(userpath());
gitclone("https://github.com/mrdvorsky/cnde-matlab-tools.git");
cd(fullfile("cnde-matlab-tools", "install"));
cndeMatlabTools_install();
```

This will clone this git repository in the "userpath()" folder.

---

## License
Distributed under the MIT License. See [LICENSE](LICENSE) for details.

---

## Contact
- **Maintainer**: Matt Dvorsky – [mdvorsky@iastate.edu](mailto:mdvorsky@iastate.edu)
