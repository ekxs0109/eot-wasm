# eot-wasm

基于 WebAssembly 的 [libeot](https://github.com/umanwizard/libeot) 封装，使开发者能够直接在浏览器中将 EOT 字体转换为 TTF 格式。

[English Documentation](./README.md)

## 概述

eot-wasm 提供了一个 JavaScript/WebAssembly 库，用于在客户端完全转换 Embedded OpenType (EOT) 字体到 TrueType (TTF) 格式。这对于需要处理传统 EOT 字体而不需要服务器端处理的 Web 应用程序特别有用。

## 特性

- 完全在浏览器中将 EOT 转换为 TTF
- 不需要服务器端处理
- 简单的 JavaScript API
- 基于稳定的 libeot C 库
- 通过 Emscripten 提供完整的文件系统支持

## 安装

### 使用 npm/pnpm

```bash
pnpm add eot-wasm
```

### 直接引入脚本

```html
<script src="https://unpkg.com/eot-wasm@1.0.0/dist/eot-wasm.js"></script>
```

## 使用方法

### 基础示例

```javascript
// 加载模块
LibEOT().then(module => {
  // 创建虚拟文件系统条目
  const eotPath = '/input.eot';
  const ttfPath = '/output.ttf';
  
  // 将 EOT 数据写入虚拟文件系统
  module.FS.writeFile(eotPath, eotData); // eotData 应该是 Uint8Array 类型
  
  // 将 EOT 转换为 TTF
  const result = module.ccall(
    'convertEOTtoTTF',
    'number',
    ['string', 'string'],
    [eotPath, ttfPath]
  );
  
  if (result === 0) {
    // 读取转换后的 TTF 数据
    const ttfData = module.FS.readFile(ttfPath);
    // 使用 TTF 数据...
  }
});
```

### 完整示例

查看 [examples 目录](./examples/) 获取包含文件上传和下载功能的完整示例。

## API 参考

### 模块函数

#### `convertEOTtoTTF(eotFilePath, ttfFilePath)`

将 EOT 文件转换为 TTF 格式。

- **参数**:
  - `eotFilePath` (string): 虚拟文件系统中 EOT 文件的路径
  - `ttfFilePath` (string): 转换后的 TTF 文件应该保存的路径
- **返回值**: 整数错误代码（0 表示成功）

#### `getErrorDescription(errorCode, buffer, bufferSize)`

获取错误代码的可读描述。

- **参数**:
  - `errorCode` (number): `convertEOTtoTTF` 返回的错误代码
  - `buffer` (pointer): 错误描述将被写入的缓冲区
  - `bufferSize` (number): 缓冲区大小

### 文件系统 API

该模块通过 `module.FS` 提供对 Emscripten 虚拟文件系统的访问。主要方法包括：

- `FS.writeFile(path, data)`: 将数据写入文件
- `FS.readFile(path)`: 从文件读取数据
- `FS.unlink(path)`: 删除文件

## 从源码构建

### 前提条件

- Emscripten SDK (emsdk)
- Git

### 设置和构建步骤

1. 使用子模块克隆仓库：

```bash
git clone --recursive https://github.com/your-username/eot-wasm.git
cd eot-wasm
```

2. 如果您已经克隆了仓库但没有子模块：

```bash
git submodule update --init --recursive
```

3. 运行安装脚本以安装依赖项和 Emscripten SDK：

```bash
chmod +x setup.sh
./setup.sh
```

此脚本将：
- 检查并安装所需的构建依赖（cmake, make, python3）
- 如果尚未安装，则安装 Emscripten SDK
- 如需要，初始化 git 子模块

4. 构建 WebAssembly 模块：

```bash
chmod +x build.sh
./build.sh
# 或使用 npm/pnpm
pnpm build
```

编译后的文件将被放置在 `dist` 目录中。

## 许可证

本项目使用 MIT 许可证 - 详见 [LICENSE](./LICENSE) 文件。

## 致谢

- [libeot](https://github.com/umanwizard/libeot): 底层的 EOT 转换 C 库
