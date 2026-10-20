---@class terminil.opts
---@field use_default_keys boolean?
---@field keys [string, table]|terminil.keyset|vim.keymap.set.Opts?
---@field win_config vim.api.keyset.win_config? Default configuration for terminal windows when using the `M.open()` function.
---@field buflisted boolean?

---@alias terminil.keyset {
---[1]: string|function,
---mode: string|string[],
---}

local M = {}
local H = {}
M.helper = H

H.win_data = {}

---Default configuration
---@type terminil.opts
M.config = {
	use_default_keys = true,
	keys = {
		['<C-w>e'] = { '<cmd>hide<cr>', desc = 'Hide the window' },
		['<C-w>c'] = { '<cmd>silent! bdelete!<cr>', desc = 'Delete the terminal' },
		['<C-w>s'] = { '<cmd>stopinsert<cr>', desc = 'Stop insert in terminal mode' },
		['<C-w>n'] = {
			function()
				vim.ui.input({ prompt = 'New name: ' }, function(input)
					if not input then
						return
					end
					vim.api.nvim_buf_set_name(0, input)
				end)
			end,
			desc = 'Remame the terminal',
		},
		['<leader>tt'] = { '<cmd>terminal<cr>i', mode = 'n', desc = 'Open new terminal' },
		['<leader>th'] = {
			function()
				M.open({ split = vim.o.splitbelow and 'below' or 'above' })
			end,
			mode = 'n',
			desc = 'Open new split terminal',
		},
		['<leader>tv'] = {
			function()
				M.open({ split = vim.o.splitright and 'right' or 'left' })
			end,
			mode = 'n',
			desc = 'Open new vsplit terminal',
		},
		['<leader>ts'] = {
			function()
				M.select()
			end,
			mode = 'n',
			desc = 'Select terminal',
		},
	},
	win_config = {
		split = 'below',
	},
	buflisted = false,
}

function H.setup_keys(keys)
	for key, value in pairs(keys) do
		local mode = value.mode or 't'
		local rhs = value[1]
		value[1], value.mode = nil, nil
		vim.keymap.set(mode, key, rhs, value)
	end
end

---@param cmd string|string[]
---@return string
function H.cmd_to_str(cmd)
	local nl = vim.keycode('<nl>')
	if type(cmd) == 'table' then
		return table.concat(cmd, nl) .. nl
	else
		return cmd .. nl
	end
end

function H.setup_autocmd()
	local autocmd = vim.api.nvim_create_autocmd
	local group = vim.api.nvim_create_augroup('terminil.nvim', { clear = true })

	autocmd('TermOpen', {
		group = group,
		callback = function(ev)
			if not H.win_data[ev.buf] then
				local wins = vim.api.nvim_tabpage_list_wins(0)
				local normal_wins = vim.tbl_filter(function(win)
					return vim.api.nvim_win_get_config(win).relative == ''
				end, wins)
				if #normal_wins == 1 then
					return
				end
				H.win_data[ev.buf] = vim.api.nvim_win_get_config(0)
			end
		end,
	})
	autocmd('TermClose', {
		group = group,
		callback = function(ev)
			H.win_data[ev.buf] = nil
		end,
	})
end

---@param opts vim.api.keyset.win_config?
---@param default boolean?
---@param cmd string|string[]?
function M.open(opts, default, cmd)
	if default or default == nil then
		opts = vim.tbl_deep_extend('force', M.config.win_config, opts or {})
	end
	if not opts then
		return
	end

	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_call(bufnr, function()
		vim.cmd.terminal()
		vim.cmd.startinsert()
		if cmd then
			vim.api.nvim_chan_send(vim.bo[bufnr].channel, H.cmd_to_str(cmd))
		end
		vim.bo[bufnr].buflisted = M.config.buflisted
	end)
	vim.api.nvim_open_win(bufnr, true, opts)
	H.win_data[bufnr] = opts
end

---@generic T
---@param ui_select fun(items: T[], opts: vim.ui.select.Opts, on_choice: fun(item: T|nil, idx: integer|nil))? Use this to replace the `vim.ui.select` function if you want to use a different function.
function M.select(ui_select)
	local bufs = vim.api.nvim_list_bufs()
	local term_bufs = {}
	for _, buf in ipairs(bufs) do
		if vim.bo[buf].buftype == 'terminal' and vim.bo[buf].filetype == '' then
			table.insert(term_bufs, {
				name = vim.fs.basename(vim.api.nvim_buf_get_name(buf)),
				bufnr = buf,
			})
		end
	end
	if #term_bufs == 0 then
		vim.notify('No terminal exists.')
		return
	end
	local opts = {
		prompt = 'Select terminal: ',
		format_item = function(item)
			return item.name
		end,
	}
	(ui_select or vim.ui.select)(term_bufs, opts, function(item, _)
		if not item then
			return
		end
		if H.win_data[item.bufnr] then
			vim.api.nvim_open_win(item.bufnr, true, H.win_data[item.bufnr])
		else
			vim.api.nvim_set_current_buf(item.bufnr)
		end
	end)
end

---@param opts terminil.opts?
function M.setup(opts)
	M.config = vim.tbl_deep_extend('force', M.config, opts or {})
	H.setup_autocmd()
	if M.config.use_default_keys then
		H.setup_keys(M.config.keys)
	end
end

return M
