-- Windows WebGPU 适配器选择
-- 设备优先级：离散显卡 > 集显 > Other > CPU
-- 后端优先级：Dx12 > Vulkan > OpenGL

local wezterm = require "wezterm"

-- 可选图形后端（按偏好排序）
local BACKENDS = { "Dx12", "Vulkan", "Gl" }
-- 可选设备类型（按性能偏好排序）
local DEVICE_PRIORITY = { "DiscreteGpu", "IntegratedGpu", "Other", "Cpu" }

local M = {}

---挑选当前机器上较优的 WebGPU 适配器；找不到则返回 nil（交给 WezTerm 默认）
function M.pick_best()
  -- 按 device_type -> backend 建索引
  local by_type = {}

  for _, adapter in ipairs(wezterm.gui.enumerate_gpus()) do
    local t = adapter.device_type
    if not by_type[t] then
      by_type[t] = {}
    end
    by_type[t][adapter.backend] = adapter
  end

  -- 按设备优先级取第一档可用适配器表
  local adapters
  for _, device_type in ipairs(DEVICE_PRIORITY) do
    if by_type[device_type] then
      adapters = by_type[device_type]
      break
    end
  end

  if not adapters then
    wezterm.log_error "未找到 GPU 适配器，使用默认适配器。"
    return nil
  end

  -- 在该档设备中按后端优先级挑选
  for _, backend in ipairs(BACKENDS) do
    if adapters[backend] then
      return adapters[backend]
    end
  end

  wezterm.log_error "首选 GPU 后端不可用，使用默认适配器。"
  return nil
end

---生成状态栏用的简短 GPU 描述，例如 "Dx12|Discrete|NVIDIA GeForce RTX 3060"
function M.status_text()
  local adapter = M.pick_best()
  if not adapter then
    return "WebGpu|default"
  end

  local name = adapter.name or "?"
  -- 状态栏空间有限，截断过长设备名
  if #name > 28 then
    name = name:sub(1, 25) .. "..."
  end

  return string.format("%s|%s|%s", adapter.backend or "?", adapter.device_type or "?", name)
end

return M
