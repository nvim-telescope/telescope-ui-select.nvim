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
      opts.format_item = vim.F.if_nil(opts.format_item, function(e)
        return e
      end)
      pickers.new(topts, {
        prompt_title = vim.F.if_nil(opts.prompt, "Select one of"),
        finder = finders.new_table {
          results = items,
          entry_maker = function(e)
            return {
              value = e,
              display = opts.format_item(e),
              ordinal = opts.format_item(e),
            }
          end,
        },
        attach_mappings = function(prompt_bufnr)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry().value
            local current_picker = action_state.get_current_picker(prompt_bufnr)
            local selection_index = current_picker:get_index(current_picker:get_selection_row())
            actions.close(prompt_bufnr)
            on_choice(selection, selection_index)
          end)
          return true
        end,
        sorter = conf.generic_sorter(topts),
      }):find()
    end
  end,
}
