#!/bin/bash

# Create a unique request file
REQUEST_FILE="/vscode-requests/vscode-request-$(date +%s%N)"

# Write container ID and current directory
echo "$(hostname)" > "$REQUEST_FILE"
echo "$(pwd)" >> "$REQUEST_FILE"

echo "VS Code open request sent..."