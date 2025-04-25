#!/bin/bash

EMSDK_DIR="$HOME/emsdk"
EMCC_VERSION="3.1.45"

# Check and install Emscripten SDK
check_and_install_emsdk() {
  echo "Checking Emscripten SDK environment..."
  
  # Check if git is installed
  if ! command -v git &> /dev/null; then
    echo "Git not found, installing..."
    if command -v apt-get &> /dev/null; then
      sudo apt-get update && sudo apt-get install -y git
    elif command -v yum &> /dev/null; then
      sudo yum install -y git
    elif command -v pacman &> /dev/null; then
      sudo pacman -S --noconfirm git
    elif command -v brew &> /dev/null; then
      brew install git
    else
      echo "Error: Cannot install git. Please install git manually and retry."
      exit 1
    fi
  fi
  
  # Check if Emscripten SDK is installed
  if [ ! -d "$EMSDK_DIR" ]; then
    echo "Emscripten SDK not found, installing to $EMSDK_DIR..."
    git clone https://github.com/emscripten-core/emsdk.git "$EMSDK_DIR"
    cd "$EMSDK_DIR"
    ./emsdk install $EMCC_VERSION
    ./emsdk activate $EMCC_VERSION
    cd - > /dev/null
  else
    echo "Emscripten SDK found: $EMSDK_DIR"
    cd "$EMSDK_DIR"
    # Update emsdk
    git pull
    # Check if required version is installed and activated
    if ! ./emsdk list | grep "$EMCC_VERSION" | grep INSTALLED > /dev/null; then
      echo "Installing Emscripten $EMCC_VERSION..."
      ./emsdk install $EMCC_VERSION
      ./emsdk activate $EMCC_VERSION
    fi
    cd - > /dev/null
  fi
}

# Check and install dependencies
check_and_install_dependencies() {
  echo "Checking build dependencies..."
  
  local missing_deps=false
  local deps_to_install=()
  
  # Check necessary build tools
  for cmd in cmake make python3; do
    if ! command -v $cmd &> /dev/null; then
      missing_deps=true
      deps_to_install+=("$cmd")
    fi
  done
  
  # If there are missing dependencies, try to install them
  if [ "$missing_deps" = true ]; then
    echo "Installing missing dependencies: ${deps_to_install[*]}"
    if command -v apt-get &> /dev/null; then
      sudo apt-get update && sudo apt-get install -y ${deps_to_install[@]}
    elif command -v yum &> /dev/null; then
      sudo yum install -y ${deps_to_install[@]}
    elif command -v pacman &> /dev/null; then
      sudo pacman -S --noconfirm ${deps_to_install[@]}
    elif command -v brew &> /dev/null; then
      brew install ${deps_to_install[@]}
    else
      echo "Warning: Cannot automatically install dependencies. Please manually install the following programs: ${deps_to_install[*]}"
      exit 1
    fi
  fi
}

# Check git submodules status
check_git_submodules() {
  echo "Checking git submodules status..."
  
  # Check libeot submodule
  if [ ! -d "libeot" ] || [ ! "$(ls -A libeot 2>/dev/null)" ]; then
    echo "Initializing git submodules..."
    git submodule update --init --recursive
  else
    echo "Git submodules already exist"
  fi
}

# Run all checks and installations
check_and_install_dependencies
check_and_install_emsdk
check_git_submodules

echo "======================================"
echo "Installation complete! You can now run:"
echo "  1. ./build.sh or pnpm build"
echo "======================================"
