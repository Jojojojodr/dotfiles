return {
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			},
		},
	},
	{ "Bilal2453/luvit-meta", lazy = true },
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "williamboman/mason.nvim", config = true },
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({
									group = "kickstart-lsp-highlight",
									buffer = event2.buf,
								})
							end,
						})
					end
				end,
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			local servers = {
				clangd = {
					cmd = { "clangd", "--offset-encoding=utf-16" },
					filetypes = { "c", "cpp", "h", "hpp", "objc", "objcpp" },
					root_markers = { ".git", "makefile" },
				},
				gopls = {
					cmd = { "gopls" },
					filetypes = { "go", "gomod", "gowork", "gotmpl" },
					settings = {
						gopls = {
							completeUnimported = true,
							usePlaceholders = true,
							analyses = {
								unusedparams = true,
							},
						},
					},
				},
				templ = {
					cmd = { "templ", "lsp" },
					filetypes = { "templ" },
					root_markers = { "go.work", "go.mod", ".git" },
				},
				pyright = {
					cmd = { "pyright-langserver", "--stdio" },
					filetypes = { "python" },
					root_markers = { ".git", "requirements.txt" },
				},
				rust_analyzer = {
					cmd = { "rust-analyzer" },
					filetypes = { "rust" },
				},
				ts_ls = {
					cmd = { "typescript-language-server", "--stdio" },
					filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
				},

				lua_ls = {
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
						},
					},
				},
			}

			require("mason").setup()

			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"gopls",
				"stylua",
				"rust-analyzer",
				"clangd",
				"pyright",
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			vim.lsp.config("*", { capabilities = capabilities })
			for server_name, server in pairs(servers) do
				vim.lsp.config(server_name, server)
			end

			require("mason-lspconfig").setup()
		end,
	},
}
