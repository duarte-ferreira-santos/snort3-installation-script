# Snort3 Full Installation and Configuration Script

## Introduction

Welcome to the **Snort3 Full Installation and Configuration Script** repository! This project is designed to provide a comprehensive, easy-to-use script that simplifies the installation and configuration of **Snort3**, the next-generation network intrusion detection and prevention system (NIDS/NIPS). 

## Features

- **Automated Installation**: Installs Snort3 and all necessary dependencies seamlessly.
- **Configuration Options**: Configures Snort3 for various use cases, ensuring flexibility and adaptability.
- **Comprehensive Documentation**: Detailed instructions on how to use the script and customize configurations.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Prerequisites](#prerequisites)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## Installation

To install and configure Snort3 using this script, follow these simple steps:

1. Clone the repository:
   git clone https://github.com/duarte-ferreira-santos/snort3-installation-script.git
   cd snort3-installation-script

2. Run the installation script:

    chmod +x install_snort3.sh
    ./install_snort3.sh

    Follow the on-screen instructions to complete the installation.

## Usage

Once the script is running, you will be presented with the following options in the main menu:

    Install Pre-requisites
    Install PCRE
    Install gperftools
    Install Ragel
    Download Boost
    Install Boost (optional)
    Install Safeclib
    Install Hyperscan
    Install Flatbuffers
    Install Data Acquisition (DAQ)
    Update Shared Libraries
    Create ethtool.service
    Install Snort 3
    Enabling Built-in Rules and Testing Snort
    Configure Snort User, Group, Permissions
    Create snort3.service Systemd Service
    Install and configure PulledPork 3
    Setup PulledPork Auto-Update Timer
    Install Snort 3 OpenAppID/ODP and Extras
    Enable Snort3 Features (Hyperscan, Blocklist, json, SO_rules)
    Install Vectorscan (alternative to Hyperscan)
    Uninstall Snort 3
    Update snort3_systemd with PID
    Tests and Edits
    Exit

Tests and Edits Menu

The script also includes a "Tests and Edits" menu with the following options:

    Edit snort.lua
    Test snort.lua
    Edit PulledPork config
    Edit local.rules
    Run PulledPork
    Edit Snort service file
    Reload and test Snort service
    Edit custom.lua
    Return to main menu

After running the script options Snort3 will be installed and fully configured, you can start using it to monitor your network for suspicious activity. For further configuration edit the /etc/snort/snort.lua. Make sure to adjust the settings to fit your network environment.

## Prerequisites

    A supported Linux distribution (e.g., Ubuntu, CentOS)
    Root or sudo access
    Basic knowledge of network security concepts

## Contributing

Contributions are welcome! If you'd like to contribute to this project, please fork the repository and submit a pull request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For any inquiries, please reach out via email: duarte.ferreira.santos@proton.me
