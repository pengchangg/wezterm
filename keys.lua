-- 快捷键与 Copy / Search 模式键位表
local wezterm = require "wezterm"
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
