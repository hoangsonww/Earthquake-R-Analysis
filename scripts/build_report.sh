#!/usr/bin/env bash
# Fetch data, run analysis, then render the R Markdown report

set -euo pipefail

echo "===== Build Report ====="
./scripts/fetch_quakes.sh
./scripts/run_analysis.sh

echo "Rendering RMarkdown..."
Rscript -e "rmarkdown::render('earthquake_report.Rmd', output_file='report.html')"
echo "Report built: report.html"
