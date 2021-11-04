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
      pickers.new(topts, {
        prompt_title = opts.prompt,
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
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry().value
            on_choice(selection)
          end)
          return true
        end,
        sorter = conf.generic_sorter(topts),
      }):find()
    end
  end,
}
