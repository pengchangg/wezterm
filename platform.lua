-- 平台检测：根据 WezTerm target_triple 区分 Windows / macOS
local wezterm = require "wezterm"

local triple = wezterm.target_triple or ""

return {
  is_windows = triple:find("windows") ~= nil,
  is_macos = triple:find("apple") ~= nil or triple:find("darwin") ~= nil,
  target_triple = triple,
}
