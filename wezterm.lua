-- WezTerm 入口：合并各模块配置，并注册事件回调
local wezterm = require "wezterm"
local config = require "config"
local keys = require "keys"
local gpu = require "gpu"

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
-- 配置重载成功：右侧短暂显示 RELOADED + 当前 GPU
------------------------------------------------------------
wezterm.on("window-config-reloaded", function(window, _)
  local gpu_text = gpu.status_text()
  window:set_right_status(wezterm.format {
    { Attribute = { Intensity = "Bold" } },
    { Foreground = { Color = "#1E1E2E" } },
    { Background = { Color = "#A6E3A1" } },
    { Text = " RELOADED " },
    { Foreground = { Color = "#CDD6F4" } },
    { Background = { Color = "#313244" } },
    { Text = " " .. gpu_text .. " " },
  })
  -- 约 2.5 秒后清除提示
  wezterm.time.call_after(2.5, function()
    window:set_right_status ""
  end)
end)

------------------------------------------------------------
-- 左侧状态：进入 Copy / Search 等模式时显示模式名
------------------------------------------------------------
wezterm.on("update-status", function(window, _)
  local key_table = window:active_key_table()
  if not key_table then
    window:set_left_status ""
    return
  end

  window:set_left_status(wezterm.format {
    { Attribute = { Intensity = "Bold" } },
    { Foreground = { Color = "#F2ECBC" } },
    { Background = { Color = "#4D699B" } },
    { Text = " " .. key_table:upper() .. " " },
  })
end)

return config
