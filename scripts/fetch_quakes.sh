#!/usr/bin/env bash
# Fetch the past 30 days M≥2.5 feed and save locally

DATA_DIR="${DATA_DIR:-./data}"
URL="https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_month.csv"
OUT_FILE="$DATA_DIR/2.5_month.csv"

mkdir -p "$DATA_DIR"
echo "[$(date)] Downloading earthquake feed..."
curl -sSL "$URL" -o "$OUT_FILE"
echo "Saved to $OUT_FILE"
