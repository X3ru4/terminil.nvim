---@class terminil.opts
---@field use_default_keys boolean?
---@field keys [string, table|terminil.keyset|vim.keymap.set.Opts|false]?
---@field win_config vim.api.keyset.win_config? Default configuration for terminal windows when using the `M.open()` function.
---@field term_opts terminil.open.opts?
---@field on_open fun(buf: number, chan: number)?
---@field buflisted boolean?
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

H.windata = { opening = {} }

local api = vim.api

---Default configuration
---@type terminil.opts
M.config = {
	use_default_keys = true,
	keys = {
		['<C-t>h'] = { '<cmd>hide<cr>', desc = 'Hide the window' },
		['<C-t>t'] = { '<cmd>stopinsert<cr>', desc = 'Stop insert in terminal mode' },
		['<C-t>j'] = {
			function()
				M.focus(1)
			end,
			desc = 'Next terminal window',
		},
		['<C-t>k'] = {
			function()
				M.focus(-1)
			end,
			desc = 'Previous terminal window',
		},
		['<C-t>d'] = {
			function()
				local buf = api.nvim_win_get_buf(0)
				if H.windata[buf] then
					api.nvim_win_close(0, false)
				end
				api.nvim_buf_delete(buf, { force = true })
			end,
			desc = 'Delete the terminal',
		},
		['<C-t>m'] = {
			function()
				M.open_multiple()
			end,
			desc = 'Open multiple terminal',
		},
		['<C-t>n'] = {
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
		['<leader>tm'] = {
			function()
				M.open_multiple()
			end,
			mode = 'n',
			desc = 'Open multiple terminal',
		},
		['<leader>tt'] = {
			function()
				M.open()
			end,
			mode = 'n',
			desc = 'Open new terminal',
		},
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
		['<leader>tf'] = {
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
		['<leader>ts'] = {
			function()
				M.select()
			end,
			mode = 'n',
			desc = 'Select terminal',
		},
		['<leader>tj'] = {
			function()
				M.focus(1)
			end,
			mode = 'n',
			desc = 'Next terminal window',
		},
		['<leader>tk'] = {
			function()
				M.focus(-1)
			end,
			mode = 'n',
			desc = 'Previous terminal window',
		},
		['<leader>td'] = {
			function()
				local buf = api.nvim_win_get_buf(0)
				if H.windata[buf] then
					api.nvim_win_close(0, false)
				end
				api.nvim_buf_delete(buf, { force = true })
			end,
			mode = 'n',
			desc = 'Delete the terminal',
		},
	},
	win_config = {
		split = 'below',
	},
	term_opts = {},
	on_open = function(buf, chan) end,
	buflisted = false,
	auto_startinsert = true,
}

function H.setup_keys(keys)
	for key, value in pairs(keys) do
		if value then
			local mode = value.mode or 't'
			local rhs = value[1]
			value[1], value.mode = nil, nil
			vim.keymap.set(mode, key, rhs, value)
		end
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

local exclude_ft = {
	fzf = true,
}
function H.is_term(buf)
	return vim.bo[buf] and vim.bo[buf].buftype == 'terminal' and not exclude_ft[vim.bo[buf].filetype]
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

function H.open_buf(buf)
	if H.is_term(buf) then
		if H.windata[buf] then
			local winid = H.windata.opening[buf]
			if winid and vim.tbl_contains(api.nvim_tabpage_list_wins(0), winid) then
				api.nvim_set_current_win(winid)
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
		if H.is_term(api.nvim_win_get_buf(win)) then
			return true
		end
		return false
	end, api.nvim_list_wins())
end

function H.list_termbufs()
	return vim.tbl_filter(function(buf)
		if H.is_term(buf) then
			return true
		end
		return false
	end, api.nvim_list_bufs())
end

function H.setup_autocmd()
	local autocmd = api.nvim_create_autocmd
	local group = api.nvim_create_augroup('terminil.nvim', { clear = true })

	autocmd('TermOpen', {
		group = group,
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
		group = group,
		callback = function(ev)
			H.windata[ev.buf] = nil
			H.windata.opening[ev.buf] = nil
		end,
	})
	autocmd('WinEnter', {
		group = group,
		callback = function(ev)
			if H.is_term(ev.buf) then
				H.windata.opening[ev.buf] = api.nvim_get_current_win()
			end
		end,
	})
	autocmd('WinClosed', {
		group = group,
		callback = function(ev)
			if H.windata.opening[ev.buf] then
				H.windata.opening[ev.buf] = nil
			end
		end,
	})
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

	local shell = vim.o.shell

	if opts.shell then
		if vim.fn.executable(opts.shell) == 1 then
			vim.opt.shell = opts.shell
		else
			vim.notify('Invalid shell "' .. opts.shell .. '"', vim.log.levels.ERROR)
			vim.notify('The terminal will use the default shell.')
		end
	end

	local ok, err = pcall(function()
		if not win_config then
			vim.cmd.terminal()
			local bufnr = api.nvim_get_current_buf()
			vim.bo[bufnr].buflisted = M.config.buflisted
			if opts.cmd then
				api.nvim_chan_send(vim.bo[bufnr].channel, H.cmd_to_str(opts.cmd))
			end
		else
			local bufnr = api.nvim_create_buf(false, true)
			H.windata[bufnr] = win_config
			api.nvim_buf_call(bufnr, function()
				vim.cmd.terminal()
				vim.bo[bufnr].buflisted = M.config.buflisted
				if opts.cmd then
					api.nvim_chan_send(vim.bo[bufnr].channel, H.cmd_to_str(opts.cmd))
				end
				if opts.buf_call then
					opts.buf_call(bufnr)
				end
			end)
			local winid = api.nvim_open_win(bufnr, true, win_config)
			H.windata.opening[bufnr] = winid
		end
	end)

	vim.opt.shell = shell
	if not ok and err then
		vim.notify(err, vim.log.levels.ERROR)
	end
end

---@generic T
---@param ui_select fun(items: T[], opts: vim.ui.select.Opts, on_choice: fun(item: T|nil, idx: integer|nil))? Use this to replace the `vim.ui.select` function if you want to use a different function.
function M.select(ui_select)
	local termbufs = {}
	for _, buf in ipairs(H.list_termbufs()) do
		table.insert(termbufs, {
			name = vim.fs.basename(api.nvim_buf_get_name(buf)),
			bufnr = buf,
		})
	end
	if #termbufs == 0 then
		vim.notify('No terminal exists.')
		return
	end
	local opts = {
		prompt = 'Select terminal: ',
		format_item = function(item)
			return item.name
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
---@param count number? >1
---@param horizontal 'above'|'below'?
---@param vertical 'left'|'right'?
function M.open_multiple(count, horizontal, vertical)
	count = count or vim.v.count1
	local i_cycle = 1
	local cycles = {
		horizontal or H.default_split('horizontal'),
		vertical or H.default_split('vertical'),
	}

	local termwins = H.list_termwins()

	if termwins[#termwins] then
		local split = api.nvim_win_get_config(termwins[#termwins]).split
		if split == 'above' or split == 'below' then
			i_cycle = 2
			count = count + 1
		end
	end

	for i = i_cycle, count do
		i_cycle = ((i - 1) % 2) + 1
		M.open({ split = cycles[i_cycle] })
	end
end

---Focus on the terminal windows in order
---@param direction -1|1
function M.focus(direction)
	local termwins = H.list_termwins()
	local current_win = api.nvim_get_current_win()
	for i, win in ipairs(termwins) do
		if win == current_win then
			local count = math.abs(i + direction * vim.v.count1)
			count = ((count - 1) % #termwins) + 1
			api.nvim_set_current_win(termwins[count])
		end
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
