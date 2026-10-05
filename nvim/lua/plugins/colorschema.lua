return {
	-- {
	-- 	"folke/tokyonight.nvim",
	-- 	lazy = true,
	-- 	priority = 1000,
	-- 	opts = { style = "storm" },
	-- },
	{
		"craftzdog/solarized-osaka.nvim",
		lazy = true,
		priority = 1000,
		opts = function()
			return {
				transparent = true,
				on_highlights = function(hl, c)
					hl.LineNr = { fg = c.base00 }
					hl.CursorLineNr = { fg = c.yellow300 }
					hl.Comment = { fg = c.base0, italic = true }
					hl.Normal = { fg = c.base1 }
					hl.Constant = { fg = c.cyan300 }
					hl.Special = { fg = c.orange300 }
					hl.Identifier = { fg = c.blue300 }
					hl.Statement = { fg = c.green300 }
					hl.Type = { fg = c.yellow300 }
				end,
			}
		end,
	},
}
