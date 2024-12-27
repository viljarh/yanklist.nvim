local M = {}

local state = {
	buf = nil,
	win = nil,
}

-- Create a window
local function create_window(contents)
	local truncated_contents = {}
	for _, item in ipairs(contents) do
		local first_line = item:match("^[^\n]*") or ""
		if #item > #first_line then
			first_line = first_line .. " ..."
		end
		table.insert(truncated_contents, first_line)
	end

	local buf = vim.api.nvim_create_buf(false, true)

	local width = 50
	local height = math.min(#contents, 20)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local opts = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "single",
	}

	local win = vim.api.nvim_open_win(buf, true, opts)

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, truncated_contents)

	vim.bo[buf].modifiable = false
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].swapfile = false

	return buf, win
end

-- toggle yank history in a window
function M.toggle_history()
	if state.win and vim.api.nvim_win_is_valid(state.win) then
		vim.api.nvim_win_close(state.win, true)
		state.win = nil
		state.buf = nil
		return
	end

	local core = require("yanklist.core")
	local history = core.get_history()

	if #history == 0 then
		vim.notify("No yanked items yet!")
		return
	end

	local buf, win = create_window(history)
	state.buf = buf
	state.win = win

	-- close window with q
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"q",
		[[<cmd>lua require("yanklist.ui").toggle_history()<CR>]],
		{ noremap = true, silent = true }
	)

	-- press enter to yank item from the list
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"<CR>",
		[[<cmd>lua require("yanklist.ui").select_item()<CR>]],
		{ noremap = true, silent = true }
	)
end

-- Handle selecting an item
function M.select_item()
	if not state.buf then
		return
	end

	local line_number = vim.api.nvim_win_get_cursor(0)[1] -- 1-based index
	local core = require("yanklist.core")
	local full_history = core.get_history()

	local selected_item = full_history[line_number]
	if selected_item then
		vim.fn.setreg('"', selected_item)
		vim.api.nvim_win_close(state.win, true)
		vim.notify("Yanked: " .. selected_item:sub(1, 50) .. (selected_item:len() > 50 and " ..." or ""))
		state.buf = nil
		state.win = nil
	end
end

return M
