#!/bin/bash

EMSDK_DIR="$HOME/emsdk"

# Check if Emscripten environment is already set up
if ! command -v emcc &> /dev/null; then
  if [ -f "$EMSDK_DIR/emsdk_env.sh" ]; then
    echo "Activating Emscripten environment..."
    source "$EMSDK_DIR/emsdk_env.sh"
  else
    echo "Error: Emscripten environment not found. Please run ./setup.sh first to install it."
    exit 1
  fi
fi

echo "Using Emscripten: $(which emcc) ($(emcc --version | head -n 1))"

# Create output directory
mkdir -p dist

# Compile libeot library and wrapper to WebAssembly
echo "Building eot-wasm..."
emcc -O2 \
    libeot/src/libeot.c \
    libeot/src/EOT.c \
    libeot/src/writeFontFile.c \
    libeot/src/triplet_encodings.c \
    libeot/src/ctf/parseCTF.c \
    libeot/src/ctf/parseTTF.c \
    libeot/src/ctf/SFNTContainer.c \
    libeot/src/util/stream.c \
    libeot/src/lzcomp/ahuff.c \
    libeot/src/lzcomp/bitio.c \
    libeot/src/lzcomp/liblzcomp.c \
    libeot/src/lzcomp/lzcomp.c \
    libeot/src/lzcomp/mtxmem.c \
    src/libeot_wrapper.c \
    -I./libeot/inc \
    -DDECOMPRESS_ON \
    -s WASM=1 \
    -s EXPORTED_RUNTIME_METHODS="['ccall', 'cwrap', 'FS']" \
    -s FORCE_FILESYSTEM=1 \
    -s ALLOW_MEMORY_GROWTH=1 \
    -s MODULARIZE=1 \
    -s EXPORT_NAME="LibEOT" \
    -o dist/eot-wasm.js

echo "Build completed! The eot-wasm library has been generated in the dist directory."
