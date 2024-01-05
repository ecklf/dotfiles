return {
	settings = {
		-- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
		["rust-analyzer"] = {
			imports = {
				granularity = {
					group = "module",
				},
				prefix = "self",
			},
			cargo = {
				buildScripts = {
					enable = true,
				},
				--[[ loadOutDirsFromCheck = true, ]]
				--[[ allFeatures = false, ]]
				--[[ features = { "native-tls" }, ]]
			},
			procMacro = {
				enable = true,
			},
			check = {
				--[[ enable = true, ]]
				--[[ allFeatures = false, ]]
				--[[ featureFlags = { "native-tls" }, ]]
			},
			checkOnSave = {
				command = "clippy",
			},
		},
	},
}
