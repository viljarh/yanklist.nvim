local M = {}
local yank_history = {}

function M.add_to_history()
	local event = vim.v.event
	local text = table.concat(event.regcontents, "\n")
	if #text > 0 then
		table.insert(yank_history, 1, text)
	end
end

function M.get_history()
	return yank_history
end

function M.initialize()
	vim.api.nvim_create_autocmd("TextYankPost", {
		callback = M.add_to_history,
	})
end

return M
