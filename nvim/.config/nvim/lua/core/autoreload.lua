-- Real-time reload of buffers changed on disk by external agents (Claude, Codex).
-- A libuv fs_event watcher on the cwd triggers a debounced :checktime, so buffers
-- update immediately instead of waiting for FocusGained/CursorHold.
local uv = vim.uv or vim.loop

local M = {}
local handle, timer
local ignored = { "/.git/", "/node_modules/", "/.venv/" }

local function is_ignored(path)
	for _, pat in ipairs(ignored) do
		if path:find(pat, 1, true) then
			return true
		end
	end
	return false
end

local function schedule_check()
	if not timer then
		timer = uv.new_timer()
	end
	timer:stop()
	timer:start(
		50,
		0,
		vim.schedule_wrap(function()
			if vim.fn.mode():match("[cr!t]") or vim.fn.getcmdwintype() ~= "" then
				return
			end
			vim.cmd("silent! checktime")
		end)
	)
end

function M.start()
	if handle then
		handle:stop()
		handle:close()
		handle = nil
	end
	local cwd = uv.cwd()
	handle = uv.new_fs_event()
	if not handle then
		return
	end
	-- recursive is supported on macOS/Windows; elsewhere it is silently ignored
	handle:start(cwd, { recursive = true }, function(err, filename)
		if err or not filename then
			return
		end
		if is_ignored("/" .. filename) then
			return
		end
		schedule_check()
	end)
end

function M.setup()
	local group = vim.api.nvim_create_augroup("Autoreload", { clear = true })

	-- Unmodified buffer: reload silently. Modified buffer: keep it, warn.
	vim.api.nvim_create_autocmd("FileChangedShell", {
		group = group,
		callback = function(args)
			if vim.bo[args.buf].modified then
				vim.v.fcs_choice = ""
				vim.notify(
					("%s changed on disk but buffer has edits. :DiffOrig to compare, :e! to discard yours."):format(
						vim.fn.fnamemodify(args.file, ":~:.")
					),
					vim.log.levels.WARN
				)
			else
				vim.v.fcs_choice = "reload"
			end
		end,
	})

	vim.api.nvim_create_autocmd("FileChangedShellPost", {
		group = group,
		callback = function(args)
			vim.notify(("Reloaded %s (changed on disk)"):format(vim.fn.fnamemodify(args.file, ":~:.")))
		end,
	})

	vim.api.nvim_create_autocmd({ "DirChanged", "VimEnter" }, {
		group = group,
		callback = M.start,
	})

	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = group,
		callback = function()
			if handle then
				handle:stop()
				handle:close()
			end
			if timer then
				timer:stop()
				timer:close()
			end
		end,
	})

	-- Buffer vs on-disk diff (classic :DiffOrig recipe)
	vim.api.nvim_create_user_command("DiffOrig", function()
		local ft = vim.bo.filetype
		vim.cmd("vert new | set buftype=nofile bufhidden=wipe | read ++edit # | 0d_")
		vim.bo.filetype = ft
		vim.cmd("diffthis | wincmd p | diffthis")
	end, { desc = "Diff buffer against file on disk" })
end

return M
