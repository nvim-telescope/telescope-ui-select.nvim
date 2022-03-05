return require("telescope").register_extension {
  setup = function(topts)
    if #topts == 1 and topts[1] ~= nil then
      topts = topts[1]
    end

    local pickers = require "telescope.pickers"
    local finders = require "telescope.finders"
    local conf = require("telescope.config").values
    local actions = require "telescope.actions"
    local action_state = require "telescope.actions.state"

    vim.ui.select = function(items, opts, on_choice)
      opts = opts or {}
      local indexed_items = {}
      for idx, item in ipairs(items) do
        table.insert(indexed_items, {index = idx, text = item})
      end
      opts.format_item = vim.F.if_nil(opts.format_item, function(e)
        return e
      end)
      pickers.new(topts, {
        prompt_title = vim.F.if_nil(opts.prompt, "Select one of"),
        finder = finders.new_table {
          results = indexed_items,
          entry_maker = function(e)
            return {
              value = e,
              display = opts.format_item(e.text),
              ordinal = opts.format_item(e.text),
            }
          end,
        },
        attach_mappings = function(prompt_bufnr)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry().value
            actions.close(prompt_bufnr)
            on_choice(selection.text, selection.index)
          end)
          return true
        end,
        sorter = conf.generic_sorter(topts),
      }):find()
    end
  end,
}
