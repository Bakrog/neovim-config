return {
	"folke/trouble.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	keys = {
		{
			"<leader>tt",
			"<cmd>Trouble diagnostics toggle<cr>",
		},
		{
			"tp",
			"<cmd>Trouble diagnostics prev jump=true<cr>",
		},
		{
			"tn",
			"<cmd>Trouble diagnostics next jump=true<cr>",
		},
		{
			"tt",
			"<cmd>Trouble diagnostics toggle_preview<cr>",
		},
		{
			"qf",
			"<cmd>Trouble qflist toggle<cr>",
		},
	},

	config = function()
		local trouble = require("trouble")
		trouble.setup({
			win = {
				wo = {
					wrap = true,
				},
			},
		})
	end,
}
