require("nvchad.configs.lspconfig").defaults()

vim.lsp.config("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      check = {
        command = "clippy",
      },
    },
  },
})

local servers = { "html", "cssls", "rust_analyzer", "basedpyright", "ruff", "ts_ls", "lemminx", "lua_ls", "taplo" }
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
