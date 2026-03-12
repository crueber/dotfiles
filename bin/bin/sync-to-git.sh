#!/bin/bash

SYNC_DIR="$1"

if [ -z "$SYNC_DIR" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

cd "$SYNC_DIR" || exit 1

# Initialize git if needed
if [ ! -d .git ]; then
  # Create .gitignore
  cat >.gitignore <<'EOF'
.stfolder
.stversions
.stignore
EOF

  # Create/update .stignore to exclude git
  if [ ! -f .stignore ]; then
    cat >.stignore <<'EOF'
.git
.gitignore
EOF
  else
    # Append if not already present
    grep -qxF '.git' .stignore || echo '.git' >>.stignore
    grep -qxF '.gitignore' .stignore || echo '.gitignore' >>.stignore
  fi

  git init
  git add .
  git commit -m "Initial commit"
fi

# Check for changes
if ! git diff-index --quiet HEAD --; then
  git add -A
  git commit -m "Auto-backup: $(date '+%Y-%m-%d %H:%M:%S')"
  git push origin main
fi
