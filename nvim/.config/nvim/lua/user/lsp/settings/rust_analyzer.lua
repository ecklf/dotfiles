return {
	settings = {
		-- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
		["rust-analyzer"] = {
			checkOnSave = {
				command = "clippy",
			},
			procMacro = {
				enable = true,
			},
			files = {
				excludeDirs = {
					"node_modules",
				},
				watcherExclude = {
					"node_modules",
				},
			},
			--[[ cargo = { ]]
			--[[   loadOutDirsFromCheck = true, ]]
			--[[ }, ]]
		},
	},
}
