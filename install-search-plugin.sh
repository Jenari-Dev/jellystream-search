#!/bin/bash
# JellyStream Search Plugin Installer
# Run this on your NAS (bliffblackboxmon) as jenariskywalker
#
# This copies the search plugin JS into your Jellyfin container's web root
# and patches index.html to load it automatically.

set -e

CONTAINER_NAME="jellyfin"  # Change if your container has a different name
PLUGIN_FILE="jellystream-search.js"
WEB_DIR="/jellyfin/jellyfin-web"

echo "=== JellyStream Search Plugin Installer ==="
echo ""

# Step 1: Copy the JS file into the container
echo "[1/3] Copying plugin file into container..."
docker cp "$PLUGIN_FILE" "$CONTAINER_NAME:$WEB_DIR/$PLUGIN_FILE"

# Step 2: Check if already patched
echo "[2/3] Checking index.html..."
if docker exec "$CONTAINER_NAME" grep -q "jellystream-search" "$WEB_DIR/index.html"; then
    echo "  Already patched! Skipping."
else
    echo "  Patching index.html to load plugin..."
    # Insert script tag before closing </body>
    docker exec "$CONTAINER_NAME" sed -i "s|</body>|<script src=\"$PLUGIN_FILE\"></script></body>|" "$WEB_DIR/index.html"
    echo "  Done."
fi

# Step 3: Restart Jellyfin to pick up changes
echo "[3/3] Restarting Jellyfin container..."
docker restart "$CONTAINER_NAME"

echo ""
echo "=== Installation complete! ==="
echo "Open Jellyfin and navigate to Search to see the new visual search page."
echo ""
echo "NOTE: This patch will be lost if the container image is updated."
echo "Re-run this script after any Jellyfin container rebuild."
