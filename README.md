# telescope-ui-select.nvim

It sets `vim.ui.select` to telescope. That means for example that neovim core
stuff can fill the telescope picker. Example would be
`lua vim.lsp.buf.code_action()`.

![screenshot](https://user-images.githubusercontent.com/66286082/154263222-ccecd75a-9b4b-410f-9843-1f300638aecf.png)

requires latest nvim 0.7 or newer nightly version

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

      -- pseudo code / specification for writing custom displays, like the one
      -- for "codeactions"
      -- specific_opts = {
      --   [kind] = {
      --     make_indexed = function(items) -> indexed_items, width,
      --     make_displayer = function(widths) -> displayer
      --     make_display = function(displayer) -> function(e)
      --     make_ordinal = function(e) -> string
      --   },
      --   -- for example to disable the custom builtin "codeactions" display
      --      do the following
      --   codeactions = false,
      -- }
    }
  }
}
-- To get ui-select loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require("telescope").load_extension("ui-select")
```
