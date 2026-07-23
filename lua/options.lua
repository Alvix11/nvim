require "nvchad.options"

-- add yours here!

local o = vim.o
o.relativenumber = true
o.cursorline = true
o.cursorlineopt = "both"

o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldenable = true
o.foldlevel = 99
o.foldlevelstart = 99
o.foldcolumn = "1"
