require("nvchad.configs.lspconfig").defaults()

vim.lsp.config("odoo_ls", {
  cmd = {
    vim.fn.expand("$HOME/.local/share/nvim/odoo/odoo_ls_server"),
  },
  filetypes = { "python", "xml" },
  workspace_folders = {
    {
      uri = vim.uri_from_fname(vim.fn.getcwd()),
      name = "main_folder",
    },
  },
  settings = {
    Odoo = {
      selectedProfile = "main",
    },
  },
})

vim.lsp.enable({ "odoo_ls" })

local servers = { "html", "cssls", "rust_analyzer", "basedpyright", "ruff", "ts_ls", "lemminx", "lua_ls" }
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
