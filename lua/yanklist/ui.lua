local M = {}

-- State to manage the floating window and buffer
local state = {
	buf = nil,
	win = nil,
}

-- Format lines for better readability
local function format_lines(lines, max_width)
	local formatted = {}
	for _, line in ipairs(lines) do
		-- Handle multiline yanks: only show the first line with "..."
		local first_line = line:match("[^\r\n]+")
		if line:find("\n") then
			first_line = first_line .. "..." -- Indicate it's multiline
		end

		-- Truncate if it exceeds max width
		if #first_line > max_width then
			table.insert(formatted, first_line:sub(1, max_width - 3) .. "...")
		else
			table.insert(formatted, first_line)
		end

		-- Add a separator below each entry
		table.insert(formatted, string.rep("-", max_width))
	end
	return formatted
end

-- Create a side panel window
local function create_window(contents)
	local buf = vim.api.nvim_create_buf(false, true) -- Create a new unlisted scratch buffer

	-- Define the dimensions for the side panel
	local width = 50 -- Width of the side panel
	local height = vim.o.lines - 4 -- Leave 2 lines of padding at top and bottom
	local row = 2 -- Start 2 lines below the top
	local col = 0 -- Align to the left edge

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

	-- Format lines for better readability
	local max_line_width = width - 2
	local formatted_contents = format_lines(contents, max_line_width)

	-- Populate the buffer with formatted contents
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, formatted_contents)

	-- Set buffer-local options
	vim.bo[buf].modifiable = false
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].swapfile = false

	return buf, win
end

-- Toggle the yank history panel
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

	-- Allow the user to close the panel with "q"
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"q",
		[[<cmd>lua require("yanklist.ui").toggle_history()<CR>]],
		{ noremap = true, silent = true }
	)

	-- Allow the user to select an item to yank
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
	local line = vim.api.nvim_get_current_line()

	-- Ignore separator lines when selecting
	if line:match("^%-%-$") then
		vim.notify("Cannot select a separator line!")
		return
	end

	vim.fn.setreg('"', line) -- Set the default register to the selected line
	vim.api.nvim_win_close(state.win, true)
	vim.notify("Yanked: " .. line)
	state.buf = nil
	state.win = nil
end

return M
