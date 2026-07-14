-- WezTerm 外观 / Shell / 字体 / 标签栏 / GPU 等主配置
local wezterm = require "wezterm"
local gpu = require "gpu"

local config = {}

------------------------------------------------------------
-- Shell（Windows）
------------------------------------------------------------
-- 默认启动程序（PowerShell 7）
config.default_prog = { "D:\\PowerShell-7.5.4-win-x64\\pwsh.exe" }
-- 新标签默认工作目录：用户主目录
config.default_cwd = wezterm.home_dir
-- 进程退出后关闭窗格
config.exit_behavior = "Close"

------------------------------------------------------------
-- 启动菜单（Ctrl+Shift+S 打开，可模糊搜索）
-- label: 菜单显示名；args: 实际执行的命令参数
------------------------------------------------------------
config.launch_menu = {
  { label = "dev205", args = { "tssh", "dev205" } },
  { label = "Wsl-Arch", args = { "wsl" } },
  { label = "jump-dev", args = { "ssh", "dev" } },
  { label = "jump-prod", args = { "ssh", "prod" } },
  { label = "rocky.home", args = { "tssh", "rocky.home" } },
}

------------------------------------------------------------
-- 外观
------------------------------------------------------------
-- 配色方案（WezTerm 内置名）
config.color_scheme = "Catppuccin Mocha"
-- 粗体同时加亮 ANSI 颜色
config.bold_brightens_ansi_colors = "BrightAndBold"
-- 显示滚动条
config.enable_scroll_bar = true
-- 打字时隐藏鼠标指针
config.hide_mouse_cursor_when_typing = true
-- 响铃：系统蜂鸣
config.audible_bell = "SystemBeep"

-- 光标闪烁动画与样式
config.cursor_blink_ease_in = "EaseIn"
config.cursor_blink_ease_out = "EaseOut"
config.cursor_blink_rate = 1000 -- 闪烁周期（毫秒）
config.default_cursor_style = "BlinkingBlock" -- 闪烁方块光标
config.cursor_thickness = 1
-- 光标处反色显示，提高对比度
config.force_reverse_video_cursor = true

-- 终端内容与窗口边缘的内边距（像素）
config.window_padding = { left = 12, right = 12, top = 10, bottom = 10 }
-- 窗口装饰：无原生标题栏，最小化/最大化/关闭并入标签栏，可调整大小
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
-- 集成标题按钮靠右，Windows 风格
config.integrated_title_button_alignment = "Right"
config.integrated_title_button_style = "Windows"
config.integrated_title_buttons = { "Hide", "Maximize", "Close" }
-- 关闭窗口时始终确认
config.window_close_confirmation = "AlwaysPrompt"
-- 这些退出码视为“干净退出”（如 Ctrl+C = 130）
config.clean_exit_codes = { 130 }
-- 以下进程退出时跳过关闭确认
config.skip_close_confirmation_for_processes_named = {
  "bash",
  "sh",
  "zsh",
  "fish",
  "tmux",
  "nu",
  "cmd.exe",
  "pwsh.exe",
  "powershell.exe",
}

------------------------------------------------------------
-- 字体
------------------------------------------------------------
-- 改字号时不自动改窗口大小
config.adjust_window_size_when_changing_font_size = false
-- 方形字形在后跟空格时允许略微溢出
config.allow_square_glyphs_to_overflow_width = "WhenFollowedBySpace"
-- 自定义方块字形抗锯齿
config.anti_alias_custom_block_glyphs = true
config.font_size = 12 -- 字号
config.line_height = 1.2 -- 行高倍率
config.underline_position = -2.5 -- 下划线垂直位置
config.underline_thickness = "2px" -- 下划线粗细
-- 缺少字形时不弹警告
config.warn_about_missing_glyphs = false

-- 主字体 + 符号回退字体
config.font = wezterm.font_with_fallback {
  {
    family = "CaskaydiaCove Nerd Font",
    weight = "Regular",
  },
  { family = "Symbols Nerd Font" },
}

------------------------------------------------------------
-- 标签栏
------------------------------------------------------------
config.enable_tab_bar = true -- 启用标签栏
-- 仅一个标签时也显示标签栏（便于拖动窗口、看状态）
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = true -- 显示「+」新建按钮
-- 序号由 format-tab-title 自定义，此处关闭内置序号
config.show_tab_index_in_tab_bar = false
config.show_tabs_in_tab_bar = true
-- 关闭标签后不自动切回上一个活动标签
config.switch_to_last_active_tab_when_closing_tab = false
-- 标签 / 分屏索引从 1 开始（非 0）
config.tab_and_split_indices_are_zero_based = false
config.tab_bar_at_bottom = false -- false = 顶部（与窗口按钮同一条）
config.tab_max_width = 18 -- 单个标签最大宽度
config.use_fancy_tab_bar = false -- 使用简洁 retro 标签栏

-- 状态栏刷新间隔（毫秒），越小模式提示越跟手
config.status_update_interval = 100

-- Copy / Search 等组合输入时，光标高亮色
config.colors = config.colors or {}
config.colors.compose_cursor = "#DCA561"

------------------------------------------------------------
-- GPU / 渲染
------------------------------------------------------------
config.front_end = "WebGpu" -- 使用 WebGpu 前端
config.webgpu_force_fallback_adapter = false -- 不强制回退适配器
-- 自动挑选较优 GPU（见 gpu.lua）
config.webgpu_preferred_adapter = gpu.pick_best()

-- 电量低于 35% 时偏向省电，否则高性能
local battery = wezterm.battery_info()[1]
config.webgpu_power_preference = (battery and battery.state_of_charge < 0.35)
    and "LowPower"
  or "HighPerformance"

return config
