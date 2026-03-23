#!/bin/bash

# Ensure we're in the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
cd "$SCRIPT_DIR"

# Check if PowerShell Core (pwsh) is installed
if ! command -v pwsh &> /dev/null; then
    echo "Error: PowerShell Core ('pwsh') is not installed."
    echo "This script acts as a Linux wrapper around make_card.ps1."
    echo ""
    echo "To install on Ubuntu/Debian, run:"
    echo "  sudo apt update"
    echo "  sudo apt install -y powershell libgdiplus"
    echo "  (Note: libgdiplus is required for the System.Drawing APIs used in the .ps1 script)"
    echo ""
    echo "For other Linux distributions, see: https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux"
    exit 1
fi

echo "Running make_card.ps1 via PowerShell Core..."
pwsh -ExecutionPolicy Bypass -File ./make_card.ps1

if [ $? -eq 0 ]; then
    echo "Done! The profile card should be updated."
else
    echo "PowerShell script encountered an error."
    exit 1
fi
