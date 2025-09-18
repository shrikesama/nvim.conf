local M = {}

local defaults = {
    border = "double",
    winblend = 0,
    preview_title = "Preview",
    max_file_size = 256 * 1024,
}

local state = {
    opts = {},
    tree = {
        is_open = false,
        bufnr = nil,
        winid = nil,
        augroup = nil,
        win_autocmd = nil,
    },
    preview = {
        layout = nil,
        buf = nil,
        win = nil,
    },
    api = nil,
    last_path = nil,
    events_registered = false,
}

local close_preview_win
local handle_tree_closed
local sync_tree_state

local function get_api()
    if state.api then
        return state.api
    end
    local ok, api = pcall(require, "nvim-tree.api")
    if not ok then
        return nil
    end
    state.api = api
    return api
end

local function safe_del_augroup(id)
    if not id then
        return
    end
    pcall(vim.api.nvim_del_augroup_by_id, id)
end

local function safe_del_autocmd(id)
    if not id then
        return
    end
    pcall(vim.api.nvim_del_autocmd, id)
end

local function track_tree_win(winid)
    if not winid then
        return
    end
    state.tree.winid = winid
    if state.tree.win_autocmd then
        safe_del_autocmd(state.tree.win_autocmd)
    end
    state.tree.win_autocmd = vim.api.nvim_create_autocmd("WinClosed", {
        pattern = tostring(winid),
        callback = function()
            handle_tree_closed()
        end,
    })
end

local function update_tree_win()
    if state.tree.winid and vim.api.nvim_win_is_valid(state.tree.winid) then
        return state.tree.winid
    end
    if state.tree.bufnr and vim.api.nvim_buf_is_valid(state.tree.bufnr) then
        local win = vim.fn.bufwinid(state.tree.bufnr)
        if win ~= -1 and vim.api.nvim_win_is_valid(win) then
            track_tree_win(win)
            return win
        end
    end
    return nil
end

local function focus_tree_win()
    local win = update_tree_win()
    if win then
        vim.api.nvim_set_current_win(win)
        return true
    end
    return false
end

local function ensure_preview_buf()
    local buf = state.preview.buf
    if buf and vim.api.nvim_buf_is_valid(buf) then
        return buf
    end
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
    vim.api.nvim_buf_set_option(buf, "swapfile", false)
    vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.keymap.set("n", "<Esc>", function()
        focus_tree_win()
    end, { buffer = buf, desc = "Focus nvim-tree" })
    vim.keymap.set("n", "<CR>", function()
        if focus_tree_win() then
            local api = get_api()
            if api then
                api.node.open.edit()
                sync_tree_state()
            end
        end
    end, { buffer = buf, desc = "Open file from preview" })
    state.preview.buf = buf
    return buf
end

local function apply_window_options(win)
    vim.api.nvim_win_set_option(win, "wrap", false)
    vim.api.nvim_win_set_option(win, "cursorline", false)
    vim.api.nvim_win_set_option(win, "cursorcolumn", false)
    vim.api.nvim_win_set_option(win, "number", false)
    vim.api.nvim_win_set_option(win, "relativenumber", false)
    vim.api.nvim_win_set_option(win, "signcolumn", "no")
    vim.api.nvim_win_set_option(win, "foldenable", false)
    if state.opts.winblend and state.opts.winblend > 0 then
        vim.api.nvim_win_set_option(win, "winblend", state.opts.winblend)
    end
    if vim.fn.has("nvim-0.9") == 1 and state.opts.preview_title ~= "" then
        local cfg = vim.api.nvim_win_get_config(win)
        cfg.title = state.opts.preview_title
        pcall(vim.api.nvim_win_set_config, win, cfg)
    end
end

local function has_preview_layout()
    return state.preview.layout ~= nil and state.preview.layout.preview ~= nil
end

local function ensure_preview_win()
    if state.preview.win and vim.api.nvim_win_is_valid(state.preview.win) then
        return state.preview.win
    end
    if not has_preview_layout() then
        return nil
    end
    local buf = ensure_preview_buf()
    local cfg = state.preview.layout.preview
    local win = vim.api.nvim_open_win(buf, false, {
        relative = "editor",
        width = cfg.width,
        height = cfg.height,
        row = cfg.row,
        col = cfg.col,
        border = state.opts.border,
        style = "minimal",
        noautocmd = true,
        zindex = 60,
    })
    state.preview.win = win
    apply_window_options(win)
    return win
end

close_preview_win = function()
    if state.preview.win and vim.api.nvim_win_is_valid(state.preview.win) then
        vim.api.nvim_win_close(state.preview.win, true)
    end
    state.preview.win = nil
    state.last_path = nil
end

local function show_lines(lines, filetype)
    local buf = ensure_preview_buf()
    vim.api.nvim_buf_set_option(buf, "modifiable", true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(buf, "modifiable", false)
    vim.api.nvim_buf_set_option(buf, "filetype", filetype or "")
    ensure_preview_win()
end

local function render_file(path)
    local stat = vim.loop.fs_stat(path)
    if not stat or stat.type ~= "file" then
        close_preview_win()
        return false
    end
    if stat.size > state.opts.max_file_size then
        local size_kb = math.floor(stat.size / 1024)
        show_lines({ string.format("File too large (%d KB)", size_kb) }, "nvimtreepreview")
        return true
    end
    local ok, data = pcall(vim.fn.readfile, path)
    if not ok then
        show_lines({ "Error reading file", tostring(data) }, "nvimtreepreview")
        return true
    end
    show_lines(data, vim.filetype.match({ filename = path }) or "")
    return true
end

local function render_node(force)
    if not state.tree.is_open then
        return false
    end
    local api = get_api()
    if not api then
        return false
    end
    local node = api.tree.get_node_under_cursor()
    if not node then
        return false
    end
    if node.type ~= "file" then
        state.last_path = nil
        close_preview_win()
        return false
    end
    if not force and node.absolute_path == state.last_path then
        if state.preview.win and vim.api.nvim_win_is_valid(state.preview.win) then
            return true
        end
    end
    state.last_path = node.absolute_path
    return render_file(node.absolute_path)
end

local function clear_tree_autocmds()
    safe_del_augroup(state.tree.augroup)
    state.tree.augroup = nil
    safe_del_autocmd(state.tree.win_autocmd)
    state.tree.win_autocmd = nil
end

handle_tree_closed = function()
    if not state.tree.is_open and not state.tree.bufnr then
        close_preview_win()
        return
    end
    close_preview_win()
    clear_tree_autocmds()
    state.tree.is_open = false
    state.tree.bufnr = nil
    state.tree.winid = nil
    state.last_path = nil
end

sync_tree_state = function()
    local api = get_api()
    if not api then
        handle_tree_closed()
        return
    end
    if api.tree.is_visible() then
        state.tree.is_open = true
        update_tree_win()
    else
        handle_tree_closed()
    end
end

local function attach_autocmds(bufnr)
    clear_tree_autocmds()
    local group = vim.api.nvim_create_augroup("NvimTreePreview" .. bufnr, { clear = true })
    state.tree.augroup = group
    vim.api.nvim_create_autocmd("CursorMoved", {
        group = group,
        buffer = bufnr,
        callback = function()
            if vim.api.nvim_get_current_buf() ~= state.tree.bufnr then
                return
            end
            render_node(false)
        end,
    })
    vim.api.nvim_create_autocmd("BufWipeout", {
        group = group,
        buffer = bufnr,
        callback = function()
            handle_tree_closed()
        end,
    })
end

local function subscribe_tree_events()
    if state.events_registered then
        return
    end
    local api = get_api()
    if not api then
        return
    end
    api.events.subscribe(api.events.Event.TreeOpen, function()
        sync_tree_state()
    end)
    api.events.subscribe(api.events.Event.TreeClose, function()
        handle_tree_closed()
    end)
    state.events_registered = true
end

function M.setup(opts)
    state.opts = vim.tbl_deep_extend("force", defaults, opts or {})
    subscribe_tree_events()
end

function M.set_layout(layout)
    state.preview.layout = layout
    if state.preview.win and vim.api.nvim_win_is_valid(state.preview.win) then
        close_preview_win()
        ensure_preview_win()
        render_node(true)
    end
end

function M.attach(api, bufnr)
    state.api = api or state.api
    state.tree.bufnr = bufnr
    track_tree_win(vim.api.nvim_get_current_win())
    attach_autocmds(bufnr)
    ensure_preview_win()
    sync_tree_state()
    render_node(true)
end

function M.focus()
    local ok = render_node(true)
    if not ok then
        return
    end
    local win = ensure_preview_win()
    if win then
        vim.api.nvim_set_current_win(win)
    end
end

function M.focus_tree()
    focus_tree_win()
end

function M.toggle_tree(opts)
    local api = get_api()
    if not api then
        return
    end
    api.tree.toggle(opts)
    sync_tree_state()
end

function M.close_tree()
    local api = get_api()
    if not api then
        handle_tree_closed()
        return
    end
    if not api.tree.is_visible() then
        handle_tree_closed()
        return
    end
    api.tree.close()
    handle_tree_closed()
end

function M.close()
    close_preview_win()
end

function M.sync_tree()
    sync_tree_state()
end

return M
