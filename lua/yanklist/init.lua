local M = {}

function M.setup(user_config)
	local default_config = {
		keymap = "<leader>yl",
	}

	local config = vim.tbl_deep_extend("force", default_config, user_config or {})

	if config.keymap then
		vim.api.nvim_set_keymap(
			"n",
			config.keymap,
			"<cmd>lua require('yanklist.ui').toggle_side_panel()<CR>",
			{ noremap = true, silent = true }
		)
	end

	require("yanklist.core").initialize()
end
return M
