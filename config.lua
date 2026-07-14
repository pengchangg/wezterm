local wezterm = require "wezterm"
local gpu = require "gpu"

local config = {}

-- Shell (Windows)
config.default_prog = { "D:\\PowerShell-7.5.4-win-x64\\pwsh.exe" }
config.default_cwd = wezterm.home_dir
config.exit_behavior = "Close"

-- Fixed SSH / remote launch list (Ctrl+Shift+S)
config.launch_menu = {
  { label = "dev205", args = { "tssh", "dev205" } },
  { label = "Wsl-Arch", args = { "wsl" } },
  { label = "jump-dev", args = { "ssh", "dev" } },
  { label = "jump-prod", args = { "ssh", "prod" } },
  { label = "rocky.home", args = { "tssh", "rocky.home" } },
}

-- Appearance
config.color_scheme = "Catppuccin Mocha"
config.bold_brightens_ansi_colors = "BrightAndBold"
config.enable_scroll_bar = true
config.hide_mouse_cursor_when_typing = true
config.audible_bell = "SystemBeep"

config.cursor_blink_ease_in = "EaseIn"
config.cursor_blink_ease_out = "EaseOut"
config.cursor_blink_rate = 1000
config.default_cursor_style = "BlinkingBlock"
config.cursor_thickness = 1
config.force_reverse_video_cursor = true

config.window_padding = { left = 12, right = 12, top = 10, bottom = 10 }
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.integrated_title_button_alignment = "Right"
config.integrated_title_button_style = "Windows"
config.integrated_title_buttons = { "Hide", "Maximize", "Close" }
config.window_close_confirmation = "AlwaysPrompt"
config.clean_exit_codes = { 130 }
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

-- Font
config.adjust_window_size_when_changing_font_size = false
config.allow_square_glyphs_to_overflow_width = "WhenFollowedBySpace"
config.anti_alias_custom_block_glyphs = true
config.font_size = 12
config.line_height = 1.2
config.underline_position = -2.5
config.underline_thickness = "2px"
config.warn_about_missing_glyphs = false

config.font = wezterm.font_with_fallback {
  {
    family = "CaskaydiaCove Nerd Font",
    weight = "Regular",
  },
  { family = "Symbols Nerd Font" },
}

-- Tab bar
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = true
config.show_tab_index_in_tab_bar = false
config.show_tabs_in_tab_bar = true
config.switch_to_last_active_tab_when_closing_tab = false
config.tab_and_split_indices_are_zero_based = false
config.tab_bar_at_bottom = false
config.tab_max_width = 18
config.use_fancy_tab_bar = false

-- Snappy status updates so mode indicator appears quickly
config.status_update_interval = 100

-- Cursor turns orange while compose / copy-search is active
config.colors = config.colors or {}
config.colors.compose_cursor = "#DCA561"

-- GPU
config.front_end = "WebGpu"
config.webgpu_force_fallback_adapter = false
config.webgpu_preferred_adapter = gpu.pick_best()

local battery = wezterm.battery_info()[1]
config.webgpu_power_preference = (battery and battery.state_of_charge < 0.35)
    and "LowPower"
  or "HighPerformance"

return config
