![luci-app-easytier](https://socialify.git.ci/EasyTier/luci-app-easytier/image?description=1&font=JetBrains+Mono&forks=1&issues=1&logo=https%3A%2F%2Favatars.githubusercontent.com%2Fu%2F169161851%3Fs%3D200%26v%3D4&name=1&pulls=1&stargazers=1&theme=Auto)

# 开发指南

[English](DEVELOPMENT_EN.md) | 简体中文

本文档详细说明 luci-app-easytier 的开发规范和要求。

## 核心原则

**必须兼容 OpenWrt 18.06 ~ 26.x，使用 LuCI Lua1 架构**

## 技术栈限制

### 后端 (Lua)

#### ✅ 允许使用
- Lua 5.1 标准语法
- LuCI Lua1 API:
  - `luci.controller`
  - `luci.model.uci`
  - `luci.http`
  - `luci.sys`
  - `nixio.fs`
- 标准库: `io`, `os`, `string`, `table`, `math`

#### ❌ 禁止使用
- Lua2 特有语法
- 新版 LuCI JS API
- 任何需要额外依赖的库

### 前端 (JavaScript)

#### ✅ 允许使用
- ES5 语法
- `var` 声明变量
- `function` 关键字
- `XMLHttpRequest`
- 原生 DOM 操作
- 原生事件处理

#### ❌ 禁止使用
```javascript
// 禁止 ES6+ 语法
let x = 1;                    // ❌
const y = 2;                  // ❌
var z = () => {};             // ❌ 箭头函数
fetch('/api');                // ❌
async/await                   // ❌
import/export                 // ❌
模板字符串 `${x}`              // ❌
解构赋值                       // ❌
class 语法                     // ❌

// 禁止框架
Vue/React/Angular             // ❌
jQuery                        // ❌
任何构建工具                   // ❌
```

#### ✅ 正确示例
```javascript
var xhr = new XMLHttpRequest();
xhr.open('GET', '/api/status', true);
xhr.onload = function() {
    if (xhr.status === 200) {
        var data = JSON.parse(xhr.responseText);
        document.getElementById('status').textContent = data.status;
    }
};
xhr.send();
```

## 架构设计

### 页面渲染流程

```
用户请求 → Lua Controller → 渲染 HTM 模板 → 返回 HTML
                ↓
         初始数据注入到页面
                ↓
         JavaScript 增强交互
                ↓
         AJAX 调用 Lua API
                ↓
         更新局部 DOM
```

### 文件组织

```
controller/easytier.lua
├── index()                    # 路由注册
├── act_status()              # 状态API
├── upload_binary()           # 上传API
└── ...

view/easytier/status.htm
├── Lua 模板代码 (<%...%>)
├── HTML 结构
├── CSS 样式 (<style>)
└── JavaScript (<script>)
```

## 国际化 (i18n)

### Lua 中使用

```lua
local i18n = require "luci.i18n"
local translate = i18n.translate

-- 翻译文本
local text = translate("Hello World")
```

### HTM 模板中使用

```html
<!-- 简短语法 -->
<h1><%:Hello World%></h1>

<!-- 完整语法 -->
<p><%=translate("Welcome to EasyTier")%></p>
```

### JavaScript 中使用

```javascript
// 方式1: Lua 注入翻译
var msg = '<%=translate("Upload successful")%>';
alert(msg);

// 方式2: API 返回翻译
xhr.onload = function() {
    var response = JSON.parse(xhr.responseText);
    alert(response.message); // 后端已翻译
};
```

### 翻译文件

```po
# po/zh_Hans/easytier.po
msgid "Hello World"
msgstr "你好世界"

msgid "Upload successful"
msgstr "上传成功"
```

## API 设计

### 路由注册

```lua
-- controller/easytier.lua
function index()
    entry({"admin", "vpn", "easytier"}, firstchild(), _("EasyTier"), 46).dependent = true
    entry({"admin", "vpn", "easytier", "status"}, cbi("easytier_status"), _("Status"), 1).leaf = true
    entry({"admin", "vpn", "easytier", "api_status"}, call("act_status")).leaf = true
end
```

### API 实现

```lua
function act_status()
    local uci = require "luci.model.uci".cursor()
    
    luci.http.prepare_content("application/json")
    luci.http.write_json({
        success = true,
        running = luci.sys.call("pgrep easytier-core >/dev/null") == 0,
        version = uci:get_first("easytier", "easytier", "version")
    })
end
```

### 前端调用

```javascript
function updateStatus() {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', '/cgi-bin/luci/admin/vpn/easytier/api_status', true);
    xhr.onload = function() {
        if (xhr.status === 200) {
            var data = JSON.parse(xhr.responseText);
            if (data.success) {
                document.getElementById('status').textContent = 
                    data.running ? 'Running' : 'Stopped';
            }
        }
    };
    xhr.send();
}
```

## UCI 配置

### 读取配置

```lua
local uci = require "luci.model.uci".cursor()

-- 读取单个值
local enabled = uci:get("easytier", "@easytier[0]", "enabled")

-- 读取第一个section
local network_name = uci:get_first("easytier", "easytier", "network_name")

-- 读取列表
local peers = uci:get("easytier", "@easytier[0]", "peers") or {}
```

### 保存配置

```lua
-- 设置值
uci:set("easytier", "@easytier[0]", "enabled", "1")
uci:set("easytier", "@easytier[0]", "network_name", "mynet")

-- 设置列表
uci:delete("easytier", "@easytier[0]", "peers")
for _, peer in ipairs(peers) do
    uci:set_list("easytier", "@easytier[0]", "peers", peer)
end

-- 提交更改
uci:commit("easytier")
```

## 日志处理

### 后端实现

```lua
function get_log()
    local log_file = "/tmp/easytier.log"
    local log = ""
    
    if luci.sys.call("[ -f '" .. log_file .. "' ]") == 0 then
        -- 去除ANSI颜色代码
        log = luci.sys.exec("sed 's/\\x1b\\[[0-9;]*m//g' " .. log_file)
    end
    
    luci.http.write(log)
end
```

### 前端渲染

```javascript
function loadLog() {
    var xhr = new XMLHttpRequest();
    xhr.open('GET', '/cgi-bin/luci/admin/vpn/easytier/get_log', true);
    xhr.onload = function() {
        if (xhr.status === 200) {
            var lines = xhr.responseText.split('\n');
            var html = '';
            
            for (var i = 0; i < lines.length; i++) {
                var line = lines[i];
                var level = 'info';
                
                if (line.indexOf('ERROR') !== -1) level = 'error';
                else if (line.indexOf('WARN') !== -1) level = 'warn';
                else if (line.indexOf('DEBUG') !== -1) level = 'debug';
                
                html += '<div class="log-line log-' + level + '">' + 
                        escapeHtml(line) + '</div>';
            }
            
            document.getElementById('log_content').innerHTML = html;
        }
    };
    xhr.send();
}

function escapeHtml(text) {
    var div = document.createElement('div');
    div.appendChild(document.createTextNode(text));
    return div.innerHTML;
}
```

## UI 设计规范

### 响应式布局

```css
/* 桌面端 */
.container {
    max-width: 1200px;
    margin: 0 auto;
}

/* 移动端 */
@media (max-width: 768px) {
    .container {
        padding: 10px;
    }
    
    .grid {
        grid-template-columns: 1fr;
    }
}
```

### 主题适配

```css
:root {
    --bg-color: #ffffff;
    --text-color: #333333;
    --border-color: #e0e0e0;
}

@media (prefers-color-scheme: dark) {
    :root {
        --bg-color: #1e1e1e;
        --text-color: #e0e0e0;
        --border-color: #3e3e3e;
    }
}

.card {
    background: var(--bg-color);
    color: var(--text-color);
    border: 1px solid var(--border-color);
}
```

## 测试要求

### 兼容性测试

必须在以下环境测试：

- ✅ OpenWrt 18.06 (Lua1)
- ✅ OpenWrt 22.03 (Lua1/Lua2)
- ✅ OpenWrt SNAPSHOT (Lua2)

### 浏览器测试

- ✅ Chrome/Edge (现代浏览器)
- ✅ Firefox
- ✅ Safari (iOS)
- ✅ 移动端浏览器

### 功能测试

- [ ] 配置保存和读取
- [ ] 服务启动和停止
- [ ] 文件上传
- [ ] 日志显示
- [ ] 状态更新
- [ ] 国际化切换

## 常见问题

### Q: 为什么不使用 lua2 和 js ?
A: 无法兼容老旧版本openwrt的使用，js不适合低配置路由器。

### Q: 为什么不使用 let/const?
A: OpenWrt 18.06 的浏览器环境不支持 ES6，必须使用 ES5 语法。

### Q: 为什么不使用 Vue/React?
A: 这些框架需要构建工具，且体积大，不适合嵌入式环境。

### Q: 如何实现动态更新?
A: 使用 XMLHttpRequest + setInterval 轮询，或 WebSocket（需要额外支持）。

### Q: 如何调试?
A: 使用浏览器开发者工具，查看 Console 和 Network 标签。

## 代码审查清单

提交前请确认：

- [ ] 没有使用 ES6+ 语法
- [ ] 没有使用前端框架
- [ ] 所有文本都已国际化
- [ ] API 返回 JSON 格式
- [ ] 错误处理完善
- [ ] 代码有适当注释
- [ ] 在 OpenWrt 18.06 上测试通过
- [ ] 移动端显示正常
- [ ] 暗色主题显示正常

## 参考资源

- [LuCI Lua1 API 文档](https://github.com/openwrt/luci/wiki)
- [OpenWrt UCI 文档](https://openwrt.org/docs/guide-user/base-system/uci)
- [ES5 语法参考](https://www.ecma-international.org/ecma-262/5.1/)
