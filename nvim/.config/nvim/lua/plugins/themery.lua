return {
	{
		"zaldih/themery.nvim",
		lazy = false,
		config = function()
			require("themery").setup({
				themes = { "catppuccin", "tokyonight", "gruvbox", "vscode", "bluloco" },
				livePreview = true,
			})
		end,
	},
}
