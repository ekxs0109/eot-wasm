# eot-wasm

A WebAssembly wrapper for [libeot](https://github.com/umanwizard/libeot) enabling EOT to TTF font conversion directly in web browsers.

[中文文档](./README.zh.md)

## Overview

eot-wasm provides a JavaScript/WebAssembly library for converting Embedded OpenType (EOT) fonts to TrueType (TTF) format entirely client-side. This is particularly useful for web applications that need to handle legacy EOT fonts without server-side processing.

## Features

- Convert EOT to TTF entirely in the browser
- No server-side processing required
- Simple JavaScript API
- Built on the robust libeot C library
- Full filesystem support through Emscripten

## Installation

### Using npm/pnpm

```bash
pnpm add eot-wasm
```

### Direct script include

```html
<script src="https://unpkg.com/eot-wasm@1.0.0/dist/eot-wasm.js"></script>
```

## Usage

### Basic Example

```javascript
// Load the module
LibEOT().then(module => {
  // Create virtual file system entries
  const eotPath = '/input.eot';
  const ttfPath = '/output.ttf';
  
  // Write EOT data to virtual filesystem
  module.FS.writeFile(eotPath, eotData); // eotData should be a Uint8Array
  
  // Convert EOT to TTF
  const result = module.ccall(
    'convertEOTtoTTF',
    'number',
    ['string', 'string'],
    [eotPath, ttfPath]
  );
  
  if (result === 0) {
    // Read the converted TTF data
    const ttfData = module.FS.readFile(ttfPath);
    // Use the TTF data...
  }
});
```

### Complete Example

See the [examples directory](./examples/) for a complete example with file upload and download functionality.

## API Reference

### Module Functions

#### `convertEOTtoTTF(eotFilePath, ttfFilePath)`

Converts an EOT file to TTF format.

- **Parameters**:
  - `eotFilePath` (string): Path to the EOT file in the virtual filesystem
  - `ttfFilePath` (string): Path where the converted TTF file should be saved
- **Returns**: Integer error code (0 for success)

#### `getErrorDescription(errorCode, buffer, bufferSize)`

Retrieve a human-readable description of an error code.

- **Parameters**:
  - `errorCode` (number): The error code returned by `convertEOTtoTTF`
  - `buffer` (pointer): Buffer where the error description will be written
  - `bufferSize` (number): Size of the buffer

### File System API

The module provides access to Emscripten's virtual file system through `module.FS`. Key methods include:

- `FS.writeFile(path, data)`: Write data to a file
- `FS.readFile(path)`: Read data from a file
- `FS.unlink(path)`: Delete a file

## Building from Source

### Prerequisites

- Emscripten SDK (emsdk)
- Git

### Setup and Build Steps

1. Clone the repository with submodules:

```bash
git clone --recursive https://github.com/your-username/eot-wasm.git
cd eot-wasm
```

2. If you've already cloned the repo without submodules:

```bash
git submodule update --init --recursive
```

3. Run the setup script to install dependencies and Emscripten SDK:

```bash
chmod +x setup.sh
./setup.sh
```

This script will:
- Check and install required build dependencies (cmake, make, python3)
- Install the Emscripten SDK if not already present
- Initialize git submodules if needed

4. Build the WebAssembly module:

```bash
chmod +x build.sh
./build.sh
# or use npm/pnpm
pnpm build
```

The compiled files will be placed in the `dist` directory.

## License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

## Credits

- [libeot](https://github.com/umanwizard/libeot): The underlying C library for EOT conversion
