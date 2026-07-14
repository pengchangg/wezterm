-- Windows 系统信息采样：CPU / 内存 / 网络上下行速率
-- 约 2 秒缓存，避免 status 刷新过频时反复启动 PowerShell

local wezterm = require "wezterm"

local M = {}

local CACHE_TTL_SEC = 1

-- 上次对外展示的文案与时间
local cached_text = "CPU --  MEM --  DOWN --  UP --"
local cached_at = 0

-- 网络差分用的上一次字节计数
local prev_rx, prev_tx, prev_net_at = nil, nil, nil
local last_down, last_up = nil, nil

local function now_sec()
  return os.time()
end

---字节速率格式化为可读字符串
local function format_rate(bytes_per_sec)
  if bytes_per_sec == nil then
    return "--"
  end
  local n = math.max(0, bytes_per_sec)
  if n < 1024 then
    return string.format("%.0fB/s", n)
  elseif n < 1024 * 1024 then
    return string.format("%.1fKB/s", n / 1024)
  else
    return string.format("%.1fMB/s", n / (1024 * 1024))
  end
end

---调用 PowerShell 取：cpu% mem% rx_bytes tx_bytes
local function sample_raw()
  local ps = table.concat({
    "$ErrorActionPreference='SilentlyContinue'",
    "$cpu = [math]::Round((Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average)",
    "$os = Get-CimInstance Win32_OperatingSystem",
    "$mem = [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) * 100 / $os.TotalVisibleMemorySize)",
    "$rx = [int64]0; $tx = [int64]0",
    "Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | ForEach-Object {",
    "  $s = Get-NetAdapterStatistics -Name $_.Name -ErrorAction SilentlyContinue",
    "  if ($s) { $rx += $s.ReceivedBytes; $tx += $s.SentBytes }",
    "}",
    "Write-Output (\"{0} {1} {2} {3}\" -f $cpu, $mem, $rx, $tx)",
  }, "; ")

  local ok, stdout, _ = wezterm.run_child_process {
    "powershell.exe",
    "-NoProfile",
    "-NonInteractive",
    "-Command",
    ps,
  }

  if not ok or not stdout then
    return nil
  end

  local cpu, mem, rx, tx = stdout:match("(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
  if not cpu then
    return nil
  end

  return {
    cpu = tonumber(cpu),
    mem = tonumber(mem),
    rx = tonumber(rx),
    tx = tonumber(tx),
  }
end

---刷新缓存并返回状态栏文案
function M.status_text()
  local t = now_sec()
  if (t - cached_at) < CACHE_TTL_SEC then
    return cached_text
  end

  local sample = sample_raw()
  if not sample then
    cached_at = t
    return cached_text
  end

  -- 计算网络速率（需要两次有效采样）
  if prev_rx and prev_tx and prev_net_at and t > prev_net_at then
    local dt = t - prev_net_at
    if dt > 0 then
      last_down = (sample.rx - prev_rx) / dt
      last_up = (sample.tx - prev_tx) / dt
      if last_down < 0 then
        last_down = 0
      end
      if last_up < 0 then
        last_up = 0
      end
    end
  end

  prev_rx, prev_tx, prev_net_at = sample.rx, sample.tx, t

  cached_text = string.format(
    "CPU %d%%  MEM %d%%  DOWN %s  UP %s",
    sample.cpu,
    sample.mem,
    format_rate(last_down),
    format_rate(last_up)
  )
  cached_at = t
  return cached_text
end

return M
