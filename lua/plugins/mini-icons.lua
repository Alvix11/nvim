return {
  "echasnovski/mini.icons",
  lazy = false, -- Cargar al arrancar para interceptar las peticiones de íconos
  opts = {
    style = "glyph",
  },
  config = function(_, opts)
    local mini_icons = require "mini.icons"
    mini_icons.setup(opts)

    -- Engaña a Neovim para que cualquier plugin que pida `nvim-web-devicons`
    -- reciba en su lugar los íconos de mini.icons:
    mini_icons.mock_nvim_web_devicons()
  end,
}
