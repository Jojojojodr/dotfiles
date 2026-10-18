-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- TIP: Disable arrow keys in normal mode
vim.keymap.set("n", "<left>", "")
vim.keymap.set("n", "<right>", "")
vim.keymap.set("n", "<up>", "")
vim.keymap.set("n", "<down>", "")

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- [[ Plugin Keymaps ]]
--  All plugin keybinds live here. Each entry is commented with the plugin it
--  belongs to and what the keybind does.

-- conform.nvim: <leader>f -> format the current buffer (LSP fallback)
vim.keymap.set("n", "<leader>f", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "[F]ormat buffer" })

-- themery.nvim: <leader>tt -> open the theme picker
vim.keymap.set("n", "<leader>tt", "<cmd>Themery<CR>", { desc = "Open Theme Picker" })

-- gitsigns.nvim: <leader>gp -> preview the current git hunk inline
vim.keymap.set("n", "<leader>gp", "<cmd>Gitsigns preview_hunk_inline<CR>", { desc = "Gitsigns: preview hunk inline" })
-- gitsigns.nvim: <leader>gt -> toggle the inline git blame for the current line
vim.keymap.set(
	"n",
	"<leader>gt",
	"<cmd>Gitsigns toggle_current_line_blame<CR>",
	{ desc = "Gitsigns: toggle line blame" }
)

-- harpoon: <leader>a -> add the current file to the harpoon list
vim.keymap.set("n", "<leader>a", function()
	require("harpoon"):list():add()
end, { desc = "Harpoon: add file" })
-- harpoon: <leader>r -> remove the current file from the harpoon list
vim.keymap.set("n", "<leader>r", function()
	require("harpoon"):list():remove()
end, { desc = "Harpoon: delete file" })
-- harpoon: <leader>h -> toggle the harpoon quick menu
vim.keymap.set("n", "<leader>h", function()
	require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
end, { desc = "Harpoon: toggle quick menu" })
-- harpoon: <C-h><C-h> -> jump to harpoon file 1
vim.keymap.set("n", "<c-h><c-h>", function()
	require("harpoon"):list():select(1)
end, { desc = "Harpoon: select file 1" })
-- harpoon: <C-h><C-j> -> jump to harpoon file 2
vim.keymap.set("n", "<c-h><c-j>", function()
	require("harpoon"):list():select(2)
end, { desc = "Harpoon: select file 2" })
-- harpoon: <C-h><C-k> -> jump to harpoon file 3
vim.keymap.set("n", "<c-h><c-k>", function()
	require("harpoon"):list():select(3)
end, { desc = "Harpoon: select file 3" })
-- harpoon: <C-h><C-l> -> jump to harpoon file 4
vim.keymap.set("n", "<c-h><c-l>", function()
	require("harpoon"):list():select(4)
end, { desc = "Harpoon: select file 4" })
-- harpoon: <C-s-n> -> jump to the next harpoon file
vim.keymap.set("n", "<c-s-n>", function()
	require("harpoon"):list():next()
end, { desc = "Harpoon: next file" })
-- harpoon: <C-s-p> -> jump to the previous harpoon file
vim.keymap.set("n", "<c-s-p>", function()
	require("harpoon"):list():prev()
end, { desc = "Harpoon: previous file" })

-- neo-tree.nvim: <C-n> -> toggle the filesystem tree on the left
vim.keymap.set("n", "<C-n>", "<cmd>Neotree filesystem toggle left<CR>", { desc = "Neo-tree: toggle filesystem" })

-- telescope.nvim: <leader>sh -> search help tags
vim.keymap.set("n", "<leader>sh", function()
	require("telescope.builtin").help_tags()
end, { desc = "[S]earch [H]elp" })
-- telescope.nvim: <leader>sk -> search keymaps
vim.keymap.set("n", "<leader>sk", function()
	require("telescope.builtin").keymaps()
end, { desc = "[S]earch [K]eymaps" })
-- telescope.nvim: <leader>p -> find files
vim.keymap.set("n", "<leader>p", function()
	require("telescope.builtin").find_files()
end, { desc = "[S]earch [F]iles" })
-- telescope.nvim: <leader>ss -> search telescope builtins
vim.keymap.set("n", "<leader>ss", function()
	require("telescope.builtin").builtin()
end, { desc = "[S]earch [S]elect Telescope" })
-- telescope.nvim: <leader>sw -> search the word under the cursor
vim.keymap.set("n", "<leader>sw", function()
	require("telescope.builtin").grep_string()
end, { desc = "[S]earch current [W]ord" })
-- telescope.nvim: <leader>sg -> live grep across the project
vim.keymap.set("n", "<leader>sg", function()
	require("telescope.builtin").live_grep()
end, { desc = "[S]earch by [G]rep" })
-- telescope.nvim: <leader>sd -> search diagnostics
vim.keymap.set("n", "<leader>sd", function()
	require("telescope.builtin").diagnostics()
end, { desc = "[S]earch [D]iagnostics" })
-- telescope.nvim: <leader>sr -> resume the previous telescope picker
vim.keymap.set("n", "<leader>sr", function()
	require("telescope.builtin").resume()
end, { desc = "[S]earch [R]esume" })
-- telescope.nvim: <leader>s. -> search recently opened files
vim.keymap.set("n", "<leader>s.", function()
	require("telescope.builtin").oldfiles()
end, { desc = '[S]earch Recent Files ("." for repeat)' })
-- telescope.nvim: <leader>sc -> search color schemes
vim.keymap.set("n", "<leader>sc", function()
	require("telescope.builtin").colorscheme()
end, { desc = "[S]earch [C]olorschemes" })
-- telescope.nvim: <leader><leader> -> find existing buffers
vim.keymap.set("n", "<leader><leader>", function()
	require("telescope.builtin").buffers()
end, { desc = "[ ] Find existing buffers" })
-- telescope.nvim: <leader>/ -> fuzzily search within the current buffer
vim.keymap.set("n", "<leader>/", function()
	require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
		winblend = 10,
		previewer = false,
	}))
end, { desc = "[/] Fuzzily search in current buffer" })
-- telescope.nvim: <leader>s/ -> live grep in the currently open files
vim.keymap.set("n", "<leader>s/", function()
	require("telescope.builtin").live_grep({
		grep_open_files = true,
		prompt_title = "Live Grep in Open Files",
	})
end, { desc = "[S]earch [/] in Open Files" })
-- telescope.nvim: <leader>sn -> search the neovim config files
vim.keymap.set("n", "<leader>sn", function()
	require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
end, { desc = "[S]earch [N]eovim files" })

-- vim-tmux-navigator: move between nvim windows and tmux panes with CTRL+<hjkl>
--  Kept after the split navigation above so it takes precedence, matching the
--  previous lazy-loaded behaviour.
vim.keymap.set("n", "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>", { desc = "Tmux navigator: left" })
vim.keymap.set("n", "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>", { desc = "Tmux navigator: down" })
vim.keymap.set("n", "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>", { desc = "Tmux navigator: up" })
vim.keymap.set("n", "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>", { desc = "Tmux navigator: right" })
vim.keymap.set("n", "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>", { desc = "Tmux navigator: previous" })

-- nvim-lspconfig: buffer-local keymaps, applied when a language server attaches
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("kickstart-lsp-attach-keymaps", { clear = true }),
	callback = function(event)
		local map = function(keys, func, desc, mode)
			mode = mode or "n"
			vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end

		-- nvim-lspconfig + telescope.nvim: gd -> go to definition
		map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
		-- nvim-lspconfig + telescope.nvim: gr -> go to references
		map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
		-- nvim-lspconfig + telescope.nvim: gI -> go to implementation
		map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
		-- nvim-lspconfig + telescope.nvim: <leader>D -> go to type definition
		map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
		-- nvim-lspconfig + telescope.nvim: <leader>ds -> show document symbols
		map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
		-- nvim-lspconfig + telescope.nvim: <leader>ws -> show workspace symbols
		map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
		-- nvim-lspconfig: <leader>rn -> rename the symbol under the cursor
		map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
		-- nvim-lspconfig: <leader>ca -> apply a code action (normal + visual)
		map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
		-- nvim-lspconfig: gD -> go to declaration
		map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

		-- nvim-lspconfig: <leader>th -> toggle inlay hints (only if the server supports them)
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
			map("<leader>th", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
			end, "[T]oggle Inlay [H]ints")
		end
	end,
})
