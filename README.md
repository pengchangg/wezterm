# WezTerm 配置说明（Windows / macOS）

跨平台 WezTerm 配置：共用外观与 `Ctrl+Shift` 快捷键，通过 `platform.lua` 按系统分支处理 Shell、启动菜单、窗口按钮与 GPU，通过被 Git 忽略的 `local.lua` 保存本机路径和远程主机。默认禁用 WezTerm 自带快捷键，改用本仓库定义的绑定。

## 文件结构

```
wezterm.lua       # 入口：合并 config + keys，标签标题与模式状态
platform.lua      # 平台检测（Windows / macOS）
config.lua        # 外观、字体、标签栏、Shell、启动菜单、GPU
gpu.lua           # 按平台、电源偏好选择 WebGPU 适配器
keys.lua          # 常用快捷键、Copy/Search 模式；macOS 额外 Cmd 绑定
local.lua.example # 本机覆盖模板；复制为 local.lua 后使用
```

加载流程：`wezterm.lua` → `require("config")`（内含 `platform`、`gpu` 和可选的 `local.lua`）→ 合并 `require("keys")` → 返回最终配置表。

## 平台差异（`platform.lua`）

| 项 | Windows | macOS |
|----|---------|-------|
| `default_prog` | PATH 中的 PowerShell 7，可由 `local.lua` 覆盖 | **不设置**，跟随系统登录 Shell |
| 启动菜单 | `Wsl-Arch` + `local.lua` 本机启动项 | `local.lua` 本机启动项（无 WSL） |
| 标题按钮 | 靠右，`Windows` 风格 | 靠左，`MacOsNative` |
| GPU 后端 | Dx12 → Vulkan → Gl | Metal |
| 快捷键 | `Ctrl+Shift` 等 | 同上 + 常用 `Cmd` 等价绑定 |

## 环境依赖

- WezTerm（建议 nightly 或较新稳定版）
- 字体（两台均需安装同名家族）：
  - **CaskaydiaCove Nerd Font**（主字体）
  - **Symbols Nerd Font**（符号回退）
- Windows：PATH 中有 PowerShell 7 的 `pwsh.exe`；若使用 WSL 启动项，PATH 中需有 `wsl`
- Windows / macOS：若在本机启动菜单中使用 `tssh`，PATH 中需有对应命令

## 外观与行为（`config.lua`）

| 项 | 当前值 |
|----|--------|
| 配色 | `Tokyo Night` |
| 字体 | `CaskaydiaCove Nerd Font` |
| 字号 | `12` |
| 行高 | `1.2` |
| 光标 | `BlinkingBlock`，闪烁 1000ms |
| 标签栏 | 顶部；`INTEGRATED_BUTTONS` 合并窗口按钮；非 fancy、最大宽度 18 |
| 窗口装饰 | `INTEGRATED_BUTTONS\|RESIZE` |
| 默认目录 | 用户主目录 |
| 关闭确认 | 开启；常见 shell 进程可跳过确认 |
| 渲染 | `WebGpu` |

## GPU（`gpu.lua` + `config.lua`）

- 前端：`WebGpu`
- 高性能适配器优先级：离散卡 → 集显 → Other → CPU
- 低功耗适配器优先级：集显 → Other → 离散卡 → CPU
- 后端优先级：见上方平台表；Linux 等其他平台使用 Vulkan → Gl
- 加载配置时电量低于 35% 使用 `LowPower`，否则使用 `HighPerformance`
- 电量变化不会动态迁移正在使用的渲染器；重载配置或重启 WezTerm 后重新选择

## 快捷键（`keys.lua`）

已关闭 WezTerm 默认快捷键（`disable_default_key_bindings = true`）。无 Leader 键。

进入 Copy / Search 时，左侧会显示 `COPY_MODE` / `SEARCH_MODE`。

标签栏右侧按窗口宽度自适应显示：

- 宽窗口（至少 110 列）：远程上下文、当前目录最后两级、电池和完整日期时间；
- 中等窗口（80–109 列）：当前目录名、电池和时间；
- 窄窗口（少于 80 列）：电池和时间；无电池时只显示时间；
- 配置重载成功时，短暂显示 `RELOADED`，同时保留完整日期时间。

主目录会缩写为 `~`，长路径会截断。远程主机名依赖 Shell 通过 OSC 7 上报当前目录，也会尝试使用非本地 WezTerm domain；无法识别时自动省略。状态栏只读取 WezTerm API，不执行外部监控命令。

### 全局常用（两台）

| 快捷键 | 作用 |
|--------|------|
| `Ctrl+Shift+C` / `V` | 复制 / 粘贴 |
| `Shift+Insert` | 粘贴 |
| `Ctrl+Shift+T` / `W` | 新建 / 关闭标签 |
| `F2` | 重命名当前标签 |
| `Ctrl+Shift+Q` | 关闭当前窗格 |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | 下一 / 上一标签 |
| `Shift+F1`…`F24` | 切换到对应标签 |
| `Ctrl+Shift+"` | 左右分屏 |
| `Ctrl+Shift+%` | 上下分屏 |
| `Ctrl+Alt+H/J/K/L` | 窗格导航 |
| `Ctrl+Shift+方向键` | 调整窗格大小 |
| `Ctrl+Shift+E` | 选择窗格（PaneSelect） |
| `Ctrl+Shift+Z` | 窗格缩放切换 |
| `Ctrl+Shift+X` | Copy Mode |
| `Ctrl+Shift+F` | 搜索 |
| `Ctrl+Shift+S` | SSH 远程菜单（`launch_menu`） |
| `Ctrl+=` / `Ctrl+-` / `Ctrl+0` | 字号增大 / 减小 / 重置 |
| `Ctrl+Shift+P` | 命令面板 |
| `Ctrl+Shift+R` | 重载配置（成功后右侧显示 `RELOADED` 约 1.5 秒） |
| `Ctrl+Shift+N` | 新窗口 |
| `Ctrl+Shift+L` | Debug Overlay |
| `Ctrl+Shift+Space` | Quick Select |
| `Ctrl+Shift+O` | Quick Select 打开 URL（输入高亮前缀） |
| `Ctrl+Shift+U` | 字符选择 |
| `Alt+Enter` | 全屏 |
| `Alt+Shift+T` | Launcher（模糊搜索） |
| `PageUp` / `PageDown` | 按页滚动 |
| `Ctrl+单击` | 打开光标下链接（默认单击仍可打开） |

### macOS 额外（Cmd）

| 快捷键 | 作用 |
|--------|------|
| `Cmd+C` / `V` | 复制 / 粘贴 |
| `Cmd+T` / `W` | 新建 / 关闭标签 |
| `Cmd+N` | 新窗口 |
| `Cmd+F` | 搜索 |
| `Cmd+=` / `-` / `0` | 字号增大 / 减小 / 重置 |
| `Cmd+Q` | 关闭当前窗格 |
| `Cmd+单击` | 打开光标下链接 |

### Copy Mode（`Ctrl+Shift+X`）

Vim 风格移动与选择：`HJKL`、词跳转、`V/v/Ctrl+V` 选区、`Y` 复制并退出等。`Esc` 退出。

### Search Mode（`Ctrl+Shift+F`）

| 键 | 作用 |
|----|------|
| `Ctrl+n` / `Ctrl+N` | 下一 / 上一匹配 |
| `Ctrl+R` | 切换匹配类型 |
| `Ctrl+U` | 清空模式 |
| 方向键 / PageUp/Down | 浏览匹配 |
| `Esc` | 退出 |

## 常见修改

- **换配色**：改 `config.lua` 中 `color_scheme`（使用 WezTerm 内置方案名）
- **换 Windows Shell**：在 `local.lua` 中设置 `default_prog`
- **换默认目录 / 字号**：在 `local.lua` 中设置 `default_cwd` / `font_size`
- **固定 GPU 策略**：在 `local.lua` 中设置 `webgpu_power_preference` 为 `HighPerformance` 或 `LowPower`
- **换主字体**：改 `config.font` 的 `family`
- **改快捷键**：改 `keys.lua` 中 `M.keys`（macOS Cmd 段在文件后半）
- **增删 SSH 主机**：改本机 `local.lua` 中的 `launch_menu`，例如 `{ label = "生产机", args = { "ssh", "prod" } }`（需本机 PATH 有对应命令）

首次使用时可复制模板并填写本机配置：

```sh
cp local.lua.example local.lua
```

`local.lua` 支持以下白名单字段：`default_prog`、`default_cwd`、`font_size`、`webgpu_power_preference` 和 `launch_menu`。无此文件时仍可正常启动；格式错误或字段类型错误会写入 WezTerm 日志。

修改后按 `Ctrl+Shift+R` 重载，或重启 WezTerm。

## 配置验证

```sh
wezterm --config-file wezterm.lua show-keys
wezterm --config-file wezterm.lua ls-fonts
```

也可打开 Debug Overlay 检查配置日志和实际使用的 GPU。

## 刻意未包含

- Leader / 多级模态快捷键
- 运行时配色 / 字体选择器
- Linux 专用 Shell 和窗口按钮配置
- 工作区 / 项目启动器与会话恢复
