#!/bin/bash

# FreeCAD Installer Script
# Downloads the latest AppImage, icon and creates desktop integration

set -e  # Exit on error

echo "Starting FreeCAD installation..."

# Get latest version
echo "Fetching latest FreeCAD version..."
LATEST_URL="https://github.com/FreeCAD/FreeCAD/releases/latest"
VERSION=$(basename $(curl -Ls -o /dev/null -w %{url_effective} "$LATEST_URL"))
echo "Found version: $VERSION"

# Get AppImage URL
echo "Locating AppImage download..."
RELEASE_ASSETS_URL="https://github.com/FreeCAD/FreeCAD/releases/expanded_assets/$VERSION"
APPIMAGE_URL=$(curl -s "$RELEASE_ASSETS_URL" | grep -oP 'href="\K[^"]*conda-Linux-aarch64-py[0-9]+\.AppImage(?=")')

if [[ -z "$APPIMAGE_URL" ]]; then
    echo "Error: Could not find AppImage download link"
    exit 1
fi

# Create necessary directories
echo "Creating directories..."
mkdir -p ~/.local/bin ~/.local/share/icons ~/.local/share/applications

# Download AppImage
echo "Downloading FreeCAD AppImage..."
wget -q --show-progress "https://github.com$APPIMAGE_URL" -O ~/.local/bin/FreeCAD_$VERSION.AppImage
chmod +x ~/.local/bin/FreeCAD_$VERSION.AppImage

# Create versionless symlink
ln -sf ~/.local/bin/FreeCAD_$VERSION.AppImage ~/.local/bin/freecad

# Download icon
echo "Downloading FreeCAD icon..."
ICON_URL="https://github.com/FreeCAD/FPA/raw/main/images/logos/FreeCAD-symbol.png"
if ! wget -q "$ICON_URL" -O ~/.local/share/icons/freecad.png; then
    echo "Warning: Failed to download icon, using default"
    cp /usr/share/icons/default.kde4/64x64/apps/preferences-desktop.png ~/.local/share/icons/freecad.png 2>/dev/null || true
fi

# Create desktop file
echo "Creating desktop entry..."
cat > ~/.local/share/applications/freecad.desktop <<EOL
[Desktop Entry]
Name=FreeCAD
Exec=$HOME/.local/bin/freecad
Comment=3D CAD Modeler
Terminal=false
Icon=freecad
Type=Application
Categories=Graphics;Science;Engineering;
EOL

# Add to PATH
echo "Updating PATH..."
if ! grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
fi

echo -e "\n✅ Installation successful!"
echo "FreeCAD $VERSION installed to:"
echo "  ~/.local/bin/FreeCAD_$VERSION.AppImage"
echo -e "\nYou can now:"
echo "1. Launch from your application menu"
echo "2. Run from terminal with: freecad"
echo "3. Or using full version: FreeCAD_$VERSION.AppImage"
