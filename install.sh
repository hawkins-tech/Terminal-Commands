#!/usr/bin/env bash
# Installation script for Terminal-Commands
# Usage: curl -sSL https://raw.githubusercontent.com/hawkins-tech/Terminal-Commands/main/install.sh | bash

set -e

REPO_URL="https://github.com/hawkins-tech/Terminal-Commands"
INSTALL_DIR="/usr/local/bin"
TEMP_DIR=$(mktemp -d)

echo "==================================="
echo "Terminal-Commands installer"
echo "==================================="
echo ""

# Check if running with sudo/root for system-wide install
if [ "$EUID" -ne 0 ]; then 
  echo "Note: This script requires sudo privileges to install to $INSTALL_DIR"
  echo "You may be prompted for your password."
  echo ""
fi

echo "Downloading Terminal-Commands..."
cd "$TEMP_DIR"

# Try to download using git if available, otherwise use curl/wget
if command -v git &> /dev/null; then
  git clone --depth 1 "$REPO_URL" Terminal-Commands
  cd Terminal-Commands
else
  echo "Error: git is required for installation"
  echo "Please install git and try again"
  exit 1
fi

echo ""
echo "Installing commands to $INSTALL_DIR..."

# Make scripts executable and install
chmod +x bin/*
sudo cp bin/* "$INSTALL_DIR/"
echo "  Installed $(ls bin/ | wc -w) commands"

echo ""
echo "Cleaning up..."
rm -rf "$TEMP_DIR"

echo ""
echo "==================================="
echo "Installation complete!"
echo "==================================="
echo ""
echo "The following commands are now available:"
echo ""
echo "  Process & Port Management:"
echo "  - killgrep <pattern>   Kill processes matching a name pattern"
echo "  - portowner <port>     Show/kill what owns a port (JSON)"
echo "  - waitport <port>      Wait until a port is ready"
echo "  - waitpid <pid>        Wait for any process to exit"
echo "  - portfree [range]     Find an available port"
echo ""
echo "  System Introspection:"
echo "  - syssnap              System health snapshot (JSON)"
echo "  - gitstat              Git repo state (JSON)"
echo "  - envdump              Environment dump (JSON)"
echo "  - diskwhy [path]       Disk usage breakdown"
echo ""
echo "  File Operations:"
echo "  - trash <path>         Move files to recoverable trash"
echo "  - secure_delete <path> Securely wipe files (DoD standard)"
echo "  - checkpoint <cmd>     Named file/directory snapshots"
echo "  - batchrename <p> <r>  Bulk rename with regex (dry-run default)"
echo ""
echo "  Streaming & Looping:"
echo "  - firstmatch <pattern> Print first matching line from stdin"
echo "  - always <command>     Retry a command forever"
echo "  - execs                List all executables in PATH"
echo ""
echo "Run any command with -h or --help for usage details."
