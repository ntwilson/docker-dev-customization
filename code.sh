#!/bin/bash

# Get the path argument, default to current directory if not provided
TARGET_PATH="${1:-.}"

# Convert to absolute path
if [[ "$TARGET_PATH" = /* ]]; then
    # Already absolute
    ABSOLUTE_PATH="$TARGET_PATH"
else
    # Make relative path absolute
    ABSOLUTE_PATH="$(cd "$TARGET_PATH" 2>/dev/null && pwd)" || {
        echo "Error: Path '$TARGET_PATH' does not exist"
        exit 1
    }
fi

# Create a unique request file
REQUEST_FILE="/vscode-requests/vscode-request-$(date +%s%N)"

# Write container ID and absolute path
echo "$(hostname)" > "$REQUEST_FILE"
echo "$ABSOLUTE_PATH" >> "$REQUEST_FILE"

echo "VS Code open request sent for: $ABSOLUTE_PATH"