return {
	"Mofiqul/vscode.nvim",
	config = function()
		vim.o.background = "dark" -- or 'light'
		vim.cmd([[colorscheme vscode]])
	end,
}
