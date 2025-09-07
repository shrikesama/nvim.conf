local M = {}

local function relpath(file)
    local uv = vim.loop
    local real_file = (uv.fs_realpath(file) or file)
    local cwd = vim.fn.getcwd(-1, -1)
    local real_cwd = (uv.fs_realpath(cwd) or cwd)

    local rel = vim.fn.fnamemodify(real_file, ":.")
    if rel == real_file then
        rel = vim.fn.fnamemodify(real_file, ":t")
    end
    return rel
end

function M.get_selected_location()
    local buf = vim.api.nvim_get_current_buf()
    local file_path = vim.api.nvim_buf_get_name(buf)
    if file_path == "" then
        vim.notify("No file associated with current buffer", vim.log.levels.WARN)
        return
    end

    local rel = relpath(file_path)

    local mode = vim.api.nvim_get_mode().mode           -- 更可靠
    local sline, eline
    if mode == "v" or mode == "V" or mode == "\22" then -- \22 == <C-v>
        local s = vim.fn.getpos("'<")
        local e = vim.fn.getpos("'>")
        sline, eline = s[2], e[2]
        if sline > eline then sline, eline = eline, sline end
    else
        local cur = vim.api.nvim_win_get_cursor(0)
        sline, eline = cur[1], cur[1]
    end

    local path_part = (rel == "." and "." or ("./" .. rel))
    local location = (sline == eline)
        and string.format("%s:%d", path_part, sline)
        or string.format("%s:%d-%d", path_part, sline, eline)

    -- 尝试写系统剪贴板与备用选择缓冲区
    pcall(vim.fn.setreg, "+", location)
    pcall(vim.fn.setreg, "*", location)

    if mode == "v" or mode == "V" or mode == "\22" then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
    end

    vim.notify("Location copied: " .. location, vim.log.levels.INFO)
    return location
end

-- ========= Plugin Configuration =========
local ai_assistant = {
    name = "ai-assistant",
    dir = vim.fn.stdpath("config"),
    lazy = true,
    keys = {
        { "<leader>al", function() M.get_selected_location() end, desc = "Get selected code location", mode = { "v" } },
    },
}

return { ai_assistant }
