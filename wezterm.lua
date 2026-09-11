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
  wezterm.GLOBAL.show_reloaded = true
  wezterm.time.call_after(1.5, function()
    wezterm.GLOBAL.show_reloaded = false
  end)
end)

------------------------------------------------------------
-- 状态栏配色（对齐 Tokyo Night）
------------------------------------------------------------
local C = {
  reload_bg = "#9ece6a",
  reload_fg = "#1a1b26",
  clock_bg = "#414868",
  clock_fg = "#c0caf5",
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

------------------------------------------------------------
-- 状态栏：左侧模式名；右侧日期时间 / 重载提示
------------------------------------------------------------
wezterm.on("update-status", function(window, _)
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

  -- 右侧：重载提示优先，否则显示日期时间
  local elements = {}
  if wezterm.GLOBAL.show_reloaded then
    push_seg(elements, C.reload_bg, C.reload_fg, " RELOADED ", true)
  else
    local clock = wezterm.strftime "%m/%d %H:%M"
    push_seg(elements, C.clock_bg, C.clock_fg, " " .. clock .. " ", true)
  end
  window:set_right_status(wezterm.format(elements))
end)

return config
