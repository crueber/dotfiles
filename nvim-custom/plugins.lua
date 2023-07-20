
local plugins = {
  {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup {
        sync_root_with_cwd = true,
        respect_buf_cwd = true,
        update_focused_file = {
          enable = true,
          update_root = true
        }
      }
    end,
    init = function()
      require('telescope').load_extension('projects')
    end,
  },
}

return plugins

