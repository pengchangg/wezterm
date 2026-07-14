local wezterm = require "wezterm"
local config = require "config"
local keys = require "keys"

for k, v in pairs(keys) do
  config[k] = v
end

-- Compact tab titles: " 1:pwsh " instead of jammed "pwsh.exepwsh.exe"
wezterm.on("format-tab-title", function(tab, _, _, cfg, _, max_width)
  if cfg.use_fancy_tab_bar or not cfg.enable_tab_bar then
    return
  end

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

-- Left status: show active mode (COPY_MODE / SEARCH_MODE)
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
