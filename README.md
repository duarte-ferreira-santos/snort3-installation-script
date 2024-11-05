# Snort3 Full Installation and Configuration Script

## Introduction

Welcome to the **Snort3 Full Installation and Configuration Script** repository! This project provides an automated installation script for Snort3, a powerful open-source Intrusion Detection System (IDS) designed to enhance your network security. By automating the setup process, this script simplifies the installation of Snort3, allowing you to effectively monitor and protect your network from potential intrusions and threats.

## Features

- **Automated Installation**: Installs all prerequisites and Snort3 components.
- **Configuration Options**: Provides options for editing configuration files, testing, and managing Snort3.
- **Interactive Menu**: A user-friendly command-line interface for managing the installation and configuration.

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

Main Menu:

- **Install Pre-requisites**: Installs necessary packages for Snort3.
- **Install PCRE**: Installs the Perl Compatible Regular Expressions library.
- **Install gperftools**: Installs Google Performance Tools for performance profiling.
- **Install Ragel**: Installs Ragel for generating finite state machines.
- **Download Boost**: Downloads Boost C++ libraries.
- **Install Boost (optional)**: Optionally installs Boost libraries.
- **Install Safeclib**: Installs Safeclib for enhanced security.
- **Install Hyperscan**: Installs Intel's Hyperscan for high-performance regex matching.
- **Install Flatbuffers**: Installs Flatbuffers for efficient serialization.
- **Install Data Acquisition (DAQ)**: Installs the Snort DAQ for packet capture.
- **Update Shared Libraries**: Updates shared libraries after installations.
- **Create ethtool.service**: Creates a service for managing network interfaces.
- **Install Snort 3**: Installs the Snort 3 IDS.
- **Enabling Built-in Rules and Testing Snort**: Configures and tests built-in rules.
- **Configure Snort User, Group, Permissions**: Sets up the necessary user and permissions.
- **Create snort3.service Systemd Service**: Configures Snort as a systemd service.
- **Install and configure PulledPork 3**: Installs PulledPork for rules management.
- **Setup PulledPork Auto-Update Timer**: Configures auto-update for PulledPork.
- **Install Snort 3 OpenAppID/ODP and Extras**: Installs additional Snort features.
- **Enable Snort3 Features**: Activates features like Hyperscan and Blocklist.
- **Install Vectorscan**: Alternative to Hyperscan for regex matching.
- **Uninstall Snort 3**: Removes Snort 3 from the system.
- **Update snort3_systemd with PID**: Updates systemd service with process ID.
- **Tests and Edits**: Accesses additional testing and configuration options.
- **Exit**: Exits the script.

Tests and Edits Menu:

- **Edit snort.lua**: Modify the main Snort configuration file.
- **Test snort.lua**: Run tests to validate the configuration.
- **Edit PulledPork config**: Modify the configuration file for PulledPork.
- **Edit local.rules**: Edit custom rules for Snort.
- **Run PulledPork**: Execute PulledPork to update rules.
- **Edit Snort service file**: Modify the Snort systemd service file.
- **Reload and test Snort service**: Restart and validate the Snort service.
- **Edit custom.lua**: Edit the custom configuration for Snort.
- **Return to main menu**: Go back to the main menu.

After running the script options Snort3 will be installed and fully configured, you can start using it to monitor your network for suspicious activity. For further configuration edit the /etc/snort/snort.lua. Make sure to adjust the settings to fit your network environment.

## Prerequisites

Linux Distribution: Ubuntu 20.04 or later.
Git: Required for cloning the repository.
Networking Knowledge: Basic understanding of network security concepts is recommended.

## Contributing

Contributions are welcome! If you'd like to contribute to this project, please fork the repository and submit a pull request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For any inquiries, please reach out via email: duarte.ferreira.santos@proton.me
