-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Make the background transparent for every colorscheme
--  Runs after any colorscheme is applied (startup, Themery, :colorscheme, etc.)
local function make_transparent()
	local groups = {
		"Normal",
		"NormalNC",
		"NormalFloat",
		"FloatBorder",
		"FloatTitle",
		"SignColumn",
		"FoldColumn",
		"LineNr",
		"CursorLine",
		"CursorLineNr",
		"EndOfBuffer",
		"MsgArea",
		"StatusLine",
		"StatusLineNC",
		"TabLine",
		"TabLineFill",
		"WinBar",
		"WinBarNC",
		"WinSeparator",
		"VertSplit",
		"Pmenu",
		"TelescopeNormal",
		"TelescopeBorder",
		"TelescopePromptNormal",
		"TelescopePromptBorder",
		"TelescopeResultsNormal",
		"TelescopeResultsBorder",
		"TelescopePreviewNormal",
		"TelescopePreviewBorder",
		"NeoTreeNormal",
		"NeoTreeNormalNC",
		"NeoTreeEndOfBuffer",
		"NeoTreeCursorLine",
		"WhichKeyFloat",
		"WhichKeyNormal",
		"GitSignsAdd",
		"GitSignsChange",
		"GitSignsDelete",
	}
	for _, name in ipairs(groups) do
		local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
		if ok then
			hl.bg = nil
			hl.ctermbg = nil
			vim.api.nvim_set_hl(0, name, hl)
		end
	end

	-- Some themes give Neo-tree's own groups a background (indent markers, expanders, dim text, ...)
	for name, hl in pairs(vim.api.nvim_get_hl(0, {})) do
		if name:match("^NeoTree") and name ~= "NeoTreePreview" and not hl.link and hl.bg then
			hl.bg = nil
			hl.ctermbg = nil
			vim.api.nvim_set_hl(0, name, hl)
		end
	end
end

vim.api.nvim_create_autocmd("ColorScheme", {
	desc = "Transparent background for all colorschemes",
	group = vim.api.nvim_create_augroup("transparent-background", { clear = true }),
	callback = make_transparent,
})
