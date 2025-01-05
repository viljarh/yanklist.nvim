local M = {}

function M.setup(user_config)
	require("yanklist.core").initialize()

	vim.api.nvim_set_keymap(
		"n",
		"<leader>yl",
		"<cmd>lua require('yanklist.ui').toggle_side_panel()<CR>",
		{ noremap = true, silent = true }
	)
	if user_config and user_config.keymap then
		vim.api.nvim_set_keymap(
			"n",
			user_config.keymap,
			"<cmd>lua require('yanklist.ui').toggle_side_panel()<CR>",
			{ noremap = true, silent = true }
		)
	end
end

return M
