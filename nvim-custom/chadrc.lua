---@type ChadrcConfig 
local M = {}
M.ui = {
  theme = 'tundra',
  nvdash = {
    load_on_startup = true
  }
}
M.mappings = require "custom.mappings"
M.plugins = "custom.plugins"
M.blankline = {
  space_char_blankline = " ",
}
return M
