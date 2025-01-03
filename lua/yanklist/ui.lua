local M = {}

-- State to manage the side panel
local state = {
	buf = nil,
	win = nil,
	map = {},
}

-- Create a side panel window
local function create_side_panel(contents)
	-- Process yank history for display
	local processed_contents = {}
	state.map = {}
	for _, item in ipairs(contents) do
		-- Split multiline yanks into lines
		local lines = vim.split(item, "\n", { plain = true })
		if #lines > 1 then
			-- Show the first line with "..." if its multiline
			local truncated = lines[1]:gsub("^%s+", "") .. " ..."
			table.insert(processed_contents, truncated)
			state.map[truncated] = item
		else
			-- Add single line yanks directly
			local single_line = lines[1]:gsub("^%s+", "")
			table.insert(processed_contents, single_line)
			state.map[single_line] = item
		end
		-- Add separator below each line
		table.insert(processed_contents, "---")
	end

	-- If the side panel is already open, update it
	if state.win and vim.api.nvim_win_is_valid(state.win) then
		vim.api.nvim_set_current_win(state.win)
		vim.bo[state.buf].modifiable = true
		vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, processed_contents)
		vim.bo[state.buf].modifiable = false
		return state.buf, state.win
	end

	-- Create a new buffer for the side panel
	local buf = vim.api.nvim_create_buf(false, true)
	vim.cmd("topleft vertical 30vsplit")
	local win = vim.api.nvim_get_current_win()

	-- Attach the buffer to the new window
	vim.api.nvim_win_set_buf(win, buf)

	-- Configure buffer and window
	vim.bo[buf].modifiable = true
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].swapfile = false
	vim.wo[win].winfixwidth = true
	vim.wo[win].number = false
	vim.wo[win].relativenumber = false

	-- Fill the buffer with processed contents
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, processed_contents)
	-- Make it read-only
	vim.bo[buf].modifiable = false

	-- Save the buffer and window IDs in state
	state.buf = buf
	state.win = win

	return buf, win
end

-- Toggle the side panel
function M.toggle_side_panel()
	-- If the window is already open, close it
	if state.win and vim.api.nvim_win_is_valid(state.win) then
		vim.api.nvim_win_close(state.win, true)
		state.buf = nil
		state.win = nil
		return
	end

	-- Load yank history
	local core = require("yanklist.core")
	local history = core.get_history()

	if #history == 0 then
		vim.notify("No yanked items yet!")
		return
	end

	-- Create the side panel
	create_side_panel(history)

	-- Allow the user to close the panel with `q`
	vim.api.nvim_buf_set_keymap(
		state.buf,
		"n",
		"q",
		"<cmd>lua require('yanklist.ui').toggle_side_panel()<CR>",
		{ noremap = true, silent = true }
	)

	-- Allow the user to yank an item with `<CR>`
	vim.api.nvim_buf_set_keymap(
		state.buf,
		"n",
		"<CR>",
		[[<cmd>lua require('yanklist.ui').select_item()<CR>]],
		{ noremap = true, silent = true }
	)
end

-- Handle selecting an item
function M.select_item()
	if not state.buf then
		return
	end

	-- Get the selected line
	local line = vim.api.nvim_get_current_line()

	-- Do nothing if the line is a separator
	if line == "---" then
		vim.notify("Cannot yank a separator", vim.log.levels.WARN)
		return
	end

	-- Get the full content for the selected line
	local full_content = state.map[line] or line

	-- Yank the full content
	vim.fn.setreg('"', full_content)
	vim.fn.setreg("0", full_content)
	vim.fn.setreg("+", full_content)

	-- Close side panel after yanking
	vim.api.nvim_win_close(state.win, true)
	vim.notify("Yanked: " .. (vim.split(full_content, "\n")[1] or full_content))
	state.buf = nil
	state.win = nil
	state.map = nil
end

return M
