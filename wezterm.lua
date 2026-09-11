-- WezTerm 入口：合并各模块配置，并注册事件回调
local wezterm = require "wezterm"
local config = require "config"
local keys = require "keys"
local platform = require "platform"

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
local LOCAL_HOST = wezterm.hostname():lower()

local C = {
  reload_bg = "#9ece6a",
  reload_fg = "#1a1b26",
  context_bg = "#3d59a1",
  context_fg = "#c0caf5",
  cwd_bg = "#2f3549",
  cwd_fg = "#7dcfff",
  battery_bg = "#414868",
  battery_good_fg = "#9ece6a",
  battery_warn_fg = "#e0af68",
  battery_low_fg = "#f7768e",
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

local function get_field(value, field)
  if not value then
    return nil
  end
  local ok, result = pcall(function()
    return value[field]
  end)
  return ok and result or nil
end

local function normalize_path(path)
  path = path:gsub("\\", "/"):gsub("/+$", "")
  if path == "" then
    return "/"
  end

  local home = wezterm.home_dir:gsub("\\", "/"):gsub("/+$", "")
  local compare_path = platform.is_windows and path:lower() or path
  local compare_home = platform.is_windows and home:lower() or home
  if compare_path == compare_home then
    return "~"
  end
  if compare_path:sub(1, #compare_home + 1) == compare_home .. "/" then
    return "~" .. path:sub(#home + 1)
  end
  return path
end

local function compact_path(path, depth, max_width)
  path = normalize_path(path)
  if path == "~" or path == "/" then
    return path
  end

  local home_relative = path:sub(1, 2) == "~/"
  local components = {}
  for component in path:gmatch "[^/]+" do
    components[#components + 1] = component
  end

  local first = math.max(1, #components - depth + 1)
  -- 对主目录内的路径保留 ~，它不计入目录层级。
  if home_relative then
    first = math.max(2, #components - depth + 1)
  end

  local visible = {}
  for index = first, #components do
    visible[#visible + 1] = components[index]
  end
  local result = table.concat(visible, "/")
  if home_relative then
    result = "~/" .. result
  end
  return wezterm.truncate_right(result, max_width)
end

local function pane_context(pane, depth, max_width)
  local host
  local domain_ok, domain = pcall(function()
    return pane:get_domain_name()
  end)
  if domain_ok and type(domain) == "string" and domain ~= "" and domain:lower() ~= "local" then
    host = domain
  end

  local cwd_ok, cwd = pcall(function()
    return pane:get_current_working_dir()
  end)
  if not cwd_ok or not cwd then
    return host, nil
  end

  local cwd_host = get_field(cwd, "host")
  if type(cwd_host) == "string" then
    local normalized_host = cwd_host:lower()
    if normalized_host ~= "" and normalized_host ~= "localhost"
      and normalized_host ~= "127.0.0.1" and normalized_host ~= "::1"
      and normalized_host ~= LOCAL_HOST
    then
      host = cwd_host
    end
  end

  local path = get_field(cwd, "file_path")
  if type(path) ~= "string" or path == "" then
    return host, nil
  end
  return host, compact_path(path, depth, max_width)
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
-- 状态栏：左侧模式名；右侧上下文 / 电池 / 日期时间
------------------------------------------------------------
wezterm.on("update-status", function(window, pane)
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

  local dimensions_ok, dimensions = pcall(function()
    return pane:get_dimensions()
  end)
  local columns = dimensions_ok and dimensions.cols or 80
  local wide = columns >= 110
  local medium = columns >= 80
  local elements = {}

  if wezterm.GLOBAL.show_reloaded then
    push_seg(elements, C.reload_bg, C.reload_fg, " RELOADED ", true)
  else
    if medium then
      local context, cwd = pane_context(pane, wide and 2 or 1, wide and 24 or 16)
      if wide and context then
        push_seg(elements, C.context_bg, C.context_fg, " " .. context .. " ", true)
      end
      if cwd then
        push_seg(elements, C.cwd_bg, C.cwd_fg, " " .. cwd .. " ", false)
      end
    end

    local battery, battery_color = battery_status()
    if battery then
      push_seg(elements, C.battery_bg, battery_color, battery, true)
    end
  end

  local clock_format = (wide or wezterm.GLOBAL.show_reloaded) and "%m/%d %H:%M" or "%H:%M"
  local clock = wezterm.strftime(clock_format)
  push_seg(elements, C.clock_bg, C.clock_fg, " " .. clock .. " ", true)
  window:set_right_status(wezterm.format(elements))
end)

return config
