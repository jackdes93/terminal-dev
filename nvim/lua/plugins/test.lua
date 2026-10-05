return {
	-- vitest adapter for TS/Vue (go + python adapters come from LazyVim lang extras)
	{
		"nvim-neotest/neotest",
		optional = true,
		dependencies = { "marilari88/neotest-vitest" },
		opts = {
			adapters = {
				["neotest-vitest"] = {},
			},
		},
	},
}
