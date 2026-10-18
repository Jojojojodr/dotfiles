-- Build a transparent version of the lualine theme that matches the current colorscheme
local function transparent_theme()
	package.loaded["lualine.themes.auto"] = nil
	local ok, theme = pcall(require, "lualine.themes.auto")
	if not ok or type(theme) ~= "table" then
		return "auto"
	end
	theme = vim.deepcopy(theme)

	for _, mode in pairs(theme) do
		if type(mode) == "table" then
			for section, colors in pairs(mode) do
				if type(colors) == "table" then
					-- Section "a" shows the mode as dark text on a coloured block;
					-- keep the colour by moving it to the text
					if section == "a" and colors.bg then
						colors.fg = colors.bg
						colors.gui = "bold"
					end
					colors.bg = "NONE"
				end
			end
		end
	end
	return theme
end

local function setup_lualine()
	require("lualine").setup({
		options = {
			theme = transparent_theme(),
		},
	})
end

return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		setup_lualine()

		-- Rebuild the theme whenever the colorscheme changes (Themery, :colorscheme, ...)
		vim.api.nvim_create_autocmd("ColorScheme", {
			desc = "Transparent lualine for all colorschemes",
			group = vim.api.nvim_create_augroup("transparent-lualine", { clear = true }),
			callback = function()
				vim.schedule(setup_lualine)
			end,
		})
	end,
}
