# WezTerm 配置说明（Windows）

精简版 WezTerm 配置，面向 Windows 日常使用。默认禁用 WezTerm 自带快捷键，改用本仓库定义的绑定与 Leader 模态。

## 文件结构

```
wezterm.lua   # 入口：合并 config + keys
config.lua    # 外观、字体、标签栏、PowerShell、GPU
gpu.lua       # Windows WebGPU 适配器选择
keys.lua      # Leader、常用快捷键、模态 key tables
```

加载流程：`wezterm.lua` → `require("config")` → 合并 `require("keys")` → 返回最终配置表。

## 环境依赖

- WezTerm（建议 nightly 或较新稳定版）
- 字体：
  - **Cascadia Code NF**（主字体）
  - **Monaspace Radon**（普通斜体）
  - **Monaspace Krypton Var**（粗斜体）
  - **Symbols Nerd Font**（符号回退）
- Shell：`D:\PowerShell-7.5.4-win-x64\pwsh.exe`（可在 `config.lua` 中修改）

## 外观与行为（`config.lua`）

| 项 | 当前值 |
|----|--------|
| 配色 | `Kanagawa (Wave)`（WezTerm 内置） |
| 字号 | `12` |
| 光标 | `BlinkingBlock`，闪烁 500ms |
| 标签栏 | 底部、非 fancy、最大宽度 25 |
| 默认目录 | 用户主目录 |
| 关闭确认 | 开启；常见 shell 进程可跳过确认 |
| 渲染 | `WebGpu` |

主字体启用了 Cascadia 的若干字符变体（`cv*` / `ss*`）。斜体走 Monaspace 规则。

## GPU（`gpu.lua` + `config.lua`）

- 前端：`WebGpu`
- 适配器优先级：离散卡 → 集显 → Other → CPU
- 后端优先级（Windows）：**Dx12 → Vulkan → Gl**
- 电量低于 35% 时切换为 `LowPower`，否则 `HighPerformance`

## 快捷键（`keys.lua`）

Leader：`Alt+\`（1 秒超时）

已关闭 WezTerm 默认快捷键（`disable_default_key_bindings = true`）。

### 全局常用

| 快捷键 | 作用 |
|--------|------|
| `Ctrl+Shift+C` / `V` | 复制 / 粘贴 |
| `Ctrl+Shift+T` / `W` | 新建 / 关闭标签 |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | 下一 / 上一标签 |
| `Shift+F1`…`F24` | 切换到对应标签 |
| `Ctrl+Shift+"` | 左右分屏 |
| `Ctrl+Shift+%` | 上下分屏 |
| `Ctrl+Alt+H/J/K/L` | 窗格导航 |
| `Ctrl+Shift+Z` | 窗格缩放切换 |
| `Ctrl+Shift+F` | 搜索 |
| `Ctrl+Shift+P` | 命令面板 |
| `Ctrl+Shift+R` | 重载配置 |
| `Ctrl+Shift+N` | 新窗口 |
| `Ctrl+Shift+L` | Debug Overlay |
| `Ctrl+Shift+Space` | Quick Select |
| `Ctrl+Shift+U` | 字符选择 |
| `Alt+Enter` | 全屏 |
| `Alt+Shift+T` | Launcher（模糊搜索） |
| `PageUp` / `PageDown` | 按页滚动 |

### Leader 模态

| 快捷键 | 模式 |
|--------|------|
| `Leader+C` | Copy Mode |
| `Leader+S` | Search |
| `Leader+W` | Window Mode（分屏 / 窗格） |
| `Leader+F` | Font Mode（字号） |
| `Leader+H` | Help Mode（一次性显示常用键） |

各模式均可用 `Esc` 退出（Copy/Search 退出对应模式；Window/Font/Help 弹出 key table）。

#### Window Mode（`Leader+W`）

| 键 | 作用 |
|----|------|
| `H/J/K/L` 或方向键 | 切换窗格 |
| `V` / `S` | 左右 / 上下分屏 |
| `P` / `X` | 选择窗格 / 与当前交换 |
| `O` | 缩放切换 |
| `Q` | 关闭当前窗格 |
| `<` `>` `+` `-` | 调整窗格大小 |

#### Font Mode（`Leader+F`）

| 键 | 作用 |
|----|------|
| `+` / `-` | 增大 / 减小字号 |
| `0` | 重置字号 |

#### Copy Mode（`Leader+C`）

Vim 风格移动与选择：`HJKL`、词跳转、`V/v/Ctrl+V` 选区、`Y` 复制并退出等。

#### Search Mode（`Leader+S` 或 `Ctrl+Shift+F`）

| 键 | 作用 |
|----|------|
| `Ctrl+n` / `Ctrl+N` | 下一 / 上一匹配 |
| `Ctrl+R` | 切换匹配类型 |
| `Ctrl+U` | 清空模式 |
| 方向键 / PageUp/Down | 浏览匹配 |

## 常见修改

- **换配色**：改 `config.lua` 中 `color_scheme`（使用 WezTerm 内置方案名）
- **换 Shell**：改 `default_prog` 路径
- **换主字体**：改 `config.font` 的 `family`
- **改 Leader**：改 `keys.lua` 中 `M.leader`

修改后按 `Ctrl+Shift+R` 重载，或重启 WezTerm。

## 刻意未包含

- 运行时配色 / 字体选择器
- 自定义状态栏、标签标题格式化
- Linux / macOS 分支逻辑
