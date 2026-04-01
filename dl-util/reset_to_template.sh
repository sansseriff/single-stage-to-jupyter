#!/usr/bin/env bash
set -euo pipefail

# Reset repository to template state and optionally re-run initialization
#
# This script:
# - Removes the bootstrap state file
# - Restores the original template README (if README.template.md exists)
# - Optionally re-runs initialize_repo.sh with your settings

cd "$(dirname "$0")/.."

echo "Resetting to template state..."

# Remove bootstrap state
if [[ -f dl-util/.s2j-state.json ]]; then
    rm -f dl-util/.s2j-state.json
    echo "  ✓ Removed bootstrap state"
fi

# Remove generated download scripts (now built from templates)
if [[ -f dl-util/dl.sh ]]; then
    rm -f dl-util/dl.sh
    echo "  ✓ Removed generated dl-util/dl.sh"
fi
if [[ -f dl-util/dl.ps1 ]]; then
    rm -f dl-util/dl.ps1
    echo "  ✓ Removed generated dl-util/dl.ps1"
fi

# Remove other generated files
if [[ -f dl-util/repo_url.txt ]]; then
    rm -f dl-util/repo_url.txt
    echo "  ✓ Removed dl-util/repo_url.txt"
fi

# Restore tracked files that initialize_repo modifies, back to their committed state
for f in pyproject.toml .gitattributes dl-util/index.html; do
    if git ls-files --error-unmatch "$f" >/dev/null 2>&1; then
        git checkout -- "$f"
        echo "  ✓ Restored $f from git"
    fi
done

# Remove generated src/ files (both are produced by initialize_repo from dl-util templates)
if [[ -f src/demo_analysis.py ]]; then
    rm -f src/demo_analysis.py
    echo "  ✓ Removed src/demo_analysis.py"
fi
if [[ -f src/data_analysis.ipynb ]]; then
    rm -f src/data_analysis.ipynb
    echo "  ✓ Removed src/data_analysis.ipynb"
fi

# Uninstall nbstripout git filter if it was configured by initialize_repo
if git config --get filter.nbstripout.smudge >/dev/null 2>&1; then
    git config --remove-section filter.nbstripout 2>/dev/null || true
    git config --remove-section diff.ipynb 2>/dev/null || true
    echo "  ✓ Removed nbstripout git filter config"
fi

# Restore original README if backup exists
if [[ -f README.template.md ]]; then
    mv README.template.md README.md
    echo "  ✓ Restored original README from README.template.md"
else
    echo "  ⚠ No README.template.md found; keeping current README.md"
fi

# Ask if user wants to re-run initialization
if [[ "${1:-}" == "--reinit" ]] || [[ "${1:-}" == "-r" ]]; then
    shift || true
    echo ""
    echo "Re-running initialization..."
    ./initialize_repo.sh "$@"
else
    echo ""
    echo "Reset complete. To re-initialize, run:"
    echo "  ./initialize_repo.sh [--user <user>] [--repo <repo>] [--yes]"
fi
