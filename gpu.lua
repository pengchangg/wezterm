-- Windows WebGPU adapter selection (Dx12 > Vulkan > Gl, discrete preferred)

local wezterm = require "wezterm"

local BACKENDS = { "Dx12", "Vulkan", "Gl" }
local DEVICE_PRIORITY = { "DiscreteGpu", "IntegratedGpu", "Other", "Cpu" }

local M = {}

function M.pick_best()
  local by_type = {}

  for _, adapter in ipairs(wezterm.gui.enumerate_gpus()) do
    local t = adapter.device_type
    if not by_type[t] then
      by_type[t] = {}
    end
    by_type[t][adapter.backend] = adapter
  end

  local adapters
  for _, device_type in ipairs(DEVICE_PRIORITY) do
    if by_type[device_type] then
      adapters = by_type[device_type]
      break
    end
  end

  if not adapters then
    wezterm.log_error "No GPU adapters found. Using default adapter."
    return nil
  end

  for _, backend in ipairs(BACKENDS) do
    if adapters[backend] then
      return adapters[backend]
    end
  end

  wezterm.log_error "Preferred GPU backend not available. Using default adapter."
  return nil
end

return M
