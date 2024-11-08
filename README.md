# Snort3 Full Installation and Configuration Script

## Introduction

Welcome to the **Snort3 Full Installation and Configuration Script** repository! This project provides an automated installation script for Snort3, a powerful open-source Intrusion Detection System (IDS) designed to enhance your network security. By automating the setup process, this script simplifies the installation of Snort3, allowing you to effectively monitor and protect your network from potential intrusions and threats.

## Key Features

- **Automated Dependency Installation**: Installs all required libraries in tested versions for a successful Snort3 build.
- **Comprehensive Configuration Options**: Allows modification of configuration files, testing, and managing Snort3 interactively.
- **Interactive CLI Menu**: Offers a user-friendly command-line interface to simplify installation and configuration.

## Table of Contents

- [Dependencies and Snort Version](#dependencies-and-snort-version)
- [Installation](#installation)
- [Usage](#usage)
- [Prerequisites](#prerequisites)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## Dependencies and Snort Version

The script installs the following dependencies, ensuring compatibility with **Snort3 version 3.3.0.0** for optimal installation and operation:

| Dependency     | Version  |
|----------------|----------|
| Boost          | 1.85.0   |
| PCRE           | 8.45     |
| Gperftools     | 2.15     |
| Ragel          | 6.10     |
| Hyperscan      | 5.4.2    |
| Flatbuffers    | 2.0.0    |
| DAQ            | 3.0.15   |
| Safeclib       | 3.8.1    |

These versions have been thoroughly tested to work together, eliminating compatibility issues in the build environment.

**Feature options for default installation**:
    DAQ Modules:    Static (afpacket;bpf;dump;fst;gwlb;nfq;pcap;savefile;trace)

    libatomic:      System-provided

    Hyperscan:      ON

    ICONV:          ON

    Libunwind:      ON

    LZMA:           ON

    RPC DB:         Built-in

    SafeC:          OFF

    TCMalloc:       ON

    JEMalloc:       OFF

    UUID:           ON

    NUMA:           ON

    LibML:          OFF


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

Once the script starts, the main menu displays various options for installation and configuration. For a complete installation, you can simply follow the menu options in numerical order, ensuring each component is set up in sequence.

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
- **Enabling Built-in Rules and Testing Snort**: Enables built-in rules in snort.lua, and tests the Snort setup to ensure proper functionality.
- **Configure Snort User, Group, Permissions**: Sets up the Snort user and group, establishes permissions for log directories, and ensures the appropriate security measures are in place.
- **Create snort3.service Systemd Service**: Configures Snort as a systemd service for automatic management and enables it to run on a specified network interface.
- **Install and configure PulledPork 3**: Automates the installation and configuration of PulledPork 3 for managing Snort rules, setting up necessary directories and permissions.
- **Setup PulledPork Auto-Update Timer**: Configures automatic updates for PulledPork to ensure the latest Snort rules are regularly applied, enhancing system security.
- **Install Snort 3 OpenAppID/ODP and Extras**: Installs additional Snort features, including OpenAppID and other enhancements for improved detection capabilities.
- **Enable Snort3 Features**: Backs up the snort.lua configuration, updates the HOME_NET variable, and ensures the inclusion of custom settings for enhanced monitoring capabilities.
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
