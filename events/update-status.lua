---@diagnostic disable: undefined-field
---
---@module "events.update-status"
---@author sravioli
---@license GNU-GPLv3

-- selene: allow(incorrect_standard_library_use)
local tunpack = table.unpack or unpack

local wt = require "wezterm"
local timefmt = wt.strftime

local class, fn = require "utils.class", require "utils.fn"
local icon, sep, sb = class.icon, class.icon.Sep, class.layout:new "StatusBar"
local fs, str = fn.fs, fn.str

---@class UpdateStatusEvent
local e = {}

-- {{{1 e.__get_modes()

---Retrieves a table of available modes, each represented by a set of properties.
---Each key corresponds to a mode, and the associated value is a table containing
---information about the mode's icon, text, background color, and padding.
---
---@return UpdateStatusEvent.Modes modes mode information.
e.__get_modes = function()
  ---@class UpdateStatusEvent.Modes
  ---
  ---Each mode has the following properties:
  ---* `i` (string): The icon for the mode (eg 󰍉).
  ---* `txt` (string): The label text for the mode (eg "SEARCH").
  ---* `bg` (string): The background color for the mode.
  ---* `pad` (number): The padding value for the mode.
  ---
  ---@field search_mode table "SEARCH" mode.
  ---@field window_mode table "WINDOW" mode.
  ---@field copy_mode table "COPY" mode.
  ---@field font_mode table "FONT" mode.
  ---@field help_mode table "NORMAL" mode.
  ---@field pick_mode table "PICK" mode.
  return {
    search_mode = { i = "󰍉", txt = "SEARCH", bg = e.theme.brights[4], pad = 5 },
    window_mode = { i = "󱂬", txt = "WINDOW", bg = e.theme.ansi[6], pad = 4 },
    copy_mode = { i = "󰆏", txt = "COPY", bg = e.theme.brights[3], pad = 5 },
    font_mode = { i = "󰛖", txt = "FONT", bg = e.theme.ansi[7], pad = 4 },
    help_mode = { i = "󰞋", txt = "NORMAL", bg = e.theme.ansi[5], pad = 5 },
    pick_mode = { i = "󰢷", txt = "PICK", bg = e.theme.ansi[2], pad = 5 },
  }
end -- }}}

-- {{{1 e.__get_width(Config, pane, window)

---Retrieves the width configuration for a given pane and window.
---The function calculates the usable width based on the pane's dimensions and the
---window's width, and returns a table with various width-related properties for use in
---the interface.
---
---@param Config table UI settings.
---@param pane wt.Pane Wezterm's pane object
---@param window wt.Window Wezterm's window object
---@return UpdateStatusEvent.Width width width-related properties.
e.__get_width = function(Config, pane, window)
  local pane_dimensions = pane:get_dimensions()
  local win_width = window:get_dimensions().pixel_width

  ---@class UpdateStatusEvent.Width
  ---@field ws number workspace (0).
  ---@field mode number mode section (0).
  ---@field tabs number tab section (5).
  ---@field prompt number prompt section (0).
  ---@field usable number usable width
  ---@field new_button number new tab button, (8 if present, otherwise 0)
  return {
    ws = 0,
    mode = 0,
    tabs = 5,
    prompt = 0,
    usable = math.floor((win_width * pane_dimensions.cols) / pane_dimensions.pixel_width),
    new_button = Config.show_new_tab_button_in_tab_bar and 8 or 0,
  }
end -- }}}

-- {{{1 e.set_left_status(window)

---Updates and sets the left status bar for the given window.
---The function constructs the left status bar by checking the current mode and workspace,
---appending relevant information such as mode icon, text, workspace name, and width,
---then formats and sets it to the window's left status bar.
---
---@param window wt.Window Wezterm's window object
e.set_left_status = function(window)
  local lsb = sb:new "LeftStatusBar"

  e.mode = window:active_key_table()
  if e.mode and e.modes[e.mode] then
    local mode_fg = e.modes[e.mode].bg
    local txt, ico = e.modes[e.mode].txt or "", e.modes[e.mode].i or ""
    local indicator = str.pad(str.padr(ico) .. txt, 1)

    lsb:append(mode_fg, e.bg, indicator, { "Bold" })

    e.width.mode = str.width(indicator)
  end

  local ws = window:active_workspace()
  if ws ~= "" and not e.mode then
    local ws_bg = e.theme.brights[6]
    ws = str.pad(str.padr(icon.Workspace) .. ws)
    e.width.ws = str.width(ws) + 4

    if e.width.usable >= e.width.ws then
      lsb:append(ws_bg, e.bg, ws, { "Bold" })
    end
  end

  window:set_left_status(lsb:format())
end -- }}}

-- {{{1 e.set_modal_prompts(window)

---Constructs and sets the right status bar to display modal prompts for the given window.
---The function creates a series of prompts based on the current mode's key bindings
---and descriptions, adjusting the layout according to the available width. The status bar
---is then updated in the window.
---
---@param window wt.Window Wezterm's window object
e.set_modal_prompts = function(window)
  local rsb = sb:new "RightStatusBar"
  local prompt_bg, map_fg, txt_fg =
    e.theme.tab_bar.background, e.modes[e.mode].bg, e.theme.foreground
  local msep = sep.sb.modal

  local key_tbl = require("mappings.modes")[2][e.mode]
  for idx = 1, #key_tbl do
    local map, _, desc = tunpack(key_tbl[idx])

    if map:find "%b<>" then
      map = map:gsub("(%b<>)", function(s)
        return s:sub(2, -2)
      end)
    end

    e.width.prompt = str.width(map .. str.pad(desc)) + e.modes[e.mode].pad
    e.width.usable = e.width.usable - e.width.prompt
    if e.width.usable > 0 and desc ~= "" then
      rsb:append(prompt_bg, txt_fg, "<", { "Bold" })
      rsb:append(prompt_bg, map_fg, map)
      rsb:append(prompt_bg, txt_fg, ">")
      rsb:append(prompt_bg, txt_fg, str.pad(desc), { "Normal", "Italic" })

      local next_map, _, next_desc = tunpack(key_tbl[idx + 1] or { "", "", "" })
      local next_prompt_len = str.width(next_map .. str.pad(next_desc))
      if idx < #key_tbl and next_prompt_len < e.width.usable then
        rsb:append(prompt_bg, e.theme.brights[1], str.padr(msep, 1), { "NoItalic" })
      end
    end
  end

  window:set_right_status(rsb:format())
end -- }}}

-- {{{1 e.update_width(Config, window, pane)

---Updates the width calculations for the window and pane, factoring in various UI elements.
---The function computes the width of tabs, mode, new button, and workspace, then returns
---the remaining usable width.
---
---@param Config table The configuration settings used for formatting the tab titles.
---@param window wt.Window Wezterm's window object
---@param pane wt.Pane Wezterm's pane object
---@return number usable_width remaining usable width
e.update_width = function(Config, window, pane)
  for _ = 1, #window:mux_window():tabs() do
    local tab_title = pane:get_title()
    e.width.tabs = e.width.tabs
      + str.width(str.format_tab_title(pane, tab_title, Config, 25))
  end

  return e.width.usable - (e.width.tabs + e.width.mode + e.width.new_button + e.width.ws)
end -- }}}

-- {{{1 e.set_right_status(Config, window, pane)

---Updates and sets a compact right status bar for the given window.
---
---@param Config table configuration settings
---@param window wt.Window Wezterm's window object
---@param pane wt.Pane Wezterm's pane object
e.set_right_status = function(Config, window, pane)
  local rsb = sb:new "RightStatusBar"

  local fancy_bg = Config.window_frame.active_titlebar_bg
  local last_fg = Config.use_fancy_tab_bar and fancy_bg or e.theme.tab_bar.background
  local cwd = fs.get_cwd_hostname(pane, true)
  local cells = {
    { bg = e.theme.ansi[5], fg = last_fg, text = fs.pathshortener(cwd, 3) .. str.padl(icon.Folder) },
    { bg = e.theme.ansi[4], fg = e.theme.ansi[5], text = timefmt "%H:%M" .. str.padl(icon.Clock[timefmt "%I"]) },
  }

  for i = 1, #cells do
    local cell = cells[i]
    rsb:append(cell.fg, cell.bg, sep.sb.right)
    rsb:append(cell.bg, e.theme.tab_bar.background, str.pad(cell.text), { "Bold" })
  end

  window:set_right_status(rsb:format())
end -- }}}

---Update status event
---@param window wt.Window Wezterm's window object
---@param pane   wt.Pane   Wezterm's pane object
wt.on("update-status", function(window, pane)
  local Config, Overrides = window:effective_config(), window:get_config_overrides() or {}
  e.theme = Config.color_schemes[Overrides.color_scheme or Config.color_scheme]
  e.bg, e.fg = e.theme.background, e.theme.ansi[5]

  e.modes = e.__get_modes()
  e.width = e.__get_width(Config, pane, window)

  e.set_left_status(window)

  e.width.usable = e.update_width(Config, window, pane)

  if e.mode and e.modes[e.mode] then
    e.set_modal_prompts(window)
    return -- return early to not render the status-bar
  end

  e.set_right_status(Config, window, pane)
end)

-- vim: fdm=marker fdl=1
