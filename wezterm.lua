local config = require "config"
local keys = require "keys"

for k, v in pairs(keys) do
  config[k] = v
end

return config
