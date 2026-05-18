![luci-app-easytier](https://socialify.git.ci/EasyTier/luci-app-easytier/image?custom_description=EasyTier+Installation+Packages+%28IPK+and+APK%29+for+OpenWrt&description=1&font=JetBrains+Mono&forks=1&issues=1&logo=https%3A%2F%2Favatars.githubusercontent.com%2Fu%2F169161851%3Fs%3D200%26v%3D4&name=1&pulls=1&stargazers=1&theme=Auto)

English | [简体中文](README.md)

[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![OpenWrt](https://img.shields.io/badge/OpenWrt-18.06--26.x-orange.svg)](https://openwrt.org)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/EasyTier/luci-app-easytier)

OpenWrt LuCI web interface for managing [EasyTier](https://github.com/EasyTier/EasyTier) - a simple, secure, and decentralized VPN networking solution.

## ✨ Features

- 🎨 Modern UI design with automatic light/dark theme switching
- 📱 Perfect adaptation for mobile and desktop devices
- 🌍 Full Chinese/English internationalization support
- 📊 Real-time traffic monitoring and network interface status display
- 🔄 Real-time performance metrics and version information
- 📦 Support for compressed packages and binary file uploads
- 🔧 Flexible configuration management with backup and restore

## 📋 Compatibility

### OpenWrt Versions
- ✅ OpenWrt 18.06 / 18.08
- ✅ OpenWrt 19.x ~ 26.x
- ✅ Support for IPK (22.03.x) and APK (SNAPSHOT) package formats

### Architecture Support
- ARM: aarch64, armv7, arm
- MIPS: mips, mipsel
- x86: x86_64

## 🚀 Quick Start

### Method 1: Using Pre-compiled Packages

1. Download the package for your architecture from [Releases](https://github.com/EasyTier/luci-app-easytier/releases)
2. Upload to OpenWrt's `/tmp` directory
3. Install:

```bash
# IPK package (OpenWrt 22.03.x)
opkg install /tmp/luci-app-easytier_*.ipk

# APK package (OpenWrt SNAPSHOT)
apk add --allow-untrusted /tmp/luci-app-easytier_*.apk
```

4. Refresh your browser or re-login to LuCI interface
5. Upload EasyTier binary in **VPN → EasyTier**

### Method 2: GitHub Actions Auto-build

1. Fork this repository
2. Modify the architecture list in `.github/workflows/build.yml` (optional)
3. Go to Actions page and manually trigger the `Build-OpenWrt-EasyTier` workflow
4. Enter version number (e.g., `v1.0.0`) and release notes
5. Wait for compilation to complete and download from Releases

<img width="2727" height="866" alt="image" src="https://github.com/user-attachments/assets/24a55d1c-7937-4cef-87f8-cd8778b5f009" />

### Method 3: Local Compilation

```bash
# 1. Download OpenWrt SDK
wget https://downloads.openwrt.org/releases/22.03.7/targets/rockchip/armv8/openwrt-sdk-22.03.7-rockchip-armv8_gcc-11.2.0_musl.Linux-x86_64.tar.xz
tar -xJf openwrt-sdk-*.tar.xz
cd openwrt-sdk-*/

# 2. Clone the repository
git clone https://github.com/EasyTier/luci-app-easytier.git package/luci-app-easytier

# 3. Update feeds and configure
./scripts/feeds update -a
./scripts/feeds install -a
make defconfig

# 4. Compile
make package/luci-app-easytier/compile V=s

# 5. Find the generated ipk
find bin/ -name "luci-app-easytier*.ipk"
```

## 📦 Dependencies

- `kmod-tun` - TUN/TAP kernel module (required)
- `luci-compat` - LuCI compatibility layer

Ensure `kmod-tun` is installed before installation:
```bash
opkg update
opkg install kmod-tun
```

## 🔧 Usage

### Initial Configuration

1. After installing the plugin, navigate to **VPN → EasyTier**
2. Upload EasyTier binary files on the **Upload Program** page, or directly install the ipk/apk package containing the core (easytier.ipk / easytier.apk)
   - Supports single files: `easytier-core`, `easytier-cli`, `easytier-web-embed`
   - Supports compressed packages: `.zip`, `.tar.gz`, `.tar`
3. Configure network parameters on the **EasyTier Core** page
4. Enable and save the configuration

### Configuration Methods

Two configuration methods are supported:

1. **Command-line parameters**: Configure parameters through the LuCI interface
2. **Configuration file**: Use the `/etc/easytier/config.toml` configuration file

### Function Pages

- **Status** - View running status, version info, connection info, and real-time traffic
- **EasyTier Core** - Configure core parameters (network name, secret key, nodes, etc.)
- **Self-hosted Console** - Configure easytier-web console
- **Logs** - View running logs with level filtering support
- **Upload Program** - Upload and manage EasyTier binary files

## 🛠️ Development Guide

### Tech Stack

- **Backend**: Lua 5.1 (LuCI legacy architecture)
- **Frontend**: HTML + CSS + ES5 JavaScript
- **Rendering**: Server-side rendering (SSR)
- **Internationalization**: LuCI native i18n (.po files)

### Development Requirements

#### Compatibility Principles
- ✅ Must be compatible with OpenWrt 18.06 ~ 26.x
- ✅ Use LuCI Lua1 architecture (also compatible with Lua2)
- ❌ Do not use LuCI JS framework (view.js/form.js/rpc.js)
- ❌ Do not use ES6+ syntax (let/const/arrow functions/fetch)

#### Frontend Standards
```javascript
// ✅ Allowed
var xhr = new XMLHttpRequest();
function handleClick() { }
document.getElementById('id');

// ❌ Forbidden
const data = await fetch('/api');
let result = () => {};
import module from 'module';
```

#### Backend Standards
```lua
-- ✅ Use Lua1 API
local http = require "luci.http"
local uci = require "luci.model.uci".cursor()
http.write_json({success = true})

-- ❌ Do not use Lua2-specific syntax
-- Do not use new LuCI JS API
```

#### Internationalization
```lua
-- In Lua
local translate = i18n.translate
translate("Text to translate")

-- In HTM templates
<%:Text to translate%>

-- In JavaScript (injected by Lua)
var msg = '<%=translate("Text")%>';
```

### Directory Structure

```
luci-app-easytier/
├── luasrc/
│   ├── controller/
│   │   └── easytier.lua          # Routes and API controller
│   ├── model/cbi/
│   │   ├── easytier.lua          # Configuration page
│   │   └── easytier_status.lua   # Status page
│   └── view/easytier/
│       ├── easytier_status.htm   # Status page template
│       ├── easytier_log.htm      # Log page
│       ├── easytier_upload.htm   # Upload page
│       └── ...
├── root/
│   ├── etc/
│   │   ├── config/easytier       # UCI config file
│   │   ├── init.d/easytier       # Init script
│   │   └── easytier/             # Config directory
│   └── usr/share/easytier/
│       └── download.sh           # Download script
├── po/
│   ├── zh_Hans/easytier.po       # Simplified Chinese translation
│   └── templates/easytier.pot    # Translation template
└── Makefile                      # OpenWrt package definition
```

### API Design Standards

```lua
-- API path format
entry({"admin", "vpn", "easytier", "api_name"}, call("function_name")).leaf = true

-- Return JSON format
function api_name()
    luci.http.prepare_content("application/json")
    luci.http.write_json({
        success = true,
        data = {},
        message = "Success"
    })
end
```

### Contributing Code

1. Fork the project and create a branch
2. Ensure code complies with development standards
3. Test compatibility on OpenWrt 18.06 and the latest version
4. Submit a Pull Request

## 🐛 Troubleshooting

### Interface Not Showing After Installation
```bash
# Clear LuCI cache
rm -rf /tmp/luci-*
# Re-login to LuCI interface
```

### util.pcdata Warning
```bash
sed -i 's/util.pcdata/xml.pcdata/g' /usr/lib/lua/luci/model/cbi/easytier.lua
```

### Configuration File Conflict
When upgrading, if a configuration file conflict is prompted, the old configuration will be retained and the new configuration saved as `/etc/config/easytier-opkg`. You can ignore this error.

## 📄 License

This project is licensed under the [Apache License 2.0](LICENSE).

## 🔗 Related Links

- [EasyTier Official Repository](https://github.com/EasyTier/EasyTier)
- [EasyTier Official Documentation](https://easytier.cn)
- [OpenWrt Official Website](https://openwrt.org)

## 🤝 Contributing

Issues and Pull Requests are welcome!

---
