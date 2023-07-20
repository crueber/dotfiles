local M = {}

M.base46 = {

  n = {
    ["<leader>tt"] = {
      function()
         require("base46").toggle_transparency()
      end,
      "toggle transparency",
    },
    ["<leader><leader>"] = {"<c-^>", "toggle buffers"},
    ["<leader>tp"] = {"<cmd>Telescope projects<CR>", "Find files in project"}
  },
}

return M
