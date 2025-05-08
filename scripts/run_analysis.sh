#!/usr/bin/env bash
# Runs the full earthquake analysis/script

# Optional: load environment variables
if [[ -f .env ]]; then
  export $(grep -v '^#' .env | xargs)
fi

echo "[$(date)] Starting analysis..."
Rscript earthquake_viz_complete.R
echo "[$(date)] Analysis complete."
