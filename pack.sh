#!/usr/bin/env bash
# 把这个包打成 tarball —— 给别人用。
set -euo pipefail

PKG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d)"
OUT_DIR="$PKG_DIR/dist"
TARBALL="$OUT_DIR/aim-dist-$STAMP.tar.gz"

mkdir -p "$OUT_DIR"

# 只打包要发的东西——别把 dist/ 自己也塞进去。
tar -czf "$TARBALL" \
  -C "$PKG_DIR" \
  --exclude=dist \
  --exclude='__pycache__' \
  --exclude='.git' \
  README.md install.sh pack.sh skills agents

echo "打好了：$TARBALL"
ls -lh "$TARBALL"
