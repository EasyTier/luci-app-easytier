![luci-app-easytier](https://socialify.git.ci/EasyTier/luci-app-easytier/image?custom_description=EasyTier+Installation+Packages+%28IPK+and+APK%29+for+OpenWrt&description=1&font=JetBrains+Mono&forks=1&issues=1&logo=https%3A%2F%2Favatars.githubusercontent.com%2Fu%2F169161851%3Fs%3D200%26v%3D4&name=1&pulls=1&stargazers=1&theme=Auto)

# Development Guide

English | [简体中文](DEVELOPMENT.md)

This document details the development standards and requirements for luci-app-easytier.

## Core Principles

**Must be compatible with OpenWrt 18.06 ~ 26.x, using LuCI Lua1 architecture**

## Technology Stack Restrictions

### Backend (Lua)

#### ✅ Allowed
- Lua 5.1 standard syntax
- LuCI Lua1 API:
  - `luci.controller`
  - `luci.model.uci`
  - `luci.http`
  - `luci.sys`
  - `nixio.fs`
- Standard libraries: `io`, `os`, `string`, `table`, `math`

#### ❌ Forbidden
- Lua2-specific syntax
- New LuCI JS API
- Any libraries requiring additional dependencies

### Frontend (JavaScript)

#### ✅ Allowed
- ES5 syntax
- `var` declarations
- `function` keyword
- `XMLHttpRequest`
- Native DOM manipulation
- Native event handling

#### ❌ Forbidden
```javascript
// Forbidden ES6+ syntax
let x = 1;                    // ❌
const y = 2;                  // ❌
var z = () => {};             // ❌ Arrow functions
fetch('/api');                // ❌
async/await                   // ❌
import/export                 // ❌
Template literals `${x}`      // ❌
Destructuring                 // ❌
class syntax                  // ❌

// Forbidden frameworks
Vue/React/Angular             // ❌
jQuery                        // ❌
Any build tools               // ❌
```

#### ✅ Correct Example
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

## Architecture Design

### Page Rendering Flow

```
User Request → Lua Controller → Render HTM Template → Return HTML
                ↓
         Inject initial data into page
                ↓
         JavaScript enhances interaction
                ↓
         AJAX calls Lua API
                ↓
         Update partial DOM
```

### File Organization

```
controller/easytier.lua
├── index()                    # Route registration
├── act_status()              # Status API
├── upload_binary()           # Upload API
└── ...

view/easytier/status.htm
├── Lua template code (<%...%>)
├── HTML structure
├── CSS styles (<style>)
└── JavaScript (<script>)
```

## Internationalization (i18n)

### Usage in Lua

```lua
local i18n = require "luci.i18n"
local translate = i18n.translate

-- Translate text
local text = translate("Hello World")
```

### Usage in HTM Templates

```html
<!-- Short syntax -->
<h1><%:Hello World%></h1>

<!-- Full syntax -->
<p><%=translate("Welcome to EasyTier")%></p>
```

### Usage in JavaScript

```javascript
// Method 1: Lua injects translation
var msg = '<%=translate("Upload successful")%>';
alert(msg);

// Method 2: API returns translation
xhr.onload = function() {
    var response = JSON.parse(xhr.responseText);
    alert(response.message); // Already translated by backend
};
```

### Translation Files

```po
# po/zh_Hans/easytier.po
msgid "Hello World"
msgstr "你好世界"

msgid "Upload successful"
msgstr "上传成功"
```

## API Design

### Route Registration

```lua
-- controller/easytier.lua
function index()
    entry({"admin", "vpn", "easytier"}, firstchild(), _("EasyTier"), 46).dependent = true
    entry({"admin", "vpn", "easytier", "status"}, cbi("easytier_status"), _("Status"), 1).leaf = true
    entry({"admin", "vpn", "easytier", "api_status"}, call("act_status")).leaf = true
end
```

### API Implementation

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

### Frontend Invocation

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

## UCI Configuration

### Reading Configuration

```lua
local uci = require "luci.model.uci".cursor()

-- Read single value
local enabled = uci:get("easytier", "@easytier[0]", "enabled")

-- Read first section
local network_name = uci:get_first("easytier", "easytier", "network_name")

-- Read list
local peers = uci:get("easytier", "@easytier[0]", "peers") or {}
```

### Saving Configuration

```lua
-- Set value
uci:set("easytier", "@easytier[0]", "enabled", "1")
uci:set("easytier", "@easytier[0]", "network_name", "mynet")

-- Set list
uci:delete("easytier", "@easytier[0]", "peers")
for _, peer in ipairs(peers) do
    uci:set_list("easytier", "@easytier[0]", "peers", peer)
end

-- Commit changes
uci:commit("easytier")
```

## Log Handling

### Backend Implementation

```lua
function get_log()
    local log_file = "/tmp/easytier.log"
    local log = ""
    
    if luci.sys.call("[ -f '" .. log_file .. "' ]") == 0 then
        -- Remove ANSI color codes
        log = luci.sys.exec("sed 's/\\x1b\\[[0-9;]*m//g' " .. log_file)
    end
    
    luci.http.write(log)
end
```

### Frontend Rendering

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

## UI Design Standards

### Responsive Layout

```css
/* Desktop */
.container {
    max-width: 1200px;
    margin: 0 auto;
}

/* Mobile */
@media (max-width: 768px) {
    .container {
        padding: 10px;
    }
    
    .grid {
        grid-template-columns: 1fr;
    }
}
```

### Theme Adaptation

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

## Testing Requirements

### Compatibility Testing

Must be tested on the following environments:

- ✅ OpenWrt 18.06 (Lua1)
- ✅ OpenWrt 22.03 (Lua1/Lua2)
- ✅ OpenWrt SNAPSHOT (Lua2)

### Browser Testing

- ✅ Chrome/Edge (modern browsers)
- ✅ Firefox
- ✅ Safari (iOS)
- ✅ Mobile browsers

### Functional Testing

- [ ] Configuration save and load
- [ ] Service start and stop
- [ ] File upload
- [ ] Log display
- [ ] Status updates
- [ ] Internationalization switching

## FAQ

### Q: Why can't I use let/const?
A: The browser environment in OpenWrt 18.06 doesn't support ES6; ES5 syntax must be used.

### Q: Why not use Lua2 and JS frameworks?
A: Cannot be compatible with older versions of OpenWrt, and JS frameworks are not suitable for low-spec routers.

### Q: Why can't I use Vue/React?
A: These frameworks require build tools and have large file sizes, unsuitable for embedded environments.

### Q: How to implement dynamic updates?
A: Use XMLHttpRequest + setInterval polling, or WebSocket (requires additional support).

### Q: How to debug?
A: Use browser developer tools, check Console and Network tabs.

## Code Review Checklist

Before submitting, please confirm:

- [ ] No ES6+ syntax used
- [ ] No frontend frameworks used
- [ ] All text is internationalized
- [ ] APIs return JSON format
- [ ] Error handling is complete
- [ ] Code has appropriate comments
- [ ] Tested on OpenWrt 18.06
- [ ] Mobile display is normal
- [ ] Dark theme display is normal

## Reference Resources

- [LuCI Lua1 API Documentation](https://github.com/openwrt/luci/wiki)
- [OpenWrt UCI Documentation](https://openwrt.org/docs/guide-user/base-system/uci)
- [ES5 Syntax Reference](https://www.ecma-international.org/ecma-262/5.1/)
