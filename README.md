![luci-app-easytier](https://socialify.git.ci/EasyTier/luci-app-easytier/image?description=1&font=JetBrains+Mono&forks=1&issues=1&logo=https%3A%2F%2Favatars.githubusercontent.com%2Fu%2F169161851%3Fs%3D200%26v%3D4&name=1&pulls=1&stargazers=1&theme=Auto)

[English](README_EN.md) | 简体中文

[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![OpenWrt](https://img.shields.io/badge/OpenWrt-18.06--26.x-orange.svg)](https://openwrt.org)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/EasyTier/luci-app-easytier)

OpenWrt LuCI界面，用于管理 [EasyTier](https://github.com/EasyTier/EasyTier) - 一个简单、安全、去中心化的内网穿透VPN组网方案。

## UI 预览

<img width="1584" height="2523" alt="image" src="https://github.com/user-attachments/assets/afa1d31b-cb97-4502-a5ac-2ada8c09f78d" />

<img width="1386" height="1758" alt="image" src="https://github.com/user-attachments/assets/c65bf3fe-5c8b-42c3-8093-96c076350846" />

## ✨ 特性

- 🎨 现代化UI设计，支持亮色/暗色主题自动切换
- 📱 完美适配移动端和桌面端
- 🌍 完整的中文/英文国际化支持
- 📊 实时流量监控和网卡状态显示
- 🔄 实时显示性能占用和版本信息
- 📦 支持压缩包和二进制文件上传
- 🔧 灵活的配置管理和备份恢复

## 📋 兼容性

### OpenWrt版本
- ✅ OpenWrt 18.06 / 18.08
- ✅ OpenWrt 19.x ~ 26.x
- ✅ 支持 IPK (22.03.x) 和 APK (SNAPSHOT) 包格式

### 架构支持
- ARM: aarch64, armv7, arm
- MIPS: mips, mipsel
- x86: x86_64

## 🚀 快速开始

### 方式一：使用预编译包

1. 从 [Releases](https://github.com/EasyTier/luci-app-easytier/releases) 下载对应架构的安装包
2. 上传到OpenWrt的 `/tmp` 目录
3. 安装：

```bash
# IPK包 (OpenWrt 22.03.x)
opkg install /tmp/luci-app-easytier_*.ipk

# APK包 (OpenWrt SNAPSHOT)
apk add --allow-untrusted /tmp/luci-app-easytier_*.apk
```

4. 刷新浏览器或重新登录LuCI界面
5. 在 **VPN → EasyTier** 中上传EasyTier二进制程序

### 方式二：GitHub Actions自动编译

1. Fork本项目
2. 修改 `.github/workflows/build.yml` 中的架构列表（可选）
3. 进入 Actions 页面，手动触发 `Build-OpenWrt-EasyTier` 工作流
4. 填写版本号（如 `v1.0.0`）和发布说明
5. 等待编译完成，在 Releases 中下载

<img width="2727" height="866" alt="image" src="https://github.com/user-attachments/assets/24a55d1c-7937-4cef-87f8-cd8778b5f009" />

### 方式三：本地编译

```bash
# 1. 下载OpenWrt SDK
wget https://downloads.openwrt.org/releases/22.03.7/targets/rockchip/armv8/openwrt-sdk-22.03.7-rockchip-armv8_gcc-11.2.0_musl.Linux-x86_64.tar.xz
tar -xJf openwrt-sdk-*.tar.xz
cd openwrt-sdk-*/

# 2. 克隆项目
git clone https://github.com/EasyTier/luci-app-easytier.git package/luci-app-easytier

# 3. 更新feeds并配置
./scripts/feeds update -a
./scripts/feeds install -a
make defconfig

# 4. 编译
make package/luci-app-easytier/compile V=s

# 5. 查找生成的ipk
find bin/ -name "luci-app-easytier*.ipk"
```

## 📦 依赖

- `kmod-tun` - TUN/TAP内核模块（必需）
- `luci-compat` - LuCI兼容层

安装前请确保已安装 `kmod-tun`：
```bash
opkg update
opkg install kmod-tun
```

## 🔧 使用说明

### 首次配置

1. 安装插件后，进入 **VPN → EasyTier**
2. 在 **上传程序** 页面上传EasyTier二进制文件或直接安装包含核心的ipk/apk包（easytier.ipk easytier.apk）
   - 支持单个文件：`easytier-core`, `easytier-cli`, `easytier-web-embed`
   - 支持压缩包：`.zip`, `.tar.gz`, `.tar`
3. 在 **EasyTier Core** 页面配置网络参数
4. 启用并保存配置

### 配置方式

支持两种配置方式：

1. **命令行参数**：通过LuCI界面配置各项参数
2. **配置文件**：使用 `/etc/easytier/config.toml` 配置文件

### 功能页面

- **状态** - 查看运行状态、版本信息、连接信息和实时流量
- **EasyTier Core** - 配置核心参数（网络名称、密钥、节点等）
- **自建控制台** - 配置easytier-web控制台
- **日志** - 查看运行日志，支持级别过滤
- **上传程序** - 上传和管理EasyTier二进制文件

## 🛠️ 开发指南

### 技术栈

- **后端**: Lua 5.1 (LuCI旧架构)
- **前端**: HTML + CSS + ES5 JavaScript
- **渲染**: 服务器端渲染 (SSR)
- **国际化**: LuCI原生i18n (.po文件)

### 开发要求

#### 兼容性原则
- ✅ 必须兼容 OpenWrt 18.06 ~ 26.x
- ✅ 使用 LuCI Lua1 架构（同时兼容Lua2）
- ❌ 禁止使用 LuCI JS框架 (view.js/form.js/rpc.js)
- ❌ 禁止使用 ES6+ 语法 (let/const/箭头函数/fetch)

#### 前端规范
```javascript
// ✅ 允许
var xhr = new XMLHttpRequest();
function handleClick() { }
document.getElementById('id');

// ❌ 禁止
const data = await fetch('/api');
let result = () => {};
import module from 'module';
```

#### 后端规范
```lua
-- ✅ 使用 Lua1 API
local http = require "luci.http"
local uci = require "luci.model.uci".cursor()
http.write_json({success = true})

-- ❌ 禁止 Lua2 特有语法
-- 不使用新版 LuCI JS API
```

#### 国际化
```lua
-- Lua中
local translate = i18n.translate
translate("Text to translate")

-- HTM模板中
<%:Text to translate%>

-- JavaScript中（由Lua注入）
var msg = '<%=translate("Text")%>';
```

### 目录结构

```
luci-app-easytier/
├── luasrc/
│   ├── controller/
│   │   └── easytier.lua          # 路由和API控制器
│   ├── model/cbi/
│   │   ├── easytier.lua          # 配置页面
│   │   └── easytier_status.lua   # 状态页面
│   └── view/easytier/
│       ├── easytier_status.htm   # 状态页面模板
│       ├── easytier_log.htm      # 日志页面
│       ├── easytier_upload.htm   # 上传页面
│       └── ...
├── root/
│   ├── etc/
│   │   ├── config/easytier       # UCI配置文件
│   │   ├── init.d/easytier       # 启动脚本
│   │   └── easytier/             # 配置目录
│   └── usr/share/easytier/
│       └── download.sh           # 下载脚本
├── po/
│   ├── zh_Hans/easytier.po       # 简体中文翻译
│   └── templates/easytier.pot    # 翻译模板
└── Makefile                      # OpenWrt包定义
```

### API设计规范

```lua
-- API路径格式
entry({"admin", "vpn", "easytier", "api_name"}, call("function_name")).leaf = true

-- 返回JSON格式
function api_name()
    luci.http.prepare_content("application/json")
    luci.http.write_json({
        success = true,
        data = {},
        message = "Success"
    })
end
```

### 提交代码

1. Fork项目并创建分支
2. 确保代码符合开发规范
3. 测试在 OpenWrt 18.06 和最新版本上的兼容性
4. 提交Pull Request

详细开发规范请参考 [开发指南](DEVELOPMENT.md)

## 🐛 故障排除

### 安装后界面不显示
```bash
# 清除LuCI缓存
rm -rf /tmp/luci-*
# 重新登录LuCI界面
```

### util.pcdata 警告
```bash
sed -i 's/util.pcdata/xml.pcdata/g' /usr/lib/lua/luci/model/cbi/easytier.lua
```

### 配置文件冲突
升级时如果提示配置文件冲突，旧配置会保留，新配置保存为 `/etc/config/easytier-opkg`，可以忽略此报错。

## 📄 许可证

本项目采用 [Apache License 2.0](LICENSE) 许可证。

## 🔗 相关链接

- [EasyTier 官方仓库](https://github.com/EasyTier/EasyTier)
- [EasyTier 官方文档](https://easytier.cn)
- [OpenWrt 官网](https://openwrt.org)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

---

