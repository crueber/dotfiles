local M = {}

M.base46 = {

  n = {
    ["<leader>tt"] = {
      function()
         require("base46").toggle_transparency()
      end,
      "toggle transparency",
    },
  },
}

return M
