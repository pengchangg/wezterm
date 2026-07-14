# WezTerm 配置说明（Windows）

精简版 WezTerm 配置，面向 Windows 日常使用。默认禁用 WezTerm 自带快捷键，改用本仓库定义的直接绑定。

## 文件结构

```
wezterm.lua   # 入口：合并 config + keys，标签标题与模式状态
config.lua    # 外观、字体、标签栏、PowerShell、GPU
gpu.lua       # Windows WebGPU 适配器选择
keys.lua      # 常用快捷键、Copy/Search 模式键位
```

加载流程：`wezterm.lua` → `require("config")` → 合并 `require("keys")` → 返回最终配置表。

## 环境依赖

- WezTerm（建议 nightly 或较新稳定版）
- 字体：
  - **CaskaydiaCove Nerd Font**（主字体）
  - **Symbols Nerd Font**（符号回退）
- Shell：`D:\PowerShell-7.5.4-win-x64\pwsh.exe`（可在 `config.lua` 中修改）

## 外观与行为（`config.lua`）

| 项 | 当前值 |
|----|--------|
| 配色 | `Catppuccin Mocha`|
| 字体 | `JetBrains Mono NF` |
| 字号 | `12.5` |
| 行高 | `1.2` |
| 光标 | `BlinkingBlock`，闪烁 500ms |
| 标签栏 | 顶部；`INTEGRATED_BUTTONS` 合并窗口按钮，无原生标题栏；非 fancy、最大宽度 18 |
| 窗口装饰 | `INTEGRATED_BUTTONS\|RESIZE`（拖动标签栏或 `Ctrl+Shift` 拖动画布） |
| 默认目录 | 用户主目录 |
| 关闭确认 | 开启；常见 shell 进程可跳过确认 |
| 渲染 | `WebGpu` |

## GPU（`gpu.lua` + `config.lua`）

- 前端：`WebGpu`
- 适配器优先级：离散卡 → 集显 → Other → CPU
- 后端优先级（Windows）：**Dx12 → Vulkan → Gl**
- 电量低于 35% 时切换为 `LowPower`，否则 `HighPerformance`

## 快捷键（`keys.lua`）

已关闭 WezTerm 默认快捷键（`disable_default_key_bindings = true`）。无 Leader 键。

进入 Copy / Search 时，左下角会显示 `COPY_MODE` / `SEARCH_MODE`。

### 全局常用

| 快捷键 | 作用 |
|--------|------|
| `Ctrl+Shift+C` / `V` | 复制 / 粘贴 |
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
| `Ctrl+Shift+R` | 重载配置（成功后标签栏右侧显示 `RELOADED` 约 2.5 秒） |
| `Ctrl+Shift+N` | 新窗口 |
| `Ctrl+Shift+L` | Debug Overlay |
| `Ctrl+Shift+Space` | Quick Select |
| `Ctrl+Shift+U` | 字符选择 |
| `Alt+Enter` | 全屏 |
| `Alt+Shift+T` | Launcher（模糊搜索） |
| `PageUp` / `PageDown` | 按页滚动 |

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
- **换 Shell**：改 `default_prog` 路径
- **换主字体**：改 `config.font` 的 `family`
- **改快捷键**：改 `keys.lua` 中 `M.keys`
- **增删 SSH 主机**：改 `config.lua` 中 `launch_menu`，例如 `{ label = "生产机", args = { "ssh", "prod" } }`（需本机 PATH 有 `ssh`）

修改后按 `Ctrl+Shift+R` 重载，或重启 WezTerm。

## 刻意未包含

- Leader / 多级模态快捷键
- 运行时配色 / 字体选择器
- Linux / macOS 分支逻辑
