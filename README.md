# telescope-ui-select.nvim

It sets `vim.ui.select` to telescope. That means for example that neovim core
stuff can fill the telescope picker. Example would be
`lua vim.lsp.buf.code_action()`.

requires latest nvim 0.6 (nightly)

## Installation

```viml
Plug 'nvim-telescope/telescope-ui-select.nvim'
```


```lua
use {'nvim-telescope/telescope-ui-select.nvim' }
```

## Telescope Setup and Configuration:

```lua
-- This is your opts table
require("telescope").setup {
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown {
        -- even more opts
      }
    }
  }
}
-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require("telescope").load_extension("ui-select")
```
