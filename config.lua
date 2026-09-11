-- WezTerm 外观 / Shell / 字体 / 标签栏 / GPU 等主配置
local wezterm = require "wezterm"
local platform = require "platform"
local gpu = require "gpu"

local config = wezterm.config_builder()

local function is_string_list(value)
  if type(value) ~= "table" or #value == 0 then
    return false
  end
  for _, item in ipairs(value) do
    if type(item) ~= "string" or item == "" then
      return false
    end
  end
  return true
end

local function load_local_config()
  local path = wezterm.config_dir .. "/local.lua"
  local file = io.open(path, "r")
  if not file then
    return {}
  end
  file:close()

  local ok, overrides = pcall(dofile, path)
  if not ok then
    wezterm.log_error("加载 local.lua 失败: " .. tostring(overrides))
    return {}
  end
  if type(overrides) ~= "table" then
    wezterm.log_error "local.lua 必须返回一个配置表。"
    return {}
  end
  return overrides
end

local local_config = load_local_config()

------------------------------------------------------------
-- Shell
------------------------------------------------------------
-- Windows：从 PATH 启动 PowerShell 7；macOS：跟随系统登录 Shell
if platform.is_windows then
  config.default_prog = { "pwsh.exe" }
end
if local_config.default_prog ~= nil then
  if is_string_list(local_config.default_prog) then
    config.default_prog = local_config.default_prog
  else
    wezterm.log_error "忽略 local.lua 中无效的 default_prog，预期为非空字符串数组。"
  end
end

-- 新标签默认工作目录：用户主目录，可由 local.lua 覆盖
config.default_cwd = wezterm.home_dir
if local_config.default_cwd ~= nil then
  if type(local_config.default_cwd) == "string" and local_config.default_cwd ~= "" then
    config.default_cwd = local_config.default_cwd
  else
    wezterm.log_error "忽略 local.lua 中无效的 default_cwd，预期为非空字符串。"
  end
end
-- 进程退出后关闭窗格
config.exit_behavior = "Close"

------------------------------------------------------------
-- 启动菜单（Ctrl+Shift+S 打开，可模糊搜索）
-- label: 菜单显示名；args: 实际执行的命令参数
------------------------------------------------------------
config.launch_menu = {}

-- local.lua 中的启动项构成本机远程菜单。
if local_config.launch_menu ~= nil then
  if type(local_config.launch_menu) ~= "table" then
    wezterm.log_error "忽略 local.lua 中无效的 launch_menu，预期为数组。"
  else
    for index, item in ipairs(local_config.launch_menu) do
      if type(item) == "table" and type(item.label) == "string" and is_string_list(item.args) then
        config.launch_menu[#config.launch_menu + 1] = item
      else
        wezterm.log_error("忽略 local.lua 中无效的 launch_menu 项: " .. index)
      end
    end
  end
end

if platform.is_windows then
  -- 放在首个远程主机之后，保持既有菜单顺序；没有本机项时位于首位。
  table.insert(config.launch_menu, math.min(2, #config.launch_menu + 1), {
    label = "Wsl-Arch",
    args = { "wsl" },
  })
end

------------------------------------------------------------
-- 外观
------------------------------------------------------------
-- 配色方案（WezTerm 内置名）
config.color_scheme = "Tokyo Night"
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
-- 集成标题按钮：Windows 靠右；macOS 靠左原生风格
if platform.is_macos then
  config.integrated_title_button_alignment = "Left"
  config.integrated_title_button_style = "MacOsNative"
else
  config.integrated_title_button_alignment = "Right"
  config.integrated_title_button_style = "Windows"
end
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
if local_config.font_size ~= nil then
  if type(local_config.font_size) == "number" and local_config.font_size > 0 then
    config.font_size = local_config.font_size
  else
    wezterm.log_error "忽略 local.lua 中无效的 font_size，预期为正数。"
  end
end
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

-- 状态栏刷新间隔（毫秒），兼顾模式提示响应与刷新开销
config.status_update_interval = 500

-- Copy / Search 等组合输入时，光标高亮色
config.colors = config.colors or {}
config.colors.compose_cursor = "#DCA561"

------------------------------------------------------------
-- GPU / 渲染
------------------------------------------------------------
config.front_end = "WebGpu" -- 使用 WebGpu 前端
config.webgpu_force_fallback_adapter = false -- 不强制回退适配器

-- 电量低于 35% 时优先集显，否则优先离散显卡；配置重载后重新计算。
local battery = wezterm.battery_info()[1]
local power_preference = (battery and battery.state_of_charge < 0.35)
    and "LowPower"
  or "HighPerformance"
if local_config.webgpu_power_preference ~= nil then
  if local_config.webgpu_power_preference == "LowPower"
    or local_config.webgpu_power_preference == "HighPerformance"
  then
    power_preference = local_config.webgpu_power_preference
  else
    wezterm.log_error "忽略 local.lua 中无效的 webgpu_power_preference。"
  end
end
config.webgpu_power_preference = power_preference
config.webgpu_preferred_adapter = gpu.pick_best(power_preference)

return config
