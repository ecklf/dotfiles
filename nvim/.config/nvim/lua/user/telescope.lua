local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
  return
end

local actions = require("telescope.actions")

telescope.setup({
  defaults = {
    prompt_prefix = " ",
    selection_caret = " ",
    -- path_display = { "smart" },
    path_display = { "truncate" },
    file_ignore_patterns = { ".git/", "node_modules" },

    mappings = {
      i = {
        ["<Down>"] = actions.cycle_history_next,
        ["<Up>"] = actions.cycle_history_prev,
        ["<C-n>"] = actions.move_selection_next,
        ["<C-p>"] = actions.move_selection_previous,
        ["<C-c>"] = actions.close,
        ["<C-j>"] = actions.cycle_history_next,
        ["<C-k>"] = actions.cycle_history_prev,
        ["<CR>"] = actions.select_default,
        ["<leader>q"] = actions.send_to_qflist + actions.open_qflist,
      },
    },
  },
  vimgrep_arguments = {
    "rg",
    "--color=never",
    "--no-heading",
    "--with-filename",
    "--line-number",
    "--column",
    "--smart-case",
    "--files",
    "--hidden",
    "--glob=!.git/",
  },
  pickers = {
    find_files = {
      hidden = true,
      theme = "ivy",
    },
    live_grep = {
      additional_args = function(opts)
        return { "--hidden" }
      end,
    },
  },
  extensions = {
    fzf = {
      fuzzy = true, -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true, -- override the file sorter
      case_mode = "smart_case", -- or "ignore_case" or "respect_case"
    },
  },
})

local status_ok_fzf = pcall(require, "fzf")
if not status_ok_fzf then
  return
end

telescope.load_extension("fzf")
