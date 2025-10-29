#!/bin/sh
# Script to install uv if not already installed, then run uv sync.
# Optionally start Jupyter Lab after setup.

set -e

echo "[setup] Checking for uv..."
if ! command -v uv >/dev/null 2>&1; then
    echo "[setup] uv not found. Installing via official script..."
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL https://astral.sh/uv/install.sh | sh || {
            echo "[error] Failed to install uv via curl. Please check your network or permissions.";
            exit 1;
        }
    elif command -v wget >/dev/null 2>&1; then
        wget -qO- https://astral.sh/uv/install.sh | sh || {
            echo "[error] Failed to install uv via wget. Please check your network or permissions.";
            exit 1;
        }
    else
        echo "[error] Neither curl nor wget is available to install uv. Please install one and re-run.";
        exit 1;
    fi
else
    echo "[setup] uv is already installed."
fi

echo "[setup] Syncing Python environment with uv..."
uv sync

# Optional: register a kernel name tied to this environment for convenience
if command -v uv >/dev/null 2>&1; then
    echo "[setup] Registering IPython kernel (optional)..."
    uv run ipython kernel install --user --name="project" || echo "[warn] ipython kernel registration skipped."
fi

# Prompt user whether to start Jupyter Lab now
printf "\nStart Jupyter Lab now? [Y/n]: "
read ans
case "$ans" in
    n|N|no|No|NO)
        echo "[setup] Skipping Jupyter Lab launch. You can start it later with: uv run --with jupyter jupyter lab"
        ;;
    *)
        echo "[setup] Launching Jupyter Lab... (Ctrl+C to stop)"
        uv run --with jupyter jupyter lab
        ;;
esac
