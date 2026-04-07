#!/bin/bash
# JellyStream Search — Auto-patching entrypoint for Jellyfin Docker
# by Kain (jenariskywalker)
#
# This script runs BEFORE Jellyfin starts on every container boot.
# It copies the search plugin JS into the web root and patches index.html.
# Because it runs on every start, it survives image updates automatically.
#
# SETUP (one-time):
# 1. Place jellystream-search.js in ~/jellystream/ on your NAS
# 2. Add these volumes to your Jellyfin docker-compose.yml:
#
#    volumes:
#      - /home/jenariskywalker/jellystream/jellystream-search.js:/jellystream-search.js:ro
#      - /home/jenariskywalker/jellystream/jellystream-entrypoint.sh:/jellystream-entrypoint.sh:ro
#
# 3. Set the entrypoint in your docker-compose.yml:
#
#    entrypoint: /jellystream-entrypoint.sh
#

PLUGIN_FILE="/jellystream-search.js"
WEB_DIR="/jellyfin/jellyfin-web"
TARGET="$WEB_DIR/jellystream-search.js"
INDEX="$WEB_DIR/index.html"

echo "========================================="
echo " JellyStream Search — Auto Patcher"
echo "========================================="

# Step 1: Copy plugin JS into web root
if [ -f "$PLUGIN_FILE" ]; then
    cp "$PLUGIN_FILE" "$TARGET"
    echo "[✓] Copied jellystream-search.js to web root"
else
    echo "[✗] Plugin file not found at $PLUGIN_FILE"
    echo "    Make sure the volume mount is correct."
fi

# Step 2: Patch index.html if not already patched
if [ -f "$INDEX" ]; then
    if grep -q "jellystream-search" "$INDEX"; then
        echo "[✓] index.html already patched"
    else
        sed -i 's|</body>|<script src="jellystream-search.js"></script></body>|' "$INDEX"
        echo "[✓] Patched index.html with script tag"
    fi
else
    echo "[✗] index.html not found at $INDEX"
fi

echo "========================================="
echo " Starting Jellyfin..."
echo "========================================="

# Hand off to the real Jellyfin entrypoint
exec /jellyfin/jellyfin "$@"
