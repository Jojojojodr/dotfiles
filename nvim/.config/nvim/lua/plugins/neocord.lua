return {
	"IogaMaster/neocord",
	lazy = false,                    -- Force early loading (critical fix)
	enabled = true,
	priority = 1000,                 -- High priority to load early
	config = function()
		require("neocord").setup({
			-- General options
			logo                = "auto",
			logo_tooltip        = nil,
			main_image          = "language",
			client_id           = "1157438221865717891",
			log_level           = "debug",    -- ⬅️ ENABLE DEBUG LOGGING (critical for troubleshooting)
			debounce_timeout    = 1,          -- ⬅️ Reduced from 10s (was causing delays)
			blacklist           = {},
			file_assets         = {},
			show_time           = true,
			global_timer        = false,

			-- Rich Presence text options
			editing_text        = "Editing %s",
			file_explorer_text  = "Browsing %s",
			git_commit_text     = "Committing changes",
			plugin_manager_text = "Managing plugins",
			reading_text        = "Reading %s",
			workspace_text      = "Working on %s",
			line_number_text    = "Line %s out of %s",
			terminal_text       = "Using Terminal",
		})
	end,
}
