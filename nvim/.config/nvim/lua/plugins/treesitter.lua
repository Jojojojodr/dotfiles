return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	dependencies = {
		"windwp/nvim-ts-autotag",
	},
	config = function()
		local languages = {
			"bash",
			"c",
			"diff",
			"html",
			"lua",
			"luadoc",
			"markdown",
			"markdown_inline",
			"query",
			"vim",
			"vimdoc",
			"go",
			"templ",
			"ruby",
			"python",
			"typescript",
			"javascript",
			"tsx",
			"css",
			"json",
			"rust",
			"dockerfile",
			"yaml",
		}

		require("nvim-treesitter").setup({})
		require("nvim-treesitter").install(languages)
		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				if not pcall(vim.treesitter.start, args.buf) then
					return
				end

				local ft = vim.bo[args.buf].filetype
				local lang = vim.treesitter.language.get_lang(ft) or ft
				local ok_query, indents = pcall(vim.treesitter.query.get, lang, "indents")
				if ok_query and indents then
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})

		require("nvim-ts-autotag").setup()
	end,
}
