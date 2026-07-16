-- 快捷键与 Copy / Search 模式键位表
local wezterm = require "wezterm"
local platform = require "platform"
local act = wezterm.action

local M = {}

-- 禁用 WezTerm 默认快捷键，仅使用本文件定义的绑定
M.disable_default_key_bindings = true

M.keys = {
  ------------------------------------------------------------
  -- 标签 / 窗口
  ------------------------------------------------------------
  { key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) }, -- 下一标签
  { key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) }, -- 上一标签
  { key = "Enter", mods = "ALT", action = act.ToggleFullScreen }, -- 全屏
  { key = "n", mods = "CTRL|SHIFT", action = act.SpawnWindow }, -- 新窗口
  { key = "t", mods = "CTRL|SHIFT", action = act.SpawnTab "CurrentPaneDomain" }, -- 新建标签
  { key = "w", mods = "CTRL|SHIFT", action = act.CloseCurrentTab { confirm = true } }, -- 关闭标签
  { key = "q", mods = "CTRL|SHIFT", action = act.CloseCurrentPane { confirm = true } }, -- 关闭窗格
  {
    key = "F2",
    mods = "",
    -- 重命名当前标签
    action = act.PromptInputLine {
      description = "Rename tab",
      action = wezterm.action_callback(function(window, _, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },

  ------------------------------------------------------------
  -- 剪贴板 / 搜索 / 选择
  ------------------------------------------------------------
  { key = "c", mods = "CTRL|SHIFT", action = act.CopyTo "Clipboard" }, -- 复制
  { key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom "Clipboard" }, -- 粘贴
  { key = "Insert", mods = "SHIFT", action = act.PasteFrom "Clipboard" }, -- 粘贴（Shift+Insert）
  { key = "f", mods = "CTRL|SHIFT", action = act.Search "CurrentSelectionOrEmptyString" }, -- 搜索
  { key = "x", mods = "CTRL|SHIFT", action = act.ActivateCopyMode }, -- Copy Mode
  { key = "Space", mods = "CTRL|SHIFT", action = act.QuickSelect }, -- 快速选择
  {
    key = "o",
    mods = "CTRL|SHIFT",
    -- 快速选择 URL 并用系统浏览器打开（纯键盘）
    action = act.QuickSelectArgs {
      label = "open url",
      patterns = {
        "https?://\\S+",
      },
      action = wezterm.action_callback(function(window, pane)
        local url = window:get_selection_text_for_pane(pane)
        wezterm.open_with(url)
      end),
    },
  },
  {
    key = "u",
    mods = "CTRL|SHIFT",
    -- 字符选择面板
    action = act.CharSelect {
      copy_on_select = true,
      copy_to = "ClipboardAndPrimarySelection",
    },
  },
  { key = "Insert", mods = "CTRL|SHIFT", action = act.PasteFrom "PrimarySelection" },
  { key = "Insert", mods = "CTRL", action = act.CopyTo "PrimarySelection" },

  ------------------------------------------------------------
  -- 杂项
  ------------------------------------------------------------
  { key = "k", mods = "CTRL|SHIFT", action = act.ClearScrollback "ScrollbackOnly" }, -- 清空回滚缓冲
  { key = "l", mods = "CTRL|SHIFT", action = act.ShowDebugOverlay }, -- 调试浮层
  { key = "p", mods = "CTRL|SHIFT", action = act.ActivateCommandPalette }, -- 命令面板
  { key = "r", mods = "CTRL|SHIFT", action = act.ReloadConfiguration }, -- 重载配置
  { key = "PageUp", mods = "", action = act.ScrollByPage(-1) }, -- 上翻一页
  { key = "PageDown", mods = "", action = act.ScrollByPage(1) }, -- 下翻一页

  ------------------------------------------------------------
  -- 启动器
  ------------------------------------------------------------
  {
    key = "s",
    mods = "CTRL|SHIFT",
    -- SSH / 远程启动菜单（读取 config.launch_menu）
    action = act.ShowLauncherArgs {
      title = "SSH",
      flags = "FUZZY|LAUNCH_MENU_ITEMS",
    },
  },
  {
    key = "t",
    mods = "SHIFT|ALT",
    -- 通用 Launcher（启动项 + 域名）
    action = act.ShowLauncherArgs {
      title = "Search:",
      flags = "FUZZY|LAUNCH_MENU_ITEMS|DOMAINS",
    },
  },

  ------------------------------------------------------------
  -- 字号
  ------------------------------------------------------------
  { key = "=", mods = "CTRL", action = act.IncreaseFontSize }, -- 增大字号
  { key = "-", mods = "CTRL", action = act.DecreaseFontSize }, -- 减小字号
  { key = "0", mods = "CTRL", action = act.ResetFontSize }, -- 重置字号

  ------------------------------------------------------------
  -- 分屏 / 窗格
  ------------------------------------------------------------
  { key = '"', mods = "CTRL|SHIFT", action = act.SplitHorizontal { domain = "CurrentPaneDomain" } }, -- 左右分屏
  { key = "%", mods = "CTRL|SHIFT", action = act.SplitVertical { domain = "CurrentPaneDomain" } }, -- 上下分屏
  { key = "h", mods = "CTRL|ALT", action = act.ActivatePaneDirection "Left" }, -- 聚焦左窗格
  { key = "j", mods = "CTRL|ALT", action = act.ActivatePaneDirection "Down" }, -- 聚焦下窗格
  { key = "k", mods = "CTRL|ALT", action = act.ActivatePaneDirection "Up" }, -- 聚焦上窗格
  { key = "l", mods = "CTRL|ALT", action = act.ActivatePaneDirection "Right" }, -- 聚焦右窗格
  { key = "e", mods = "CTRL|SHIFT", action = act.PaneSelect }, -- 可视化选窗格
  { key = "z", mods = "CTRL|SHIFT", action = act.TogglePaneZoomState }, -- 窗格放大/还原
  { key = "LeftArrow", mods = "CTRL|SHIFT", action = act.AdjustPaneSize { "Left", 2 } }, -- 向左调大小
  { key = "RightArrow", mods = "CTRL|SHIFT", action = act.AdjustPaneSize { "Right", 2 } }, -- 向右调大小
  { key = "UpArrow", mods = "CTRL|SHIFT", action = act.AdjustPaneSize { "Up", 2 } }, -- 向上调大小
  { key = "DownArrow", mods = "CTRL|SHIFT", action = act.AdjustPaneSize { "Down", 2 } }, -- 向下调大小
}

-- Shift+F1 … F24：直接跳到对应标签（从 0 起算）
for i = 1, 24 do
  M.keys[#M.keys + 1] = {
    key = "F" .. i,
    mods = "SHIFT",
    action = act.ActivateTab(i - 1),
  }
end

-- macOS：常用 Cmd（SUPER）等价绑定，与上方 Ctrl+Shift 并存
if platform.is_macos then
  local mac_keys = {
    { key = "c", mods = "SUPER", action = act.CopyTo "Clipboard" },
    { key = "v", mods = "SUPER", action = act.PasteFrom "Clipboard" },
    { key = "t", mods = "SUPER", action = act.SpawnTab "CurrentPaneDomain" },
    { key = "w", mods = "SUPER", action = act.CloseCurrentTab { confirm = true } },
    { key = "n", mods = "SUPER", action = act.SpawnWindow },
    { key = "f", mods = "SUPER", action = act.Search "CurrentSelectionOrEmptyString" },
    { key = "=", mods = "SUPER", action = act.IncreaseFontSize },
    { key = "-", mods = "SUPER", action = act.DecreaseFontSize },
    { key = "0", mods = "SUPER", action = act.ResetFontSize },
    { key = "q", mods = "SUPER", action = act.CloseCurrentPane { confirm = true } },
  }
  for _, binding in ipairs(mac_keys) do
    M.keys[#M.keys + 1] = binding
  end
end

------------------------------------------------------------
-- 鼠标：Ctrl+单击打开光标下超链接（保留默认单击打开）
------------------------------------------------------------
M.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "CTRL",
    action = act.OpenLinkAtMouseCursor,
  },
  {
    event = { Down = { streak = 1, button = "Left" } },
    mods = "CTRL",
    action = act.Nop, -- 避免 Down 仍发给 vim/tmux 等鼠标追踪程序
  },
}

-- macOS：Cmd+单击等价打开链接
if platform.is_macos then
  local mac_mouse = {
    {
      event = { Up = { streak = 1, button = "Left" } },
      mods = "SUPER",
      action = act.OpenLinkAtMouseCursor,
    },
    {
      event = { Down = { streak = 1, button = "Left" } },
      mods = "SUPER",
      action = act.Nop,
    },
  }
  for _, binding in ipairs(mac_mouse) do
    M.mouse_bindings[#M.mouse_bindings + 1] = binding
  end
end

------------------------------------------------------------
-- 模式内键位（进入 Copy / Search 后生效）
------------------------------------------------------------
M.key_tables = {
  -- Copy Mode：Vim 风格移动与选择（Ctrl+Shift+X 进入）
  copy_mode = {
    { key = "Escape", mods = "", action = act.CopyMode "Close" }, -- 退出
    {
      key = "y",
      mods = "",
      -- 复制选区并退出
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
    { key = "Space", mods = "", action = act.CopyMode { SetSelectionMode = "Cell" } }, -- 单元格选择
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
    { key = "V", mods = "", action = act.CopyMode { SetSelectionMode = "Line" } }, -- 行选
    { key = "v", mods = "", action = act.CopyMode { SetSelectionMode = "Cell" } }, -- 字符选
    { key = "v", mods = "CTRL", action = act.CopyMode { SetSelectionMode = "Block" } }, -- 块选
    { key = "O", mods = "", action = act.CopyMode "MoveToSelectionOtherEndHoriz" },
    { key = "o", mods = "", action = act.CopyMode "MoveToSelectionOtherEnd" },
    { key = "d", mods = "CTRL", action = act.CopyMode { MoveByPage = 0.5 } },
    { key = "u", mods = "CTRL", action = act.CopyMode { MoveByPage = -0.5 } },
  },

  -- Search Mode：搜索匹配导航（Ctrl+Shift+F 进入）
  search_mode = {
    { key = "Escape", mods = "", action = act.CopyMode "Close" }, -- 退出
    { key = "n", mods = "CTRL", action = act.CopyMode "NextMatch" }, -- 下一处
    { key = "N", mods = "CTRL", action = act.CopyMode "PriorMatch" }, -- 上一处
    { key = "r", mods = "CTRL", action = act.CopyMode "CycleMatchType" }, -- 切换匹配类型
    { key = "u", mods = "CTRL", action = act.CopyMode "ClearPattern" }, -- 清空搜索
    { key = "PageUp", mods = "", action = act.CopyMode "PriorMatchPage" },
    { key = "PageDown", mods = "", action = act.CopyMode "NextMatchPage" },
    { key = "UpArrow", mods = "", action = act.CopyMode "PriorMatch" },
    { key = "DownArrow", mods = "", action = act.CopyMode "NextMatch" },
  },
}

return M
