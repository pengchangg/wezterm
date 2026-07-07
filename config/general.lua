local Icons = require "utils.class.icon"
local fs = require("utils.fn").fs

local Config = {}

if fs.platform().is_win then
  Config.default_prog =
    { "D:\\PowerShell-7.5.4-win-x64\\pwsh.exe" }
end

Config.default_cwd = fs.home()
Config.exit_behavior = "Close"

-- ref: https://wezfurlong.org/wezterm/config/lua/SshDomain.html
Config.ssh_domains = {}

-- ref: https://wezfurlong.org/wezterm/multiplexing.html#unix-domains
Config.unix_domains = {}

return Config
