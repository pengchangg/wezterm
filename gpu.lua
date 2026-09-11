-- WebGPU 适配器选择
-- 高性能：离散显卡 > 集显 > Other > CPU
-- 低功耗：集显 > Other > 离散显卡 > CPU
-- 后端：Windows Dx12 > Vulkan > Gl；macOS Metal；其他平台 Vulkan > Gl

local wezterm = require "wezterm"
local platform = require "platform"

local BACKENDS
if platform.is_macos then
  BACKENDS = { "Metal" }
elseif platform.is_windows then
  BACKENDS = { "Dx12", "Vulkan", "Gl" }
else
  BACKENDS = { "Vulkan", "Gl" }
end

local HIGH_PERFORMANCE_PRIORITY = { "DiscreteGpu", "IntegratedGpu", "Other", "Cpu" }
local LOW_POWER_PRIORITY = { "IntegratedGpu", "Other", "DiscreteGpu", "Cpu" }

local M = {}

local function adapter_sort_key(adapter)
  return table.concat({
    adapter.name or "",
    adapter.driver or "",
    adapter.driver_info or "",
  }, "\0")
end

---按电源偏好挑选 WebGPU 适配器；找不到则返回 nil（交给 WezTerm 默认）
function M.pick_best(power_preference)
  local device_priority = power_preference == "LowPower" and LOW_POWER_PRIORITY
    or HIGH_PERFORMANCE_PRIORITY
  local adapters = wezterm.gui.enumerate_gpus()

  -- 按设备类型和后端逐级尝试，避免某一类设备后端不匹配时过早回退。
  for _, device_type in ipairs(device_priority) do
    for _, backend in ipairs(BACKENDS) do
      local candidates = {}
      for _, adapter in ipairs(adapters) do
        if adapter.device_type == device_type and adapter.backend == backend then
          candidates[#candidates + 1] = adapter
        end
      end

      if #candidates > 0 then
        table.sort(candidates, function(a, b)
          return adapter_sort_key(a) < adapter_sort_key(b)
        end)
        return candidates[1]
      end
    end
  end

  wezterm.log_error "未找到符合首选设备类型和后端的 GPU，使用默认适配器。"
  return nil
end

return M
