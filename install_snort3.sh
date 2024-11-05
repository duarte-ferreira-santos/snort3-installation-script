!/bin/bash

# Base directory for downloads and installations
BASE_DIR="/opt/snort"
BOOST_VERSION="1.85.0"
PCRE_VERSION="8.45"
GPERFTOOLS_VERSION="2.15"
RAGEL_VERSION="6.10"
HYPERSCAN_VERSION="5.4.2"
FLATBUFFERS_VERSION="2.0.0"
DAQ_VERSION="3.0.15"
SNORT_VERSION="3.3.0.0"
SAFECLIB_VERSION="3.8.1"

pause_and_return() {
    read -rp "Press Enter to return to the main menu..."
    main_menu
}

check_command() {
    if [ $? -ne 0 ]; then
        echo "An error occurred. Exiting."
        exit 1
    fi
}

clean_previous_installation() {
    local dir=$1
    if [ -d "$dir" ]; then
        sudo rm -rf "$dir"
    fi
}

install_prereqs() {
    echo "Installing pre-requisites..."
    sudo apt-get update
    sudo apt-get install -y build-essential autotools-dev libdumbnet-dev \
        libluajit-5.1-dev libpcap-dev zlib1g-dev pkg-config libhwloc-dev \
        cmake liblzma-dev openssl libssl-dev cpputest libsqlite3-dev uuid-dev \
        libcmocka-dev libnetfilter-queue-dev libmnl-dev ethtool libbz2-dev libreadline-dev git flex python3-pip libunwind-dev doxygen jq python3.10-venv
    sudo dpkg-reconfigure tzdata
    check_command
    echo "Pre-requisites installed successfully."
    mkdir /opt/snort
    pause_and_return
}

# Function to install PCRE
install_pcre() {
    echo "Installing PCRE..."
    clean_previous_installation "$BASE_DIR/pcre*"
    cd "$BASE_DIR" || exit
    wget https://sourceforge.net/projects/pcre/files/pcre/8.45/pcre-8.45.tar.gz -O pcre-8.45.tar.gz
    tar -xzvf pcre-$PCRE_VERSION.tar.gz
    pcre_dir=$(ls -d pcre*/)
    cd "$pcre_dir" || exit
    ./configure --prefix=/usr \
                --docdir=/usr/share/doc/$pcre_dir \
                --enable-unicode-properties \
                --enable-pcre16 \
                --enable-pcre32 \
                --enable-pcregrep-libz \
                --enable-pcregrep-libbz2 \
                --enable-pcretest-libreadline \
                --disable-static
    make -j$(nproc)
    sudo make install
    cd ..
    echo "PCRE installed successfully."
    pause_and_return
}

# Function to install gperftools
install_gperftools() {
    echo "Installing gperftools..."
    clean_previous_installation "$BASE_DIR/gperftools-*"
    cd "$BASE_DIR" || exit
    wget https://github.com/gperftools/gperftools/releases/download/gperftools-2.15/gperftools-2.15.tar.gz -O gperftools-$GPERFTOOLS_VERSION.tar.gz
    tar -xzvf gperftools-*.tar.gz
    gperf_dir=$(ls -d gperftools-*/)
    cd "$gperf_dir" || exit
    ./autogen.sh
    ./configure
    make -j$(nproc)
    sudo make install
    cd ..
    echo "gperftools installed successfully."
    pause_and_return
}

# Function to install Ragel
install_ragel() {
    echo "Installing Ragel..."
    clean_previous_installation "$BASE_DIR/ragel-*"
    cd "$BASE_DIR" || exit
    wget http://www.colm.net/files/ragel/ragel-$RAGEL_VERSION.tar.gz
    tar -xzvf ragel-*.tar.gz
    ragel_dir=$(ls -d ragel*/)
    cd "$ragel_dir" || exit
    ./configure
    make -j$(nproc)
    sudo make install
    ragel -v
    pause_and_return
}


# Function to download Boost and set BOOST_ROOT
download_boost() {
    echo "Installing Ragel..."
    clean_previous_installation "$BASE_DIR/boost*"
    cd "$BASE_DIR" || exit
    wget https://archives.boost.org/release/1.85.0/source/boost_1_85_0.tar.gz -O boost_1_85_0.tar.gz
    tar -xzvf boost_1_85_0.tar.gz

  # Return to base directory
  cd "$BASE_DIR" || exit

  # Pause and return
  pause_and_return
}



# Function to install Boost
install_boost() {
    echo "Installing Boost..."
    cd "$BASE_DIR" || exit
    boost_dir=$(ls -d boost_*/)
    cd "$boost_dir" || exit
    ./bootstrap.sh
    ./b2
    sudo ./b2 install
    cd ..
    echo "Boost installed successfully."
    pause_and_return
}

# Function to install Safeclib
install_safeclib() {
    echo "Installing Safeclib..."
    clean_previous_installation "$BASE_DIR/safe*"
    cd "$BASE_DIR" || exit

    # Download Safeclib
    wget https://github.com/rurban/safeclib/releases/download/v$SAFECLIB_VERSION/safeclib-$SAFECLIB_VERSION.tar.gz

    # Extract and install Safeclib
    tar -xzvf safe*.tar.gz
    safelib_dir=$(ls -d safe*/)
    cd "$safelib_dir"
    ./configure
    make -j$(nproc)
    sudo make install
    cd ..
    echo "Safeclib installed successfully."
    pause_and_return
}


install_hyperscan() {
    echo "Installing Hyperscan..."
    clean_previous_installation "$BASE_DIR/hyperscan*"
    cd "$BASE_DIR" || exit
    rm -rd hyper*
    wget https://github.com/intel/hyperscan/archive/refs/tags/v$HYPERSCAN_VERSION.tar.gz -O hyperscan-$HYPERSCAN_VERSION.tar.gz
    tar -xzvf hyperscan-$HYPERSCAN_VERSION.tar.gz
    hyperscan_dir=$(ls -d hyperscan*/)
    cd "$hyperscan_dir" || exit

    # Clean previous build directory
    rm -rf /opt/snort/hyperscan-5.4.2-build
    mkdir /opt/snort/hyperscan-5.4.2-build
    cd /opt/snort/hyperscan-5.4.2-build 

    # Set environment variables for PCRE
    #export PKG_CONFIG_PATH=/usr/lib/pkgconfig:$PKG_CONFIG_PATH
    #export LD_LIBRARY_PATH=/usr/lib:$LD_LIBRARY_PATH
    #export C_INCLUDE_PATH=/usr/include:$C_INCLUDE_PATH
    #export CPLUS_INCLUDE_PATH=/usr/include:$CPLUS_INCLUDE_PATH

    # Run CMake from the build directory with explicit PCRE paths
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DBOOST_ROOT=/opt/snort/boost_1_85_0 ../hyperscan-5.4.2
    
    #uncomment this to force include PCRE paths
    #cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DBOOST_ROOT=/opt/snort/boost_1_85_0-DPCRE_LIBRARIES=/usr/lib/libpcre.so -DPCRE_INCLUDE_DIRS=/usr/include ../hyperscan-5.4.2
    # Compile and install, log errors
    make
    sudo make install
    # Update library cache
    sudo ldconfig

    pause_and_return
}


# Function to install Flatbuffers
install_flatbuffers() {
    echo "Installing Flatbuffers..."
    clean_previous_installation "$BASE_DIR/flatbuffers-*"
    cd "$BASE_DIR" || exit
    wget https://github.com/google/flatbuffers/archive/refs/tags/v$FLATBUFFERS_VERSION.tar.gz -O flatbuffers-v$FLATBUFFERS_VERSION.tar.gz
    tar -xzvf flatbuffers-v$FLATBUFFERS_VERSION.tar.gz
    flatbuffers_dir=$(ls -d flatbuffers-*/)
    cd "$flatbuffers_dir" || exit
    cmake -G "Unix Makefiles"
    make -j$(nproc)
    sudo make install
    cd ..
    echo "Flatbuffers installed successfully."
    pause_and_return
}

# Function to install Data Acquisition (DAQ) from Snort
install_daq() {
    echo "Installing DAQ..."
    clean_previous_installation "$BASE_DIR/libdaq-*"
    cd "$BASE_DIR" || exit
    wget https://github.com/snort3/libdaq/archive/refs/tags/v$DAQ_VERSION.tar.gz -O libdaq-$DAQ_VERSION.tar.gz
    tar -xzvf libdaq-$DAQ_VERSION.tar.gz
    libdaq_dir=$(ls -d libdaq*/)
    cd "$libdaq_dir" || exit
    ./bootstrap
    ./configure
    make -j$(nproc)
    sudo make install
    ldconfig -p | grep libdaq
    pause_and_return
}

update_shared_libraries() {
    echo "Updating shared libraries..."
    sudo ldconfig
    check_command
    echo "Shared libraries updated successfully."
    pause_and_return
}


# Function to create ethtool service
create_ethtool_service() {
    echo "Creating ethtool.service."
    echo "Please enter your network interface (e.g., ens3)."
    # List available network interfaces (excluding loopback)
    echo "Available network interfaces:"
    ip --brief a | egrep -v "lo"
    # Prompt user to select the interface for sniffing
    read -rp "Network Interface: " network_interface

    # Define the file path for the systemd service file
    SERVICE_FILE_PATH="/lib/systemd/system/ethtool.service"

    # Create the content for the service file
    SERVICE_FILE_CONTENT=$(cat <<EOF
[Unit]
Description=Ethtool config nic card offloading

After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/sbin/ethtool -K $network_interface gro off
ExecStart=/sbin/ethtool -K $network_interface lro off

[Install]
WantedBy=multi-user.target
EOF
)

    # Create and write to the systemd service file
    echo "$SERVICE_FILE_CONTENT" | sudo tee "$SERVICE_FILE_PATH" > /dev/null

    # Set appropriate permissions for the service file
    sudo chmod 644 "$SERVICE_FILE_PATH"

    # Reload the systemd daemon to apply changes
    sudo systemctl daemon-reload

    # Enable the service to start on boot
    sudo systemctl enable ethtool.service
    sudo systemctl start ethtool.service
    sudo systemctl status ethtool.service
    sudo ethtool -k $network_interface | grep receive-offload
    echo "Service file created, reloaded, and enabled successfully."

    pause_and_return
}


#Function to Fully install Snort3
install_snort3() {
    echo "Installing Snort3..."
    clean_previous_installation "$BASE_DIR/snort*"
    cd "$BASE_DIR"
    rm -rd snort*
    wget https://github.com/snort3/snort3/archive/refs/tags/$SNORT_VERSION.tar.gz
    tar -xzvf $SNORT_VERSION.tar.gz
    snort_dir=$(ls -d snort3*/)
    cd "$snort_dir" || exit
    ./configure_cmake.sh --prefix=/usr/local --enable-tcmalloc
    cd build || exit
    make -j$(nproc)
    sudo make install
    cd ..
    echo "Removing any local rules file from previous installations"
    rm /usr/local/etc/rules/local.rules &>/dev/null

    echo "Creating Snort3 configuration directories and files..."
    sudo mkdir -p /usr/local/etc/rules
    sudo mkdir -p /usr/local/etc/so_rules/
    sudo mkdir -p /usr/local/etc/lists/
    sudo touch /usr/local/etc/rules/local.rules
    sudo touch /usr/local/etc/lists/default.blocklist
    sudo mkdir -p /var/log/snort
    cd /var/log/snort
    sudo touch appid-output.log
    sudo touch appid_stats.log
    sudo touch snort.pid
    sudo touch alert_json.txt

    
    echo "Saving backup of snort.lua configuration as snort.lua.old"
    cp /usr/local/etc/snort/snort.lua /usr/local/etc/snort/snort.lua.old

    echo "Adding a test rule to local.rules..."
    echo 'alert icmp any any -> any any ( msg:"ICMP Traffic Detected"; sid:10000001; metadata:policy security-ips alert; )' | sudo tee /usr/local/etc/rules/local.rules > /dev/null

    echo "Testing Snort configuration..."
    snort -c /usr/local/etc/snort/snort.lua -R /usr/local/etc/rules/local.rules
    echo "If you see 'Snort successfully validated the configuration' with no warnings or errors, proceed to the next step."

    echo "Instructions:"
    echo "1. Run Snort in detection mode on an interface (default used is ens3, replace if needed):"
    echo "   sudo snort -c /usr/local/etc/snort/snort.lua -R /usr/local/etc/rules/local.rules -i ens3 -A alert_fast -s 65535 -k none"
    echo "2. Open a new terminal window and ping an external IP address or the interface's IP address:"
    echo "   ping <IP_ADDRESS>"
    echo "3. Verify that Snort is printing ICMP alerts to the console."
    echo "4. Press Ctrl+C to stop Snort after verifying the alerts."
    echo "5. Re-run the script and execute the next function: enabling_builtin_rules_and_testing_snort"

    pause_and_return
}

# Function to enable built-in rules and test Snort
enabling_builtin_rules_and_testing_snort() {
    echo "Loading backup of snort.lua configuration from /usr/local/etc/snort/snort.lua/snort.lua.old"
    cp /usr/local/etc/snort/snort.lua.old /usr/local/etc/snort/snort.lua

    echo "Testing Snort with the default configuration file"
    snort -c /usr/local/etc/snort/snort.lua

    echo "Enabling built-in rules in snort.lua..."

    # Uncomment the enable_builtin_rules line
    sudo sed -i 's|--enable_builtin_rules = true,|enable_builtin_rules = true,|' /usr/local/etc/snort/snort.lua

    # Append the include line immediately after enable_builtin_rules if it doesn't already exist
    sudo sed -i '/enable_builtin_rules = true,/!b;n;/include = RULE_PATH .. "\/local.rules",/!i\    include = RULE_PATH .. "/local.rules",' /usr/local/etc/snort/snort.lua

    echo "Testing the updated Snort configuration..."
    snort -c /usr/local/etc/snort/snort.lua
    if [ $? -eq 0 ]; then
        echo "Snort successfully validated the configuration with no warnings or errors."
    else
        echo "Error in Snort configuration. Please check the snort.lua file for issues."
        pause_and_return
        return
    fi

    echo "Instructions:"
    echo "1. Run Snort in detection mode on an interface (default used is ens3, replace if needed):"
    echo "   sudo snort -c /usr/local/etc/snort/snort.lua -i ens3 -A alert_fast -s 65535 -k none"
    echo "2. Open a new terminal window and ping an external IP address or the interface's IP address:"
    echo "   ping <IP_ADDRESS>"
    echo "3. Verify that Snort is printing ICMP alerts to the console."
    echo "4. Press Ctrl+C to stop Snort after verifying the alerts."
    echo "Snort3 configuration and testing completed successfully."

    pause_and_return
}

# Function to check if Snort is running
check_snort_running() {
    local pid_file="$1"
    if [ -f "$pid_file" ]; then
        local pid
        pid=$(cat "$pid_file")
        if ps -p "$pid" > /dev/null; then
            echo "Snort is running (PID: $pid)."
            return 0
        else
            echo "Snort is not running, PID file is stale."
            return 1
        fi
    else
        echo "PID file not found."
        return 1
    fi
}

# Function to configure Snort user, group, and permissions
configure_snort_user_and_permissions() {
    echo "Configuring Snort user, group, and permissions..."

    # Create snort group if it doesn't exist
    if ! getent group snort >/dev/null; then
        sudo groupadd snort
        echo "Snort group created."
    else
        echo "Snort group already exists."
    fi

    # Create snort user with no login shell and assign to snort group
    if ! getent passwd snort >/dev/null; then
        sudo useradd -r -s /sbin/nologin -g snort snort
        echo "Snort user created."
    else
        echo "Snort user already exists."
    fi

    # Set permissions for /var/log/snort
    sudo rm -rf /var/log/snort/*
    sudo mkdir -p /var/log/snort
    sudo chmod -R 5775 /var/log/snort
    sudo chown -R snort:snort /var/log/snort
    cd /var/log/snort
    sudo chown snort:snort appid_stats.log snort.pid appid-output.log alert_json.txt
    sudo chmod 775 appid_stats.log snort.pid appid-output.log alert_json.txt
    sudo chmod +t appid_stats.log snort.pid appid-output.log alert_json.txt

    echo "Permissions set for /var/log/snort directory."

    # Verify permissions
    echo "Verify the permissions of /var/log/snort:"
    ls -ld /var/log/snort
    echo ""
    echo "Please verify the permissions and ownership of /var/log/snort."
    pause_and_return
}

# Function to create the snort3.service systemd service
create_snort_systemd_service() {
    echo "Creating snort3.service systemd service..."

    # Backup original service file if it exists
    [ -f /lib/systemd/system/snort3.service ] && sudo cp /lib/systemd/system/snort3.service /lib/systemd/system/snort3.service.bak

    # List available network interfaces (excluding loopback)
    echo "Available network interfaces:"
    ip --brief a | egrep -v "lo"

    # Prompt user to select the interface for sniffing
    read -rp "Enter the name of the interface used for sniffing traffic: " interface_name

    # Create the systemD service file
    cat << EOF | sudo tee /lib/systemd/system/snort3.service > /dev/null
[Unit]
Description=Snort Daemon
After=syslog.target network.target

[Service]
Type=simple
ProtectHome=true
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true
ExecStart=/usr/local/bin/snort -c /usr/local/etc/snort/snort.lua -s 65535 -k none -l /var/log/snort -D -u snort -g snort -i $interface_name -m 0x1b --create-pidfile --plugin-path=/usr/local/etc/so_rules/
PIDFile=/var/log/snort/snort.pid

[Install]
WantedBy=multi-user.target
EOF

    echo "snort3.service file created:"
    cat /lib/systemd/system/snort3.service
    echo ""
    echo "Please verify that the snort3.service is correctly configured with your interface"
    echo "Press Enter to continue after verifying."
    read -r

    # Reload systemd daemon and enable/start snort3.service
    sudo systemctl daemon-reload
    sudo systemctl enable snort3.service
    sudo systemctl start snort3.service

    echo "snort3.service created, enabled, and started."

    # Verify service status
    echo "Verifying the status of snort3.service..."
    sudo systemctl status snort3.service
    echo ""

    # Save the PID number of the Snort service
    snort_pid=$(cat /var/log/snort/snort.pid)
    echo "Snort PID: $snort_pid"

    # Additional checks
    echo "Checking if Snort is running..."
    ps -ef | grep snort
    echo ""
    pause_and_return
}



install_pulledpork() {
    echo "Installing PulledPork 3..."

    # Define directories and paths
    PULLEDPORK_REPO="https://github.com/shirkdog/pulledpork3.git"
    PULLEDPORK_BASE_DIR="/usr/local/pulledpork3"
    CONFIG_DIR="$PULLEDPORK_BASE_DIR/etc"
    RULES_DIR="/usr/local/etc/rules"
    BLOCKLIST_DIR="/usr/local/etc/lists"
    SO_RULES_DIR="/usr/local/etc/so_rules"
    LOG_DIR="/var/log/snort"
    SNORT_PID_FILE="$LOG_DIR/snort.pid"
    SNORT_LUA_FILE="/usr/local/etc/snort/snort.lua"
    BACKUP_LUA_FILE="/usr/local/etc/snort/snort.lua.before-pulledpork"
    PULLEDPORK_CONF_FILE="$CONFIG_DIR/pulledpork.conf"
    PULLEDPORK_CONF_BACKUP="$CONFIG_DIR/pulledpork.conf.bak"

    # Clean previous installation if it exists
    if [ -d "$PULLEDPORK_BASE_DIR" ]; then
        echo "Cleaning previous PulledPork 3 installation..."
        sudo rm -rf "$PULLEDPORK_BASE_DIR"
    fi

    # Clone the PulledPork repository
    echo "Cloning PulledPork repository..."
    if ! git clone "$PULLEDPORK_REPO" "$PULLEDPORK_BASE_DIR"; then
        echo "Failed to clone repository."
        exit 1
    fi

    # Set up PulledPork directory structure
    echo "Setting up PulledPork directory structure..."
    sudo mkdir -p "$CONFIG_DIR" "$RULES_DIR" "$BLOCKLIST_DIR" "$SO_RULES_DIR" "$LOG_DIR"

    # Copy necessary files
    echo "Copying PulledPork files..."
    sudo cp -r "$PULLEDPORK_BASE_DIR/etc/"* "$CONFIG_DIR/"
    sudo cp "$PULLEDPORK_BASE_DIR/pulledpork.py" "$PULLEDPORK_BASE_DIR/"
    sudo cp -r "$PULLEDPORK_BASE_DIR/lib" "$PULLEDPORK_BASE_DIR/"

    # Ensure correct file permissions
    sudo chmod +x "$PULLEDPORK_BASE_DIR/pulledpork.py"

    # Create necessary files
    echo "Creating necessary files..."
    sudo touch "$RULES_DIR/snort.rules"
    sudo touch "$RULES_DIR/local.rules"
    sudo touch "$BLOCKLIST_DIR/default.blocklist"

    # Backup the original PulledPork configuration file
    if [ -f "$PULLEDPORK_CONF_FILE" ]; then
        echo "Backing up the original PulledPork configuration file..."
        sudo cp "$PULLEDPORK_CONF_FILE" "$PULLEDPORK_CONF_BACKUP"
    fi

    # Update PulledPork configuration file
    echo "Updating PulledPork configuration file..."
    sudo sed -i "s|^community_ruleset = .*|community_ruleset = false|g" "$PULLEDPORK_CONF_FILE"
    sudo sed -i "s|^registered_ruleset = .*|registered_ruleset = false|g" "$PULLEDPORK_CONF_FILE"
    sudo sed -i "s|^LightSPD_ruleset = .*|LightSPD_ruleset = true|g" "$PULLEDPORK_CONF_FILE"
    sudo sed -i "s|^oinkcode = .*|oinkcode = 2d772a4ad957e65feaac2b888a9396bf4c8ebf7c|g" "$PULLEDPORK_CONF_FILE"
    sudo sed -i "s|^snort_blocklist = .*|snort_blocklist = true|g" "$PULLEDPORK_CONF_FILE"
    sudo sed -i "s|^et_blocklist = .*|et_blocklist = true|g" "$PULLEDPORK_CONF_FILE"
    sudo sed -i "s|^blocklist_path = .*|blocklist_path = $BLOCKLIST_DIR/default.blocklist|g" "$PULLEDPORK_CONF_FILE"
    sudo sed -i "s|^rule_path = .*|rule_path = $RULES_DIR/snort.rules|g" "$PULLEDPORK_CONF_FILE"
    sudo sed -i "s|^local_rules = .*|local_rules = $RULES_DIR/local.rules|g" "$PULLEDPORK_CONF_FILE"
    sudo sed -i "s|^ignored_files = .*|ignored_files = includes.rules, snort3-deleted.rules|g" "$PULLEDPORK_CONF_FILE"
    sudo sed -i "s|^include_disabled_rules = .*|include_disabled_rules = true|g" "$PULLEDPORK_CONF_FILE"
    sudo sed -i "s|^sorule_path = .*|sorule_path = $SO_RULES_DIR|g" "$PULLEDPORK_CONF_FILE"
    sudo sed -i "s|^snort_path = .*|snort_path = /usr/local/bin/snort|g" "$PULLEDPORK_CONF_FILE"

    # Create and activate virtual environment
    echo "Creating and activating a virtual environment..."
    if ! python3 -m venv "$PULLEDPORK_BASE_DIR/venv"; then
        echo "Failed to create virtual environment. Installing python3-venv..."
        sudo apt-get update && sudo apt-get install -y python3-venv
        if ! python3 -m venv "$PULLEDPORK_BASE_DIR/venv"; then
            echo "Failed to create virtual environment."
            exit 1
        fi
    fi
    source "$PULLEDPORK_BASE_DIR/venv/bin/activate"

    # Install required Python packages
    echo "Installing required Python packages..."
    if ! pip install --quiet requests; then
        echo "Failed to install required Python packages."
        exit 1
    fi

    # Display PulledPork version to confirm installation
    echo "Verifying PulledPork installation..."
    if ! python3 "$PULLEDPORK_BASE_DIR/pulledpork.py" -V; then
        echo "PulledPork installation failed. Please check the logs and configuration."
        exit 1
    fi

    echo "PulledPork 3 installation and setup completed successfully."

    # Perform initial PulledPork run
    echo "Running PulledPork to fetch and configure rules..."
    if ! python3 "$PULLEDPORK_BASE_DIR/pulledpork.py" -c "$CONFIG_DIR/pulledpork.conf"; then
        echo "PulledPork execution failed. Please check the logs and configuration."
        exit 1
    fi

    # Check generated files
    echo "Checking the sizes of the generated files..."
    du -h "$SO_RULES_DIR"
    wc -l "$RULES_DIR/snort.rules"
    wc -l "$BLOCKLIST_DIR/default.blocklist"

    echo "PulledPork 3 installation completed."
    read -rp "Press Enter to continue with configuration after verifying the sizes of the generated files"

    # Backup and modify snort.lua
    echo "Backing up and modifying Snort configuration file..."
    if [ ! -f "$BACKUP_LUA_FILE" ]; then
        echo "Creating backup of snort.lua..."
        sudo cp "$SNORT_LUA_FILE" "$BACKUP_LUA_FILE"
    fi

    echo "Modifying snort.lua to include PulledPork rules..."
    sudo sed -i '/enable_builtin_rules = false,/!b;n;/include = RULE_PATH .. "\/local.rules",/d' "$SNORT_LUA_FILE"
    sudo sed -i '/enable_builtin_rules = true,/!b;n;/include = RULE_PATH .. "\/snort.rules",/!i\    include = "/usr/local/etc/rules/snort.rules",' "$SNORT_LUA_FILE"

    # Test the Snort configuration
    echo "Testing Snort configuration..."
    if ! sudo snort -c "$SNORT_LUA_FILE" --plugin-path "$SO_RULES_DIR/"; then
        echo "Snort configuration test failed. Please check the Snort logs and configuration."
        exit 1
    fi

    echo "Snort configuration tested successfully."

    pause_and_return
}

setup_pulledpork_auto_update() {
    echo "Setting up PulledPork auto-update timer..."

    # Create the PulledPork systemd service file
    sudo tee /lib/systemd/system/pulledpork3.service > /dev/null <<EOL
[Unit]
Description=Runs PulledPork3 to update Snort 3 Rulesets
Wants=pulledpork3.timer

[Service]
Type=oneshot
ExecStart=/usr/local/pulledpork3/venv/bin/python3 /usr/local/pulledpork3/pulledpork.py -c /usr/local/pulledpork3/etc/pulledpork.conf

[Install]
WantedBy=multi-user.target
EOL

    cat /lib/systemd/system/pulledpork3.service

    # Create the PulledPork systemd timer file
    sudo tee /lib/systemd/system/pulledpork3.timer > /dev/null <<EOL
[Unit]
Description=Run PulledPork3 rule updater for Snort 3 rulesets
RefuseManualStart=no
RefuseManualStop=no

[Timer]
Persistent=true
OnBootSec=120
OnCalendar=*-*-* 13:35:00
Unit=pulledpork3.service

[Install]
WantedBy=timers.target
EOL

    cat /lib/systemd/system/pulledpork3.timer

    # Reload systemd daemon to recognize the new service and timer files
    sudo systemctl daemon-reload

    # Enable and start the PulledPork timer
    sudo systemctl enable pulledpork3.timer
    sudo systemctl start pulledpork3.timer

    # Check the status of the service
    sudo systemctl status pulledpork3

    echo "PulledPork auto-update timer set up successfully."

    # Verify the Snort configuration
    echo "Verifying Snort configuration with .so rules..."
    snort -c /usr/local/etc/snort/snort.lua --plugin-path /usr/local/etc/so_rules/

    if [ $? -eq 0 ]; then
        echo "Snort configuration validated successfully with no errors."
    else
        echo "Error: Snort configuration validation failed. Please check for errors."
    fi

    pause_and_return
}

# Main function to update and enable Snort3 features
update_and_enable_snort3_features() {
    # Variables
    SNORT_LUA_FILE="/usr/local/etc/snort/snort.lua"
    BACKUP_LUA_FILE="/usr/local/etc/snort/snort.lua.before-features"
    CUSTOM_LUA_FILE="/usr/local/etc/snort/custom.lua"

    # Ensure the snort.lua file exists
    if [ ! -f "$SNORT_LUA_FILE" ]; then
        echo "Error: Snort configuration file not found at $SNORT_LUA_FILE."
        exit 1
    fi

    # Backup and restore the snort.lua before modifying it
    echo "Backing up snort.lua to $BACKUP_LUA_FILE..."
    if [ -f "$BACKUP_LUA_FILE" ]; then
        echo "Restoring $BACKUP_LUA_FILE to $SNORT_LUA_FILE..."
        sudo cp "$BACKUP_LUA_FILE" "$SNORT_LUA_FILE"
    else
        echo "Backup file $BACKUP_LUA_FILE does not exist. Creating backup..."
        sudo cp "$SNORT_LUA_FILE" "$BACKUP_LUA_FILE"
    fi

    # Prompt user for HOME_NET value
    read -p "Enter your HOME_NET value (default: 200.1.1.0/24): " HOME_NET
    HOME_NET=${HOME_NET:-200.1.1.0/24}

    # Add or update HOME_NET variable
    echo "Updating HOME_NET variable in snort.lua to $HOME_NET..."
    sudo sed -i "s|^HOME_NET = .*|HOME_NET = '$HOME_NET'|" "$SNORT_LUA_FILE"

    # Append the include 'custom.lua' line if it's not already there
    echo "Appending include 'custom.lua' to snort.lua..."
    if ! grep -q "include 'custom.lua'" "$SNORT_LUA_FILE"; then
        echo "include 'custom.lua'" | sudo tee -a "$SNORT_LUA_FILE"
    fi

    # Create the custom.lua file with the additional settings
    echo "Creating $CUSTOM_LUA_FILE with custom settings..."
    sudo tee "$CUSTOM_LUA_FILE" > /dev/null <<EOL
-- custom.lua

-- Enable hyperscan search engine
--search_engine = { search_method = "hyperscan" }
--detection = {
--    hyperscan_literals = true,
--    pcre_to_regex = true
--}

-- Enable reputation blocklist
reputation = {
    blocklist = BLACK_LIST_PATH .. "/default.blocklist",
}
--enables JSON alerting for snort alerts
alert_json =
{
file = true,
limit = 1000,
fields = 'seconds action class b64_data dir dst_addr dst_ap dst_port eth_dst eth_len eth_src eth_type gid icmp_code icmp_id icmp_seq icmp_type iface ip_id ip_len msg mpls pkt_gen pkt_len pkt_num priority proto rev rule service sid src_addr src_ap src_port target tcp_ack tcp_flags tcp_len tcp_seq tcp_win tos ttl udp_len vlan timestamp',
}
appid =
{
    app_detector_dir = '/usr/local/lib',
    --log_stats = true
}
appid_listener =
{
    json_logging = true,
    file = "/var/log/snort/appid-output.log",
}
EOL

    # Validate the snort.lua configuration
    echo "Validating snort.lua configuration..."
    if ! sudo snort -c "$SNORT_LUA_FILE" --plugin-path /usr/local/etc/so_rules/; then
        echo "Snort configuration validation failed. Restoring backup and exiting."
        sudo cp "$BACKUP_LUA_FILE" "$SNORT_LUA_FILE"
        exit 1
    fi

    echo "Configuration changes made to $SNORT_LUA_FILE"
    echo "Snort configuration validated successfully."
    
    pause_and_return
}


install_snort3_extras() {
    echo "Installing Snort OpenAppID and Snort 3 Extras..."

    # Clean up previous installations
    clean_previous_installation "$BASE_DIR/snort3_extras-*"
    clean_previous_installation "/usr/local/lib/openappid"

    cd "$BASE_DIR" || exit

    # Download Snort OpenAppID
    wget wget https://snort.org/downloads/openappid/snort-openappid.tar.gz

    # Extract and set up OpenAppID
    sudo tar -xzvf snort-openappid.tar.gz -C /usr/local/lib

    # Ensure the target directory exists and is correct
    ls -la /usr/local/lib/odp/
    read -rp "Press Enter to continue after verifying that odp directory is listed correctly"

    # Download Snort 3 Extras tarball
    wget https://api.github.com/repos/snort3/snort3_extra/tarball/refs/tags/3.3.0.0 -O snort3_extra-3.3.0.0.tar.gz
    if [ $? -ne 0 ]; then
        echo "Error: Failed to download Snort 3 Extras."
        return 1
    fi

    # Extract Snort 3 Extras
    tar -xzvf snort3_extra-3.3.0.0.tar.gz
    if [ $? -ne 0 ]; then
        echo "Error: Failed to extract Snort 3 Extras."
        return 1
    fi

    cd snort3-snort3_extra-* || exit

    # Set up PKG_CONFIG_PATH
    export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig

    # Configure and build the Snort 3 Extras
    ./configure_cmake.sh --prefix=/usr/local
    if [ $? -ne 0 ]; then
        echo "Error: Configuration failed."
        return 1
    fi

    cd build
    make -j$(nproc)
    if [ $? -ne 0 ]; then
        echo "Error: Build failed."
        return 1
    fi

    sudo make install
    if [ $? -ne 0 ]; then
        echo "Error: Installation failed."
        return 1
    fi

    # Create Snort log directory
    sudo mkdir -p /var/log/snort
    sudo chown -R snort:snort /var/log/snort

    # Verify Snort configuration
    sudo snort -c /usr/local/etc/snort/snort.lua -T --plugin-path /usr/local/etc/so_rules/
    if [ $? -ne 0 ]; then
        echo "Error: Snort configuration verification failed!"
        return 1
    fi

    echo "Snort OpenAppID and Snort 3 Extras installed successfully."

    sudo ldconfig
    cd /usr/src

    echo "Snort OpenAppID and Snort 3 Extras installed successfully."
    pause_and_return
}

install_vectorscan() {
    echo "Installing Vectorscan..."
    clean_previous_installation "$BASE_DIR/vectorscan"
    cd "$BASE_DIR" || exit
    git clone https://github.com/VectorCamp/vectorscan.git
    cd vectorscan || exit
    mkdir build
    cd build || exit
    cmake ..
    make -j$(nproc)
    sudo make install
    echo "Vectorscan installed successfully."
    pause_and_return
}


uninstall_snort3() {
    echo "Uninstalling Snort3..."
    sudo rm -rf /usr/local/bin/snort
    sudo rm -rf /usr/local/lib/snort
    sudo rm -rf /usr/local/include/snort
    sudo rm -rf /usr/local/etc/snort
    sudo rm -rf /usr/local/share/doc/snort
    sudo rm -rf /usr/local/share/man/man8/snort.8
    sudo rm -rf /usr/local/share/man/man5/snort.5
    sudo rm -rf /usr/local/share/man/man5/snort_defaults.5
    check_command
    echo "Snort3 uninstalled successfully."
    pause_and_return
}

# Function to update the snort3.service systemd service with a pid solution
update_snort_systemd_service() {
    echo "Creating snort3.service systemd service..."

    # Check if snort_wrapper.sh already exists, if not, create it
    if [ ! -f /usr/local/bin/snort_wrapper.sh ]; then
        echo "Creating snort_wrapper.sh script..."
        cat << 'EOF' | sudo tee /usr/local/bin/snort_wrapper.sh > /dev/null
#!/bin/bash

# Run Snort with the specified options
/usr/local/bin/snort -c /usr/local/etc/snort/snort.lua -s 65535 \
-k none -l /var/log/snort -D -u snort -g snort -i ens3 -m 0x1b --plugin-path=/usr/local/lib/snort_extra --plugin-path=/usr/local/etc/so_rules

# Capture the PID of the Snort process
SNORT_PID=$!

# Ensure the /var/log/snort directory exists
mkdir -p /var/log/snort

# Write the PID to the pid file
echo $SNORT_PID > /var/log/snort/snort.pid

# Change the ownership and permissions of the PID file
chown snort:snort /var/log/snort/snort.pid
chmod 775 /var/log/snort/snort.pid

# Wait for the Snort process to exit
wait $SNORT_PID
EOF

        # Make the script executable
        sudo chmod +x /usr/local/bin/snort_wrapper.sh
    else
        echo "snort_wrapper.sh already exists, skipping creation."
    fi

    # Backup original service file if it exists
    if [ -f /lib/systemd/system/snort3.service ]; then
        echo "Backing up existing snort3.service..."
        sudo cp /lib/systemd/system/snort3.service /lib/systemd/system/snort3.service.bak
    fi

    # List available network interfaces (excluding loopback)
    echo "Available network interfaces:"
    ip --brief a | egrep -v "lo"

    # Prompt user to select the interface for sniffing
    read -rp "Enter the name of the interface used for sniffing traffic: " interface_name

    # Create or update the systemD service file
    cat << EOF | sudo tee /lib/systemd/system/snort3.service > /dev/null
[Unit]
Description=Snort Daemon
After=syslog.target network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/snort_wrapper.sh --plugin-path=/usr/local/lib/snort_extra --plugin-path=/usr/local/etc/so_rules
ExecStopPost=/usr/bin/rm -f /var/log/snort/snort.pid
Restart=on-failure
RestartSec=120s

[Install]
WantedBy=multi-user.target
EOF

    echo "snort3.service file created or updated:"
    cat /lib/systemd/system/snort3.service
    echo ""
    echo "Please verify that the snort3.service is correctly configured with your interface."
    echo "Press Enter to continue after verifying."
    read -r

    # Reload systemd daemon and enable/start snort3.service
    sudo systemctl daemon-reload
    sudo systemctl enable snort3.service
    sudo systemctl start snort3.service

    echo "snort3.service created, enabled, and started."

    # Verify service status
    echo "Verifying the status of snort3.service..."
    sudo systemctl status snort3.service
    echo ""

    # Check if the Snort process is running and save its PID
    if [ -f /var/log/snort/snort.pid ]; then
        snort_pid=$(cat /var/log/snort/snort.pid)
        echo "Snort PID: $snort_pid"
    else
        echo "PID file not found. Snort may not be running."
    fi

    # Additional checks
    echo "Checking if Snort is running..."
    ps -ef | grep snort
    echo ""

    # Pause and return (assuming pause_and_return is defined elsewhere in your script)
    pause_and_return
}


edit_snort_lua() {
    nano /usr/local/etc/snort/snort.lua
}

test_snort_lua() {
    snort -c /usr/local/etc/snort/snort.lua --plugin-path /usr/local/etc/so_rules/ -T
    #uncomment all below to make daemon test
#    read -rp "snort lua test ended press Enter to continue with daemon test"
    # List available network interfaces (excluding loopback)
#    echo "Available network interfaces:"
#    ip --brief a | egrep -v "lo"
    # Prompt user to select the interface for sniffing
#    read -rp "Enter the name of the interface used for sniffing traffic: " interface_name
#    snort -c /usr/local/etc/snort/snort.lua -s 65535 -k none -l /var/log/snort -D -u snort -g snort -i $interface_name -m 0x1b --plugin-path=/usr/local/lib/snort_extra --plugin-path=/usr/local/etc/so_rules
}

edit_pulledpork_conf() {
    nano /usr/local/pulledpork3/etc/pulledpork.conf
}

edit_local_rules() {
    nano /usr/local/etc/rules/local.rules
}

run_pulledpork() {
    sudo /usr/local/pulledpork3/pulledpork.py -c /usr/local/pulledpork3/etc/pulledpork.conf
}

edit_snort_service() {
    nano /lib/systemd/system/snort3.service
}

reload_and_test_snort_service() {
    sudo systemctl daemon-reload
    sudo systemctl stop snort3.service
    sudo systemctl start snort3.service
    sudo systemctl status snort3.service
}
edit_custom_lua(){
    nano /usr/local/etc/snort/custom.lua
}

tests_and_edits() {
    while true; do
        clear
        echo "Tests and Edits Menu"
        echo "-------------------------"
        echo "1. Edit snort.lua - from /usr/local/etc/snort/snort.lua"
        echo "2. Test snort.lua"
        echo "3. Edit PulledPork config - from /usr/local/pulledpork3/etc/pulledpork.conf"
        echo "4. Edit local.rules - from /usr/local/etc/rules/"
        echo "5. Run PulledPork"
        echo "6. Edit Snort service file - from /lib/systemd/system/snort3.service"
        echo "7. Reload and test Snort service"
        echo "8. Edit custom.lua - from /usr/local/etc/snort/custom.lua"
        echo "0. Return to main menu"
        echo "-------------------------"
        read -rp "Enter your choice: " choice
        case $choice in
            1) edit_snort_lua ;;
            2) test_snort_lua ;;
            3) edit_pulledpork_conf ;;
            4) edit_local_rules ;;
            5) run_pulledpork ;;
            6) edit_snort_service ;;
            7) reload_and_test_snort_service ;;
            8) edit_custom_lua ;;
            0) break ;;
            *) echo "Invalid option" ;;
        esac
        read -rp "Press Enter to continue..."
    done
}

main_menu() {
    while true; do
        clear
        echo "Snort Installation Script"
        echo "-------------------------"
        echo "1. Install Pre-requisites"
        echo "2. Install PCRE"
        echo "3. Install gperftools"
        echo "4. Install Ragel"
        echo "5. Download Boost"
        echo "6. Install Boost (optional)"
        echo "7. Install Safeclib"
        echo "8. Install Hyperscan"
        echo "9. Install Flatbuffers"
        echo "10. Install Data Acquisition (DAQ)"
        echo "11. Update Shared Libraries"
        echo "12. Create ethtool.service"
        echo "13. Install Snort 3"
        echo "14. Enabling Built-in Rules and Testing Snort"
        echo "15. Configure Snort User, Group, Permissions"
        echo "16. Create snort3.service Systemd Service"
        echo "17. Install and configure PulledPork 3"
        echo "18. Setup PulledPork Auto-Update Timer"
        echo "19. Install Snort 3 OpenAppID/ODP and Extras"
        echo "20. Enable Snort3 Features (Hyperscan, Blocklist, json, SO_rules)"
        echo "21. Install Vectorscan (alternative to Hyperscan)"
        echo "22. Uninstall Snort 3"
        echo "23. Update snort3_systemd with PID"
        echo "24. Tests and Edits"
        echo "0. Exit"
        echo "-------------------------"
        read -rp "Enter your choice: " choice
        case $choice in
            1) install_prereqs ;;
            2) install_pcre ;;
            3) install_gperftools ;;
            4) install_ragel ;;
            5) download_boost ;;
            6) install_boost ;;
            7) install_safeclib ;;
            8) install_hyperscan ;;
            9) install_flatbuffers ;;
            10) install_daq ;;
            11) update_shared_libraries ;;
            12) create_ethtool_service ;;
            13) install_snort3 ;;
            14) enabling_builtin_rules_and_testing_snort ;;
            15) configure_snort_user_and_permissions ;;
            16) create_snort_systemd_service ;;
            17) install_pulledpork ;;
            18) setup_pulledpork_auto_update ;;
            19) install_snort3_extras ;;
            20) update_and_enable_snort3_features ;;
            21) install_vectorscan ;;
            22) uninstall_snort3 ;;
            23) update_snort_systemd_service ;;
            24) tests_and_edits ;;
            0) exit ;;
            *) echo "Invalid option" ;;
        esac
        read -rp "Press Enter to continue..."
    done
}

main_menu

