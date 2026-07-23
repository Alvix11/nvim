return function(_, opts)
  opts.git = { enable = true, ignore = false }
  opts.filters = { dotfiles = false }
  opts.view = { width = 40 }
end
