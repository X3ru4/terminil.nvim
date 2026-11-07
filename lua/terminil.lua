---@class terminil.opts
---@field use_default_keys boolean?
---@field keys [string, table|terminil.keyset|vim.keymap.set.Opts|false]?
---@field win_config vim.api.keyset.win_config? Default configuration for terminal windows when using the `M.open()` function.
---@field term_opts terminil.open.opts?
---@field on_open fun(buf: number, chan: number)?
---@field auto_startinsert boolean?

---@class terminil.open.opts
---@field cmd string|string[]?
---@field default boolean? If set to `true`, it will use the default window configuration from `M.config.win_config`, and vice versa.
---@field shell string?
---@field buf number?
---@field buf_call fun(buf: number)? This function will be called within the `nvim_buf_call` function.

---@alias terminil.keyset {
---		[1]: string|function,
---		mode: string|string[],
---}

local M = {}
local H = {}
M.helper = H

H.windata = {}

local api = vim.api
local keyprefix = {
	t = vim.g.tnil_keyprefix_t or '<C-t>',
	n = vim.g.tnil_keyprefix_n or '<leader>t',
}

---Default configuration
---@type terminil.opts
M.config = {
	use_default_keys = true,
	keys = {
		[keyprefix.t .. 't'] = { '<cmd>stopinsert<cr>', desc = 'Stop insert in terminal mode' },
		[keyprefix.t .. 'h'] = {
			function()
				M.hide()
			end,
			desc = 'Hide the terminal',
		},
		[keyprefix.t .. 'j'] = {
			function()
				M.focus(-1)
			end,
			desc = 'Next terminal window',
		},
		[keyprefix.t .. 'k'] = {
			function()
				M.focus(1)
			end,
			desc = 'Previous terminal window',
		},
		[keyprefix.t .. 'd'] = {
			function()
				M.close()
			end,
			desc = 'Close the terminal',
		},
		[keyprefix.t .. 'm'] = {
			function()
				M.open_multiple()
			end,
			desc = 'Open multiple terminal',
		},
		[keyprefix.t .. 'n'] = {
			function()
				vim.ui.input({ prompt = 'New name: ' }, function(input)
					if not input then
						return
					end
					api.nvim_buf_set_name(0, input)
				end)
			end,
			desc = 'Remame the terminal',
		},
		[keyprefix.n .. 'm'] = {
			function()
				M.open_multiple()
			end,
			mode = 'n',
			desc = 'Open multiple terminal',
		},
		[keyprefix.n .. 't'] = {
			function()
				if vim.v.count > 0 then
					M.open_in_order()
				else
					M.open()
				end
			end,
			mode = 'n',
			desc = 'Open new terminal',
		},
		[keyprefix.n .. 'h'] = {
			function()
				M.open({ split = vim.o.splitbelow and 'below' or 'above' })
			end,
			mode = 'n',
			desc = 'Open new split terminal',
		},
		[keyprefix.n .. 'v'] = {
			function()
				M.open({ split = vim.o.splitright and 'right' or 'left' })
			end,
			mode = 'n',
			desc = 'Open new vsplit terminal',
		},
		[keyprefix.n .. 'f'] = {
			function()
				local width = H.size('width', 0.7)
				local height = H.size('height', 0.6)
				M.open({
					relative = 'editor',
					title = ' >_ Terminal ',
					title_pos = 'center',
					width = width,
					height = height,
					row = math.ceil((vim.o.lines - height) / 2) - 2,
					col = math.ceil((vim.o.columns - width) / 2),
				})
			end,
			mode = 'n',
			desc = 'Open new float terminal',
		},
		[keyprefix.n .. 's'] = {
			function()
				M.select()
			end,
			mode = 'n',
			desc = 'Select terminal',
		},
		[keyprefix.n .. 'j'] = {
			function()
				M.focus(-1)
			end,
			mode = 'n',
			desc = 'Next terminal window',
		},
		[keyprefix.n .. 'k'] = {
			function()
				M.focus(1)
			end,
			mode = 'n',
			desc = 'Previous terminal window',
		},
		[keyprefix.n .. 'd'] = {
			function()
				M.close()
			end,
			mode = 'n',
			desc = 'Close the terminal',
		},
		[keyprefix.n .. 'c'] = {
			function()
				M.hide()
			end,
			mode = 'n',
			desc = 'Hide the terminal',
		},
	},
	win_config = {
		split = 'below',
	},
	term_opts = {},
	---@diagnostic disable-next-line: unused-local
	on_open = function(buf, chan) end,
	auto_startinsert = true,
}

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

local exclude_ft = {
	fzf = true,
}
function H.is_term(buf)
	return api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == 'terminal' and not exclude_ft[vim.bo[buf].filetype]
end

---@param split 'horizontal'|'vertical'
function H.default_split(split)
	local splits = {
		horizontal = vim.o.splitbelow and 'below' or 'above',
		vertical = vim.o.splitright and 'right' or 'left',
	}
	return splits[split]
end

---@param axis 'height'|'width'
---@param percent number 0.0->1.0
---@return number
function H.size(axis, percent)
	local total = axis == 'height' and vim.o.lines or vim.o.columns
	return math.ceil(total * percent)
end

---Open terminal buffer more intelligently
---@param buf number
function H.open_buf(buf)
	if H.is_term(buf) then
		if H.windata[buf] then
			local wins = H.buf_get_win(buf)
			if #wins > 0 then
				if #wins == 1 and api.nvim_win_is_valid(wins[1]) then
					api.nvim_set_current_win(wins[1])
				else
					vim.notify('This buffer: ' .. buf .. ' is running across multiple windows.', vim.log.levels.WARN)
				end
			else
				api.nvim_open_win(buf, true, H.windata[buf])
			end
		else
			api.nvim_set_current_buf(buf)
		end
	end
end

function H.list_termwins()
	return vim.tbl_filter(function(win)
		return H.is_term(api.nvim_win_get_buf(win))
	end, api.nvim_list_wins())
end

function H.list_termbufs()
	return vim.tbl_filter(function(buf)
		return H.is_term(buf)
	end, api.nvim_list_bufs())
end

function H.buf_get_win(buf)
	return vim.fn.win_findbuf(buf)
end

function H.is_termwin(win)
	return vim.tbl_contains(H.list_termwins(), win)
end

function H.setup_autocmd()
	local autocmd = api.nvim_create_autocmd
	local augroup = api.nvim_create_augroup('terminil.nvim', { clear = true })

	autocmd('TermOpen', {
		group = augroup,
		callback = function(ev)
			if M.config.auto_startinsert then
				vim.cmd.startinsert()
			end
			M.config.on_open(ev.buf, vim.bo[ev.buf].channel)
			if H.windata[ev.buf] then
				return
			end
			local wins = api.nvim_tabpage_list_wins(0)
			local normal_wins = vim.tbl_filter(function(win)
				return api.nvim_win_get_config(win).relative == ''
			end, wins)
			if #normal_wins == 1 then
				return
			end
			H.windata[ev.buf] = api.nvim_win_get_config(0)
		end,
	})
	autocmd('TermClose', {
		group = augroup,
		callback = function(ev)
			H.windata[ev.buf] = nil
		end,
	})
end

function H.setup_keys(keys)
	for key, value in pairs(vim.deepcopy(keys)) do
		if value then
			local mode = value.mode or 't'
			local rhs = value[1]
			value[1], value.mode = nil, nil
			vim.keymap.set(mode, key, rhs, value)
		end
	end
end

---Close the terminal
---@param buf number?
function M.close(buf)
	buf = buf or api.nvim_get_current_buf()
	if not H.is_term(buf) then
		return
	end
	if H.windata[buf] then
		api.nvim_win_close(0, true)
	end
	api.nvim_buf_delete(buf, { force = true })
end

---Hide the terminal
---@param buf number?
function M.hide(buf)
	buf = buf or api.nvim_get_current_buf()
	if not H.is_term(buf) then
		return
	end
	vim.bo[buf].buflisted = false
	if H.windata[buf] then
		api.nvim_win_close(0, true)
	else
		vim.cmd('bnext')
	end
end

---@param win_config vim.api.keyset.win_config?
---@param opts terminil.open.opts?
function M.open(win_config, opts)
	opts = vim.tbl_deep_extend('force', M.config.term_opts, opts or {})
	if opts.default then
		win_config = vim.tbl_deep_extend('force', M.config.win_config, win_config or {})
	end

	if opts.buf and H.is_term(opts.buf) then
		H.windata[opts.buf] = win_config or H.windata[opts.buf]
		H.open_buf(opts.buf)
		return
	end

	if opts.shell and vim.fn.executable(opts.shell) ~= 1 then
		opts.shell = nil
		vim.notify('Invalid shell "' .. opts.shell .. '"', vim.log.levels.ERROR)
		vim.notify('The terminal will use the default shell.')
	end

	local ok, err = pcall(function()
		if not win_config then
			vim.cmd.terminal(opts.shell or nil)
			local bufnr = api.nvim_get_current_buf()
			vim.bo[bufnr].buflisted = false
			if opts.cmd then
				api.nvim_chan_send(vim.bo[bufnr].channel, H.cmd_to_str(opts.cmd))
			end
			if opts.buf_call then
				opts.buf_call(bufnr)
			end
		else
			local bufnr = api.nvim_create_buf(false, true)
			H.windata[bufnr] = win_config
			api.nvim_buf_call(bufnr, function()
				vim.cmd.terminal(opts.shell or nil)
				vim.bo[bufnr].buflisted = false
				if opts.cmd then
					api.nvim_chan_send(vim.bo[bufnr].channel, H.cmd_to_str(opts.cmd))
				end
				if opts.buf_call then
					opts.buf_call(bufnr)
				end
			end)
			api.nvim_open_win(bufnr, true, win_config)
		end
	end)

	if not ok and err then
		vim.notify(err, vim.log.levels.ERROR)
	end
end

---@generic T
---@param ui_select fun(items: T[], opts: vim.ui.select.Opts, on_choice: fun(item: T|nil, idx: integer|nil))? Use this to replace the `vim.ui.select` function if you want to use a different function.
function M.select(ui_select)
	local termbufs = {}
	for idx, buf in ipairs(H.list_termbufs()) do
		table.insert(termbufs, {
			bufnr = buf,
			index = idx,
			name = vim.fs.basename(api.nvim_buf_get_name(buf)),
		})
	end
	if #termbufs == 0 then
		vim.notify('No terminal exists.')
		return
	end
	local opts = {
		prompt = 'Select terminal: ',
		format_item = function(item)
			return item.index .. ' ' .. item.name
		end,
	}
	(ui_select or vim.ui.select)(termbufs, opts, function(item, _)
		if not item then
			return
		end
		H.open_buf(item.bufnr)
	end)
end

---Open multiple terminal windows at the same time.
---@param count number|false? >1
---@param cycles string[]|vim.api.keyset.win_config[]?
---@param opts terminil.open.opts?
function M.open_multiple(count, cycles, opts)
	count = count or vim.v.count1

	local i_cycle = 1
	if not cycles then
		local termwins = H.list_termwins()
		if termwins[#termwins] then
			local split = api.nvim_win_get_config(termwins[#termwins]).split
			if split == 'above' or split == 'below' then
				i_cycle = 2
				count = count + 1
			end
		end
	end

	cycles = cycles or {
		H.default_split('horizontal'),
		H.default_split('vertical'),
	}

	for i = i_cycle, count do
		i_cycle = ((i - 1) % #cycles) + 1
		local val = cycles[i_cycle]
		---@diagnostic disable-next-line: param-type-mismatch
		M.open(type(val) == 'string' and { split = val } or val, opts)
	end
end

---Focus on the terminal windows in order
---@param direction -1|1
---@param count number?
function M.focus(direction, count)
	count = count or vim.v.count1
	local termwins = H.list_termwins()
	local current_win, current_idx = api.nvim_get_current_win(), 0

	for idx, win in ipairs(termwins) do
		if win == current_win then
			current_idx = idx
		end
	end

	local next_win = 0
	local idx = current_idx + count * direction
	if direction < 0 then
		idx = current_idx == 0 and 1 - count or idx
		if idx <= 0 then
			next_win = termwins[#termwins + (idx % -#termwins)]
		else
			next_win = termwins[idx]
		end
	else
		next_win = termwins[((idx - 1) % #termwins) + 1]
	end
	api.nvim_set_current_win(next_win)
end

---Switch to a different terminal in the current window in order
---@param direction -1|1
---@param count number?
function M.switch(direction, count)
	count = count or vim.v.count1
	local termbufs = H.list_termbufs()
	local current_buf = api.nvim_get_current_buf()
	for i, buf in ipairs(termbufs) do
		if buf == current_buf then
			local next_buf = 0
			if direction < 0 then
				local idx = i - count
				if idx <= 0 then
					next_buf = termbufs[#termbufs + (idx % -#termbufs)]
				else
					next_buf = termbufs[idx]
				end
			else
				next_buf = termbufs[(((i + count) - 1) % #termbufs) + 1]
			end
			H.windata[next_buf] = H.windata[current_buf]
			local opening_wins = H.buf_get_win(next_buf)
			if #opening_wins == 1 then
				api.nvim_win_close(opening_wins[1], true)
			end
			api.nvim_win_set_buf(0, next_buf)
		end
	end
end

---Similar to the `M.switch` function, but with the index you want
---@param idx number? > 0
function M.switch_in_order(idx)
	local count = idx or vim.v.count
	if count < 1 then
		return
	end
	local buf = H.list_termbufs()[count]
	if buf then
		local opening_wins = H.buf_get_win(buf)
		if #opening_wins == 1 then
			api.nvim_win_close(opening_wins[1], true)
		end
		api.nvim_win_set_buf(0, buf)
	end
end

---Similar to the `H.open_buf` function, but with the index you want
---@param idx number? > 0
function M.open_in_order(idx)
	local count = idx or vim.v.count
	if count < 1 then
		return
	end
	local buf = H.list_termbufs()[count]
	if buf then
		H.open_buf(buf)
	end
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
