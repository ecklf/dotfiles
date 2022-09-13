local status_ok, nvim_tree = pcall(require, "nvim-tree")
if not status_ok then
	return
end

local config_status_ok, nvim_tree_config = pcall(require, "nvim-tree.config")
if not config_status_ok then
	return
end

local tree_cb = nvim_tree_config.nvim_tree_callback

nvim_tree.setup({
	renderer = {
		root_folder_modifier = ":t",
		icons = {
			glyphs = {
				default = "",
				symlink = "",
				folder = {
					arrow_open = "",
					arrow_closed = "",
					default = "",
					open = "",
					empty = "",
					empty_open = "",
					symlink = "",
					symlink_open = "",
				},
				git = {
					unstaged = "",
					staged = "S",
					unmerged = "",
					renamed = "➜",
					untracked = "U",
					deleted = "",
					ignored = "◌",
				},
			},
		},
	},
	diagnostics = {
		enable = true,
		show_on_dirs = true,
		icons = {
			hint = "",
			info = "",
			warning = "",
			error = "",
		},
	},
	update_focused_file = {
		enable = true,
		--[[ update_cwd = true, ]]
		update_cwd = false,
		update_root = false,
		ignore_list = {},
	},
	actions = {
		use_system_clipboard = true,
		change_dir = {
			--[[ Change the working directory when changing directories in the tree. ]]
			--[[ enable = false, ]]
			enable = true,
			--[[ Use `:cd` instead of `:lcd` when changing directories. ]]
			global = false,
			--[[ Restrict changing to a directory above the global current working directory. ]]
			restrict_above_cwd = false,
		},
	},
	view = {
		width = 40,
		height = 30,
		-- side = "left",
		side = "right",
		mappings = {
			list = {
				{ key = { "l", "<CR>", "o" }, cb = tree_cb("edit") },
				{ key = "h", cb = tree_cb("close_node") },
				{ key = "v", cb = tree_cb("vsplit") },
			},
		},
	},
})
