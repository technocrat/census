#!/bin/bash
# Install system dependencies for Census.jl visualization

echo "Census.jl System Dependencies Installer"
echo "======================================="

if [[ "$(uname)" != "Darwin" ]]; then
  echo "This script is designed for macOS. You're running on $(uname)"
  echo "You may need to adapt this script for your system."
  exit 1
fi

echo ""
echo "Step 1: Installing required Homebrew packages"
echo "--------------------------------------------"
brew install libxml2 gtk+3 libffi pcre dbus glib

echo ""
echo "Step 2: Creating a wrapper script"
echo "-------------------------------"

cat > ~/bin/julia-viz << 'EOF'
#!/bin/bash
# Wrapper script for running Julia with proper environment variables for visualization
export DYLD_FALLBACK_LIBRARY_PATH="/opt/homebrew/lib:$DYLD_FALLBACK_LIBRARY_PATH"
export LIBXML2_PATH="/opt/homebrew/lib"
julia "$@"
EOF

mkdir -p ~/bin
chmod +x ~/bin/julia-viz

echo ""
echo "Step 3: Instructions"
echo "-----------------"
echo "To use visualization in Census.jl:"
echo ""
echo "1. Run Julia with visualization support using:"
echo "   ~/bin/julia-viz"
echo ""
echo "2. Or set the environment variables manually:"
echo "   DYLD_FALLBACK_LIBRARY_PATH=/opt/homebrew/lib julia"
echo ""
echo "3. Make sure ~/bin is in your PATH by adding to ~/.zshrc:"
echo "   export PATH=\"\$HOME/bin:\$PATH\""
echo ""
echo "4. Run the Julia fix script to install required packages:"
echo "   ~/bin/julia-viz scripts/fix_visualization.jl"
echo ""
echo "Installation complete!" 