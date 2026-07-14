# WezTerm 配置说明（Windows / macOS）

跨平台 WezTerm 配置：共用外观与 `Ctrl+Shift` 快捷键，通过 `platform.lua` 按系统分支处理 Shell、启动菜单、窗口按钮与 GPU。默认禁用 WezTerm 自带快捷键，改用本仓库定义的绑定。

## 文件结构

```
wezterm.lua   # 入口：合并 config + keys，标签标题与模式状态
platform.lua  # 平台检测（Windows / macOS）
config.lua    # 外观、字体、标签栏、Shell、启动菜单、GPU
gpu.lua       # WebGPU 适配器选择（按平台后端）
keys.lua      # 常用快捷键、Copy/Search 模式；macOS 额外 Cmd 绑定
```

加载流程：`wezterm.lua` → `require("config")`（内含 `platform` + `gpu`）→ 合并 `require("keys")` → 返回最终配置表。

## 平台差异（`platform.lua`）

| 项 | Windows | macOS |
|----|---------|-------|
| `default_prog` | PowerShell 7（绝对路径，见 `config.lua`） | **不设置**，跟随系统登录 Shell |
| 启动菜单 | `tssh` 主机 + `Wsl-Arch` | 仅 `tssh` 主机（无 WSL） |
| 标题按钮 | 靠右，`Windows` 风格 | 靠左，`MacOsNative` |
| GPU 后端 | Dx12 → Vulkan → Gl | Metal |
| 快捷键 | `Ctrl+Shift` 等 | 同上 + 常用 `Cmd` 等价绑定 |

## 环境依赖

- WezTerm（建议 nightly 或较新稳定版）
- 字体（两台均需安装同名家族）：
  - **CaskaydiaCove Nerd Font**（主字体）
  - **Symbols Nerd Font**（符号回退）
- Windows：`D:\PowerShell-7.5.4-win-x64\pwsh.exe`（可在 `config.lua` 中修改）；PATH 中有 `tssh` / `wsl`（启动菜单用）
- macOS：系统登录 Shell；若使用启动菜单，PATH 中需有 `tssh`

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
- 适配器优先级：离散卡 → 集显 → Other → CPU
- 后端优先级：见上方平台表
- 电量低于 35% 时切换为 `LowPower`，否则 `HighPerformance`

## 快捷键（`keys.lua`）

已关闭 WezTerm 默认快捷键（`disable_default_key_bindings = true`）。无 Leader 键。

进入 Copy / Search 时，左侧会显示 `COPY_MODE` / `SEARCH_MODE`。

标签栏右侧显示日期时间：`月/日 时:分`。重载配置成功时，短暂改为 `RELOADED`。

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
| `Ctrl+Shift+U` | 字符选择 |
| `Alt+Enter` | 全屏 |
| `Alt+Shift+T` | Launcher（模糊搜索） |
| `PageUp` / `PageDown` | 按页滚动 |

### macOS 额外（Cmd）

| 快捷键 | 作用 |
|--------|------|
| `Cmd+C` / `V` | 复制 / 粘贴 |
| `Cmd+T` / `W` | 新建 / 关闭标签 |
| `Cmd+N` | 新窗口 |
| `Cmd+F` | 搜索 |
| `Cmd+=` / `-` / `0` | 字号增大 / 减小 / 重置 |
| `Cmd+Q` | 关闭当前窗格 |

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
- **换 Windows Shell**：改 `config.lua` 中 Windows 分支的 `default_prog` 路径
- **换主字体**：改 `config.font` 的 `family`
- **改快捷键**：改 `keys.lua` 中 `M.keys`（macOS Cmd 段在文件后半）
- **增删 SSH 主机**：改 `config.lua` 中 `launch_menu`，例如 `{ label = "生产机", args = { "ssh", "prod" } }`（需本机 PATH 有对应命令）

修改后按 `Ctrl+Shift+R` 重载，或重启 WezTerm。

## 刻意未包含

- Leader / 多级模态快捷键
- 运行时配色 / 字体选择器
- Linux 专用分支（非 Windows/macOS 时走共用默认且无 `default_prog`）
- 本机 `local.lua` 覆盖（Windows pwsh 路径仍写在配置内）
