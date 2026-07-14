local act = require("wezterm").action

local M = {}

M.disable_default_key_bindings = true
M.leader = { key = "\\", mods = "ALT", timeout_milliseconds = 1000 }

M.keys = {
  { key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
  { key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
  { key = "Enter", mods = "ALT", action = act.ToggleFullScreen },
  { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo "Clipboard" },
  { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom "Clipboard" },
  { key = "f", mods = "CTRL|SHIFT", action = act.Search "CurrentSelectionOrEmptyString" },
  { key = "k", mods = "CTRL|SHIFT", action = act.ClearScrollback "ScrollbackOnly" },
  { key = "l", mods = "CTRL|SHIFT", action = act.ShowDebugOverlay },
  { key = "n", mods = "CTRL|SHIFT", action = act.SpawnWindow },
  { key = "p", mods = "CTRL|SHIFT", action = act.ActivateCommandPalette },
  { key = "r", mods = "CTRL|SHIFT", action = act.ReloadConfiguration },
  { key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab "CurrentPaneDomain" },
  {
    key = "u",
    mods = "CTRL|SHIFT",
    action = act.CharSelect {
      copy_on_select = true,
      copy_to = "ClipboardAndPrimarySelection",
    },
  },
  { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentTab { confirm = true } },
  { key = "z", mods = "CTRL|SHIFT", action = act.TogglePaneZoomState },
  { key = "PageUp", mods = "", action = act.ScrollByPage(-1) },
  { key = "PageDown", mods = "", action = act.ScrollByPage(1) },
  { key = "Insert", mods = "CTRL|SHIFT", action = act.PasteFrom "PrimarySelection" },
  { key = "Insert", mods = "CTRL", action = act.CopyTo "PrimarySelection" },
  { key = "Space", mods = "CTRL|SHIFT", action = act.QuickSelect },
  {
    key = "t",
    mods = "SHIFT|ALT",
    action = act.ShowLauncherArgs {
      title = "Search:",
      flags = "FUZZY|LAUNCH_MENU_ITEMS|DOMAINS",
    },
  },

  -- Split / pane nav
  { key = '"', mods = "CTRL|SHIFT", action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
  { key = "%", mods = "CTRL|SHIFT", action = act.SplitVertical { domain = "CurrentPaneDomain" } },
  { key = "h", mods = "CTRL|ALT", action = act.ActivatePaneDirection "Left" },
  { key = "j", mods = "CTRL|ALT", action = act.ActivatePaneDirection "Down" },
  { key = "k", mods = "CTRL|ALT", action = act.ActivatePaneDirection "Up" },
  { key = "l", mods = "CTRL|ALT", action = act.ActivatePaneDirection "Right" },

  -- Leader modes
  { key = "h", mods = "LEADER", action = act.ActivateKeyTable { name = "help_mode", one_shot = true } },
  { key = "w", mods = "LEADER", action = act.ActivateKeyTable { name = "window_mode", one_shot = false } },
  { key = "f", mods = "LEADER", action = act.ActivateKeyTable { name = "font_mode", one_shot = false } },
  { key = "c", mods = "LEADER", action = act.ActivateCopyMode },
  { key = "s", mods = "LEADER", action = act.Search "CurrentSelectionOrEmptyString" },
}

for i = 1, 24 do
  M.keys[#M.keys + 1] = {
    key = "F" .. i,
    mods = "SHIFT",
    action = act.ActivateTab(i - 1),
  }
end

M.key_tables = {
  copy_mode = {
    { key = "Escape", mods = "", action = act.CopyMode "Close" },
    {
      key = "y",
      mods = "",
      action = act.Multiple {
        { CopyTo = "ClipboardAndPrimarySelection" },
        { CopyMode = "Close" },
      },
    },
    { key = "h", mods = "", action = act.CopyMode "MoveLeft" },
    { key = "j", mods = "", action = act.CopyMode "MoveDown" },
    { key = "k", mods = "", action = act.CopyMode "MoveUp" },
    { key = "l", mods = "", action = act.CopyMode "MoveRight" },
    { key = "b", mods = "", action = act.CopyMode "MoveBackwardWord" },
    { key = "e", mods = "", action = act.CopyMode "MoveForwardWordEnd" },
    { key = "w", mods = "", action = act.CopyMode "MoveForwardWord" },
    { key = "Tab", mods = "", action = act.CopyMode "MoveForwardWord" },
    { key = "Tab", mods = "SHIFT", action = act.CopyMode "MoveBackwardWord" },
    { key = "Enter", mods = "", action = act.CopyMode "MoveToStartOfNextLine" },
    { key = "Space", mods = "", action = act.CopyMode { SetSelectionMode = "Cell" } },
    { key = "0", mods = "", action = act.CopyMode "MoveToStartOfLine" },
    { key = "$", mods = "SHIFT", action = act.CopyMode "MoveToEndOfLineContent" },
    { key = "^", mods = "", action = act.CopyMode "MoveToStartOfLineContent" },
    { key = ",", mods = "", action = act.CopyMode "JumpReverse" },
    { key = ";", mods = "", action = act.CopyMode "JumpAgain" },
    { key = "F", mods = "", action = act.CopyMode { JumpBackward = { prev_char = false } } },
    { key = "f", mods = "", action = act.CopyMode { JumpForward = { prev_char = false } } },
    { key = "T", mods = "", action = act.CopyMode { JumpBackward = { prev_char = true } } },
    { key = "t", mods = "", action = act.CopyMode { JumpForward = { prev_char = true } } },
    { key = "G", mods = "", action = act.CopyMode "MoveToScrollbackBottom" },
    { key = "g", mods = "", action = act.CopyMode "MoveToScrollbackTop" },
    { key = "H", mods = "", action = act.CopyMode "MoveToViewportTop" },
    { key = "M", mods = "", action = act.CopyMode "MoveToViewportMiddle" },
    { key = "L", mods = "", action = act.CopyMode "MoveToViewportBottom" },
    { key = "V", mods = "", action = act.CopyMode { SetSelectionMode = "Line" } },
    { key = "v", mods = "", action = act.CopyMode { SetSelectionMode = "Cell" } },
    { key = "v", mods = "CTRL", action = act.CopyMode { SetSelectionMode = "Block" } },
    { key = "O", mods = "", action = act.CopyMode "MoveToSelectionOtherEndHoriz" },
    { key = "o", mods = "", action = act.CopyMode "MoveToSelectionOtherEnd" },
    { key = "d", mods = "CTRL", action = act.CopyMode { MoveByPage = 0.5 } },
    { key = "u", mods = "CTRL", action = act.CopyMode { MoveByPage = -0.5 } },
  },

  search_mode = {
    { key = "Escape", mods = "", action = act.CopyMode "Close" },
    { key = "n", mods = "CTRL", action = act.CopyMode "NextMatch" },
    { key = "N", mods = "CTRL", action = act.CopyMode "PriorMatch" },
    { key = "r", mods = "CTRL", action = act.CopyMode "CycleMatchType" },
    { key = "u", mods = "CTRL", action = act.CopyMode "ClearPattern" },
    { key = "PageUp", mods = "", action = act.CopyMode "PriorMatchPage" },
    { key = "PageDown", mods = "", action = act.CopyMode "NextMatchPage" },
    { key = "UpArrow", mods = "", action = act.CopyMode "PriorMatch" },
    { key = "DownArrow", mods = "", action = act.CopyMode "NextMatch" },
  },

  font_mode = {
    { key = "Escape", mods = "", action = act.PopKeyTable },
    { key = "+", mods = "", action = act.IncreaseFontSize },
    { key = "-", mods = "", action = act.DecreaseFontSize },
    { key = "0", mods = "", action = act.ResetFontSize },
  },

  window_mode = {
    { key = "Escape", mods = "", action = act.PopKeyTable },
    { key = "q", mods = "", action = act.CloseCurrentPane { confirm = true } },
    { key = "h", mods = "", action = act.ActivatePaneDirection "Left" },
    { key = "j", mods = "", action = act.ActivatePaneDirection "Down" },
    { key = "k", mods = "", action = act.ActivatePaneDirection "Up" },
    { key = "l", mods = "", action = act.ActivatePaneDirection "Right" },
    { key = "v", mods = "", action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
    { key = "s", mods = "", action = act.SplitVertical { domain = "CurrentPaneDomain" } },
    { key = "p", mods = "", action = act.PaneSelect },
    { key = "x", mods = "", action = act.PaneSelect { mode = "SwapWithActive" } },
    { key = "o", mods = "", action = act.TogglePaneZoomState },
    { key = "LeftArrow", mods = "", action = act.ActivatePaneDirection "Left" },
    { key = "DownArrow", mods = "", action = act.ActivatePaneDirection "Down" },
    { key = "UpArrow", mods = "", action = act.ActivatePaneDirection "Up" },
    { key = "RightArrow", mods = "", action = act.ActivatePaneDirection "Right" },
    { key = "<", mods = "", action = act.AdjustPaneSize { "Left", 2 } },
    { key = ">", mods = "SHIFT", action = act.AdjustPaneSize { "Right", 2 } },
    { key = "+", mods = "", action = act.AdjustPaneSize { "Up", 2 } },
    { key = "-", mods = "", action = act.AdjustPaneSize { "Down", 2 } },
  },

  help_mode = {
    { key = "Escape", mods = "", action = act.PopKeyTable },
    { key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
    { key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
    { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo "Clipboard" },
    { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom "Clipboard" },
    { key = "f", mods = "CTRL|SHIFT", action = act.Search "CurrentSelectionOrEmptyString" },
    { key = "k", mods = "CTRL|SHIFT", action = act.ClearScrollback "ScrollbackOnly" },
    { key = "l", mods = "CTRL|SHIFT", action = act.ShowDebugOverlay },
    { key = "n", mods = "CTRL|SHIFT", action = act.SpawnWindow },
    { key = "p", mods = "CTRL|SHIFT", action = act.ActivateCommandPalette },
    { key = "r", mods = "CTRL|SHIFT", action = act.ReloadConfiguration },
    { key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab "CurrentPaneDomain" },
    {
      key = "u",
      mods = "CTRL|SHIFT",
      action = act.CharSelect {
        copy_on_select = true,
        copy_to = "ClipboardAndPrimarySelection",
      },
    },
    { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentTab { confirm = true } },
    { key = "z", mods = "CTRL|SHIFT", action = act.TogglePaneZoomState },
    { key = "PageUp", mods = "", action = act.ScrollByPage(-1) },
    { key = "PageDown", mods = "", action = act.ScrollByPage(1) },
    { key = "Insert", mods = "CTRL|SHIFT", action = act.PasteFrom "PrimarySelection" },
    { key = "Insert", mods = "CTRL", action = act.CopyTo "PrimarySelection" },
    { key = "Space", mods = "CTRL|SHIFT", action = act.QuickSelect },
    { key = '"', mods = "CTRL|SHIFT", action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
    { key = "%", mods = "CTRL|SHIFT", action = act.SplitVertical { domain = "CurrentPaneDomain" } },
    { key = "h", mods = "CTRL|ALT", action = act.ActivatePaneDirection "Left" },
    { key = "j", mods = "CTRL|ALT", action = act.ActivatePaneDirection "Down" },
    { key = "k", mods = "CTRL|ALT", action = act.ActivatePaneDirection "Up" },
    { key = "l", mods = "CTRL|ALT", action = act.ActivatePaneDirection "Right" },
    { key = "h", mods = "LEADER", action = act.ActivateKeyTable { name = "help_mode", one_shot = true } },
    { key = "w", mods = "LEADER", action = act.ActivateKeyTable { name = "window_mode", one_shot = false } },
    { key = "f", mods = "LEADER", action = act.ActivateKeyTable { name = "font_mode", one_shot = false } },
    { key = "c", mods = "LEADER", action = act.ActivateCopyMode },
    { key = "s", mods = "LEADER", action = act.Search "CurrentSelectionOrEmptyString" },
  },
}

return M
