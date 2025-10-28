#!/bin/bash
set -e

# Clone or pull the latest changes from the repo
REPO_URL="https://github.com/sansseriff/switch_control.git"
TARGET_DIR="$(pwd)"

if [ -d "$TARGET_DIR/.git" ]; then
    git -C "$TARGET_DIR" pull
else
    git clone "$REPO_URL"
fi

# Navigate to the switch_control directory
cd "$TARGET_DIR/switch_control"

# Run the setup script
bash -i setup.sh