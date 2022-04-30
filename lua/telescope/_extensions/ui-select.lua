return require("telescope").register_extension {
  setup = function(topts)
    local specific_opts = vim.F.if_nil(topts.specific_opts, {})
    topts.specific_opts = nil

    if #topts == 1 and topts[1] ~= nil then
      topts = topts[1]
    end

    local pickers = require "telescope.pickers"
    local finders = require "telescope.finders"
    local conf = require("telescope.config").values
    local actions = require "telescope.actions"
    local action_state = require "telescope.actions.state"
    local strings = require "plenary.strings"
    local entry_display = require "telescope.pickers.entry_display"
    local utils = require "telescope.utils"

    __TelescopeUISelectSpecificOpts = vim.F.if_nil(
      __TelescopeUISelectSpecificOpts,
      vim.tbl_extend("keep", specific_opts, {
        ["codeaction"] = {
          make_indexed = function(items)
            local indexed_items = {}
            local widths = {
              idx = 0,
              command_title = 0,
              client_name = 0,
            }
            for idx, item in ipairs(items) do
              local client = vim.lsp.get_client_by_id(item[1])
              local entry = {
                idx = idx,
                ["add"] = {
                  command_title = item[2].title:gsub("\r\n", "\\r\\n"):gsub("\n", "\\n"),
                  client_name = client and client.name or "",
                },
                text = item,
              }
              table.insert(indexed_items, entry)
              widths.idx = math.max(widths.idx, strings.strdisplaywidth(entry.idx))
              widths.command_title = math.max(widths.command_title, strings.strdisplaywidth(entry.add.command_title))
              widths.client_name = math.max(widths.client_name, strings.strdisplaywidth(entry.add.client_name))
            end
            return indexed_items, widths
          end,
          make_displayer = function(widths)
            return entry_display.create {
              separator = " ",
              items = {
                { width = widths.idx + 1 }, -- +1 for ":" suffix
                { width = widths.command_title },
                { width = widths.client_name },
              },
            }
          end,
          make_display = function(displayer)
            return function(e)
              return displayer {
                { e.value.idx .. ":", "TelescopePromptPrefix" },
                { e.value.add.command_title },
                { e.value.add.client_name, "TelescopeResultsComment" },
              }
            end
          end,
          make_ordinal = function(e)
            return e.idx .. e.add["command_title"]
          end,
        },
      })
    )

    vim.ui.select = function(items, opts, on_choice)
      opts = opts or {}
      local prompt = vim.F.if_nil(opts.prompt, "Select one of")
      if prompt:sub(-1, -1) == ":" then
        prompt = prompt:sub(1, -2)
      end
      opts.format_item = vim.F.if_nil(opts.format_item, function(e)
        return tostring(e)
      end)

      -- We want or here because __TelescopeUISelectSpecificOpts[x] can be either nil or even false -> {}
      local sopts = __TelescopeUISelectSpecificOpts[vim.F.if_nil(opts.kind, "")] or {}
      local indexed_items, widths = vim.F.if_nil(sopts.make_indexed, function(items_)
        local indexed_items = {}
        for idx, item in ipairs(items_) do
          table.insert(indexed_items, { idx = idx, text = item })
        end
        return indexed_items
      end)(items)
      local displayer = vim.F.if_nil(sopts.make_displayer, function() end)(widths)
      local make_display = vim.F.if_nil(sopts.make_display, function(_)
        return function(e)
          local x, _ = opts.format_item(e.value.text)
          return x
        end
      end)(displayer)
      local make_ordinal = vim.F.if_nil(sopts.make_ordinal, function(e)
        return opts.format_item(e.text)
      end)
      pickers.new(topts, {
        prompt_title = prompt,
        finder = finders.new_table {
          results = indexed_items,
          entry_maker = function(e)
            return {
              value = e,
              display = make_display,
              ordinal = make_ordinal(e),
            }
          end,
        },
        attach_mappings = function(prompt_bufnr)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            if selection == nil then
              utils.__warn_no_selection "ui-select"
              return
            end
            actions.close(prompt_bufnr)
            on_choice(selection.value.text, selection.value.idx)
          end)
          return true
        end,
        sorter = conf.generic_sorter(topts),
      }):find()
    end
  end,
}
