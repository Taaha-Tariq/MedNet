# Install Flutter on Linux (Bash)

## Option A: Git clone (recommended)
```bash
# 1) Install prerequisites (Debian/Ubuntu)
sudo apt-get update
sudo apt-get install -y git curl unzip xz-utils zip libglu1-mesa clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev

# 2) Download Flutter stable via git
mkdir -p "$HOME/development"
git clone https://github.com/flutter/flutter.git -b stable "$HOME/development/flutter"

# 3) Add Flutter to PATH (bash)
if ! grep -q 'development/flutter/bin' "$HOME/.bashrc"; then
  echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> "$HOME/.bashrc"
fi
source "$HOME/.bashrc"

# 4) Verify installation
flutter --version
flutter doctor

# 5) (Optional) Enable desktop support
flutter config --enable-linux-desktop
```

## Option B: Snap (alternative)
```bash
sudo snap install flutter --classic
flutter --version
flutter doctor
```

## Android builds (optional)
- Install Android Studio from https://developer.android.com/studio
- Open Android Studio → SDK Manager → Install latest SDK + Platform Tools
- Then run: `flutter doctor --android-licenses`

Notes:
- If `flutter doctor` reports missing tools, follow its suggestions.
- For non-Ubuntu distros, install equivalent packages for git, unzip, xz, cmake, ninja, gtk.
