-- WezTerm 入口：合并各模块配置，并注册事件回调
local wezterm = require "wezterm"
local config = require "config"
local keys = require "keys"

-- 将快捷键模块字段（keys / key_tables 等）合并进主配置
for k, v in pairs(keys) do
  config[k] = v
end

------------------------------------------------------------
-- 自定义标签标题：显示为「 序号:名称 」，去掉 .exe 后缀
------------------------------------------------------------
wezterm.on("format-tab-title", function(tab, _, _, cfg, _, max_width)
  if cfg.use_fancy_tab_bar or not cfg.enable_tab_bar then
    return
  end

  -- 优先使用手动设置的标签名，否则用活动窗格标题
  local title = tab.tab_title
  if not title or #title == 0 then
    title = tab.active_pane.title
  end
  title = title:gsub("%.[eE][xX][eE]$", "")

  local label = string.format(" %d:%s ", tab.tab_index + 1, title)
  return {
    { Text = wezterm.truncate_right(label, max_width) },
  }
end)

------------------------------------------------------------
-- 配置重载成功：短暂显示 RELOADED（由 update-status 绘制）
------------------------------------------------------------
wezterm.on("window-config-reloaded", function(_, _)
  local generation = (wezterm.GLOBAL.reload_generation or 0) + 1
  wezterm.GLOBAL.reload_generation = generation
  wezterm.GLOBAL.show_reloaded = true
  wezterm.time.call_after(1.5, function()
    -- 连续重载时，旧计时器不能提前清除较新的提示。
    if wezterm.GLOBAL.reload_generation == generation then
      wezterm.GLOBAL.show_reloaded = false
    end
  end)
end)

------------------------------------------------------------
-- 状态栏配色（对齐 Tokyo Night）
------------------------------------------------------------
local C = {
  reload_bg = "#9ece6a",
  reload_fg = "#1a1b26",
  battery_bg = "#414868",
  battery_good_fg = "#9ece6a",
  battery_warn_fg = "#e0af68",
  battery_low_fg = "#f7768e",
  mode_bg = "#7aa2f7",
  mode_fg = "#1a1b26",
}

local function push_seg(elements, bg, fg, text, bold)
  if bold then
    elements[#elements + 1] = { Attribute = { Intensity = "Bold" } }
  end
  elements[#elements + 1] = { Foreground = { Color = fg } }
  elements[#elements + 1] = { Background = { Color = bg } }
  elements[#elements + 1] = { Text = text }
  if bold then
    elements[#elements + 1] = { Attribute = { Intensity = "Normal" } }
  end
end

local function battery_status()
  local battery = wezterm.battery_info()[1]
  if not battery or type(battery.state_of_charge) ~= "number" then
    return nil, nil
  end

  local percent = math.max(0, math.min(100, math.floor(battery.state_of_charge * 100 + 0.5)))
  local state = battery.state or "Unknown"
  local source = (state == "Charging" or state == "Full") and "AC" or "BAT"
  local color = C.battery_good_fg
  if percent < 20 then
    color = C.battery_low_fg
  elseif percent < 50 then
    color = C.battery_warn_fg
  end
  return string.format(" %s %d%% ", source, percent), color
end

------------------------------------------------------------
-- 状态栏：左侧模式名；右侧电池状态
------------------------------------------------------------
wezterm.on("update-status", function(window, _pane)
  -- 左侧：Copy / Search 等模式
  local key_table = window:active_key_table()
  if not key_table then
    window:set_left_status ""
  else
    window:set_left_status(wezterm.format {
      { Attribute = { Intensity = "Bold" } },
      { Foreground = { Color = C.mode_fg } },
      { Background = { Color = C.mode_bg } },
      { Text = " " .. key_table:upper() .. " " },
    })
  end

  local elements = {}

  if wezterm.GLOBAL.show_reloaded then
    push_seg(elements, C.reload_bg, C.reload_fg, " RELOADED ", true)
  else
    local battery, battery_color = battery_status()
    if battery then
      push_seg(elements, C.battery_bg, battery_color, battery, true)
    end
  end

  window:set_right_status(wezterm.format(elements))
end)

return config
