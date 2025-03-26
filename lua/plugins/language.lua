local lsp_keymaps = {
    { mode = "n",          key = "gR",         action = "<cmd>Telescope lsp_references<CR>",       desc = "Show LSP references" },
    { mode = "n",          key = "gD",         action = vim.lsp.buf.declaration,                   desc = "Go to declaration" },
    { mode = "n",          key = "gd",         action = "<cmd>Telescope lsp_definitions<CR>",      desc = "Show LSP definitions" },
    { mode = "n",          key = "gi",         action = "<cmd>Telescope lsp_implementations<CR>",  desc = "Show LSP implementations" },
    { mode = "n",          key = "gt",         action = "<cmd>Telescope lsp_type_definitions<CR>", desc = "Show LSP type definitions" },
    { mode = { "n", "v" }, key = "<leader>ca", action = vim.lsp.buf.code_action,                   desc = "See available code actions" },
    { mode = "n",          key = "<leader>rn", action = vim.lsp.buf.rename,                        desc = "Smart rename" },
    {
        mode = "n",
        key = "<leader>D",
        action = "<cmd>Telescope diagnostics bufnr=0<CR>",
        desc = "Show buffer diagnostics",
    },
    { mode = "n", key = "<leader>d",  action = vim.diagnostic.open_float, desc = "Show line diagnostics" },
    { mode = "n", key = "[d",         action = vim.diagnostic.goto_prev,  desc = "Go to previous diagnostic" },
    { mode = "n", key = "]d",         action = vim.diagnostic.goto_next,  desc = "Go to next diagnostic" },
    { mode = "n", key = "K",          action = vim.lsp.buf.hover,         desc = "Show documentation for what is under cursor" },
    { mode = "n", key = "<leader>rs", action = ":LspRestart<CR>",         desc = "Restart LSP" },
}

local languagePluginConfig = {
    -- Web/React Development
    web = {
        treesitter = { "html", "css", "javascript", "typescript", "tsx", "json" },
        formatter = {
            prettier = {
                filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "css", "html", "json" },
            }
        },
        linter = {
            eslint_d = {
                filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
            },
        },
        lsp = {
            html = {
                filetypes = { "html" },
            },
            cssls = {
                filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less" },
            },
            "tailwindcss",
            "tsserver",
            emmet_ls = {
                filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less" },
            },
        }
    },

    -- Lua/Neovim Development
    lua = {
        treesitter = { "lua", "vim", "vimdoc" },
        formatter = {
            stylua = {
                filetypes = { "lua" },
            }
        },
        linter = {
            luac = {
                filetypes = { "lua" },
            }
        },
        lsp = {
            lua_ls = {
                filetypes = { "lua" },
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { "vim" },
                        },
                        completion = {
                            callSnippet = "Replace",
                        },
                    },
                },
            }
        },
    },

    -- solidity development
    solidity = {
        treesitter = { "solidity" },
        formatter = {
            "solc",
        },
        linter = {
            "solhint"
        },
        lsp = {
            "solc",
        },
    },
}

local treesitter = {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
    build = ":TSUpdate",
    dependencies = {
        "windwp/nvim-ts-autotag",
    },
    opts = function()
        local ensure_installed = {}
        -- Extract treesitter parsers from language configs
        for _, lang_config in pairs(languagePluginConfig) do
            if lang_config.treesitter then
                for k, v in ipairs(lang_config.treesitter) do
                    if type(k) == "number" then
                        table.insert(ensure_installed, v)
                    else
                        table.insert(ensure_installed, k)
                    end
                end
            end
        end
        return {
            highlight = {
                enable = true,
            },
            -- Install parsers synchronously (only applied to `ensure_installed`)
            sync_install = false,
            -- ensure these language parsers are installed
            ensure_installed = ensure_installed,

            -- Automatically install missing parsers when entering buffer
            -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
            auto_install = true,

            -- enable indentation
            indent = { enable = true },

            -- enable autotagging (w/ nvim-ts-autotag plugin)
            autotag = { enable = true },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<C-space>",
                    node_incremental = "<C-space>",
                    scope_incremental = false,
                    node_decremental = "<bs>",
                },
            },
        }
    end,
}

-- autocompletion
local completion = {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
        "hrsh7th/cmp-buffer", -- source for text in buffer
        "hrsh7th/cmp-path",   -- source for file system paths
        {
            "L3MON4D3/LuaSnip",
            -- follow latest release.
            version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
            -- install jsregexp (optional!).
            -- build = "make install_jsregexp",
        },
        "saadparwaiz1/cmp_luasnip",     -- for autocompletion
        "rafamadriz/friendly-snippets", -- useful snippets
        "onsails/lspkind.nvim",         -- vs-code like pictograms
    },

    opts = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        local lspkind = require("lspkind")
        -- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
        require("luasnip.loaders.from_vscode").lazy_load()

        return {
            completion = {
                completeopt = "menu,menuone,preview,noselect",
            },
            snippet = { -- configure how nvim-cmp interacts with snippet engine
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
                ["<C-j>"] = cmp.mapping.select_next_item(), -- next suggestion
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
                ["<C-e>"] = cmp.mapping.abort(),        -- close completion window
                ["<Tab>"] = cmp.mapping.confirm({ select = false }),
            }),
            -- sources for autocompletion
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" }, -- snippets
                { name = "buffer" },  -- text within current buffer
                { name = "path" },    -- file system paths
            }),

            -- configure lspkind for vs-code like pictograms in completion menu
            formatting = {
                format = lspkind.cmp_format({
                    maxwidth = 50,
                    ellipsis_char = "...",
                }),
            },
        }
    end,
}

local mason = {
    "williamboman/mason.nvim",
    opts = {
        ui = {
            icons = {
                package_installed = "✓",
                package_pending = "➜",
                package_uninstalled = "✗",
            },
        },
    }
}

local mason_install_package = function(package_list)
    local mason_registry = require("mason-registry")
    for _, server_name in ipairs(package_list) do
        if not mason_registry.is_installed(server_name) and
            mason_registry.has_package(server_name) then
            vim.defer_fn(function()
                mason_registry.get_package(server_name):install()
            end, 0)
        end
    end
end

-- linter
local linter = {
    "mfussenegger/nvim-lint",
    dependencies = {
        mason,
    },
    event = { "BufReadPre", "BufNewFile" },
    keys = {
        {
            "<leader>l",
            function()
                require("lint").try_lint()
            end,
            mode = { "n" },
            desc = "Trigger linting for current file",
        },
    },
    config = function()
        local lint = require("lint")
        local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
            group = lint_augroup,
            callback = function()
                require("lint").try_lint()
            end,
        })
        -- extract linters from language configs
        local linter_conf = {}
        local needed_linter = {}
        -- Extract treesitter parsers from language configs
        for _, lang_config in pairs(languagePluginConfig) do
            if lang_config.linter then
                for k, v in ipairs(lang_config.linter) do
                    if type(k) == "number" then
                        table.insert(needed_linter, v)
                    else
                        table.insert(linter_conf, v)
                        table.insert(needed_linter, k)
                    end
                end
            end
        end
        mason_install_package(needed_linter)

        -- transform linter config to nvim-lint format
        -- filetype: linter with { languages } => language with { linters }

        --    eslint_d = {
        --        filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
        --    },

        local linters_by_ft = {}
        for linter, conf in ipairs(linter_conf) do
            if conf.filetypes then
                for _, ft in ipairs(conf.filetypes) do
                    if not linters_by_ft[ft] then
                        linters_by_ft[ft] = {}
                    end
                    table.insert(linters_by_ft[ft], linter)
                end
            end
        end

        lint.linters_by_ft = linters_by_ft
    end,
}

-- format
local formatter = {
    "stevearc/conform.nvim",
    dependencies = {
        mason,
    },
    event = { "BufReadPre", "BufNewFile" },
    keys = {
        {
            "<leader>mp",
            function()
                require("conform").format({
                    lsp_fallback = true,
                    async = false,
                    timeout_ms = 1000,
                })
            end,
            mode = { "n", "v" },
            desc = "Format file or range (in visual mode)",
        },
    },
    config = function()
        local needed_formatter = {}
        -- Extract treesitter parsers from language configs
        for _, lang_config in pairs(languagePluginConfig) do
            if lang_config.formatter then
                for k, v in ipairs(lang_config.formatter) do
                    if type(k) == "number" then
                        table.insert(needed_formatter, v)
                    else
                        table.insert(needed_formatter, k)
                    end
                end
            end
        end
        mason_install_package(needed_formatter)

        -- transform formatter config to conform format
        -- filetype: formatter with { languages } => language with { formatters }
        --    prettier = {
        --        filetypes = { "javascript", "typescript", "javascriptreact", "typescriptreact", "css", "html", "json" },
        --    },
        local formatter_by_ft = {}
        for _, lang_conf in pairs(languagePluginConfig) do
            if lang_conf.formatter then
                for formatter, conf in ipairs(lang_conf.formatter) do
                    if conf.filetypes then
                        for _, ft in ipairs(conf.filetypes) do
                            if not formatter_by_ft[ft] then
                                formatter_by_ft[ft] = {}
                            end
                            table.insert(formatter_by_ft[ft], formatter)
                        end
                    end
                end
            end
        end

        local conform = require("conform")
        conform.setup({
            formatters_by_ft = formatter_by_ft,
            default_format_opts = {
                lsp_format = "fallback",
            },
            format_on_save = {
                lsp_fallback = true,
                timeout_ms = 1000,
            },
            format_after_save = {
                enabled = true,
                timeout_ms = 1000,
            },
        })
    end,
}

-- language server protocol
local lsp = {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        { "antosha417/nvim-lsp-file-operations", config = true },
        { "folke/neodev.nvim",                   opts = {} },
        {
            "williamboman/mason-lspconfig.nvim", -- mason-lspconfig.nvim closes some gaps that exist between "mason.nvim" and "lspconfig".
            dependencies = { mason }
        },
        "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
        local mason_lspconfig = require("mason-lspconfig")
        mason_lspconfig.setup({
            -- Whether servers that are set up (via lspconfig) should be automatically installed if they're not already installed.
            -- This setting has no relation with the `ensure_installed` setting.
            automatic_installation = true,
        })

        -- used to enable autocompletion (assign to every lsp server config)
        local cmp_nvim_lsp = require("cmp_nvim_lsp")
        local capabilities = cmp_nvim_lsp.default_capabilities()
        local lspconfig = require("lspconfig")
        local lsp_handlers = {
            function(server_name)
                lspconfig[server_name].setup({
                    capabilities = capabilities,
                })
            end,
        }

        -- extract lsp servers from language configs
        local needed_lsp_servers = {}
        for _, lang_config in pairs(languagePluginConfig) do
            if lang_config.lsp then
                for k, v in ipairs(lang_config.lsp) do
                    if type(k) == "number" then
                        table.insert(needed_lsp_servers, v)
                    else
                        table.insert(needed_lsp_servers, k)
                    end
                end
            end
        end
        mason_install_package(needed_lsp_servers)

        -- transform lsp config to lspconfig format
        -- filetype: lsp with { languages } => language with { lsps }
        --    html = {
        --        filetypes = { "html" },
        --    },

        for _, lang_config in pairs(languagePluginConfig) do
            for lsp_name, custom_conf in ipairs(lang_config.lsp) do
                if type(lsp_name) == "string" then
                    lsp_handlers[lsp_name] = function()
                        -- Add any other default options here
                        local server_opts = {
                            capabilities = capabilities,
                        }

                        -- Merge custom config with server_opts
                        for key, value in pairs(custom_conf) do
                            server_opts[key] = value
                        end

                        -- Setup the server with the merged options
                        lspconfig[lsp_name].setup(server_opts)
                    end
                end
            end
        end
        mason_lspconfig.setup_handlers(lsp_handlers)

        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", {}),
            callback = function(ev)
                -- Apply all keymaps from the table
                local keymap = vim.keymap -- for conciseness
                for _, mapping in ipairs(lsp_keymaps) do
                    local opts = { buffer = ev.buf, silent = true, desc = mapping.desc }
                    keymap.set(mapping.mode, mapping.key, mapping.action, opts)
                end
            end,
        })

        -- Change the Diagnostic symbols in the sign column (gutter)
        local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end
    end,
}

local lsp_progress = {
    "linrongbin16/lsp-progress.nvim",
    dependencies = {
        "nvim-lualine/lualine.nvim", -- for status line integrations
    },
    opts = function()
        local ok, lualine = pcall(require, "lualine")
        if not ok then
            return {}
        end

        local lsp_progress_opts = {
            series_format = function(title, message, percentage, done)
                local builder = {}
                local has_title = false
                local has_message = false
                if title and title ~= "" then
                    table.insert(builder, title)
                    has_title = true
                end
                if message and message ~= "" then
                    table.insert(builder, message)
                    has_message = true
                end
                if percentage and (has_title or has_message) then
                    table.insert(builder, string.format("(%.0f%%)", percentage))
                end
                if done and (has_title or has_message) then
                    table.insert(builder, "- done")
                end
                -- return table.concat(builder, " ")
                return { msg = table.concat(builder, " "), done = done }
            end,
            client_format = function(client_name, spinner, series_messages)
                if #series_messages == 0 then
                    return nil
                end
                local builder = {}
                local done = true
                for _, series in ipairs(series_messages) do
                    if not series.done then
                        done = false
                    end
                    table.insert(builder, series.msg)
                end
                if done then
                    -- replace the check mark once done
                    spinner = "%#LspProgressMessageCompleted#✓%*"
                end
                return "[" .. client_name .. "] " .. spinner .. " " .. table.concat(builder, ", ")
            end,
        }

        local lsp_progress_status = require("lualine.component"):extend()

        function lsp_progress_status:init(options)
            lsp_progress_status.super.init(self, options)

            vim.api.nvim_create_augroup("lualine_lsp_progress_augroup", { clear = true })
            vim.api.nvim_create_autocmd("User", {
                group = "lualine_lsp_progress_augroup",
                pattern = "LspProgressStatusUpdated",
                callback = require("lualine").refresh,
            })
        end

        function lsp_progress_status:update_status()
            return require("lsp-progress").progress()
        end

        local lua_conf = lualine.get_config()

        if lua_conf.sections.lualine_c then
            table.insert(lua_conf.sections.lualine_c, lsp_progress_status)
        else
            lua_conf.sections.lualine_c = { lsp_progress_status }
        end
        lualine.setup(lua_conf)

        return lsp_progress_opts
    end,
}

local trouble = {
    "folke/trouble.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "folke/todo-comments.nvim",
    },
    opts = {
        focus = true,
    },
    cmd = "Trouble",
    keys = {
        { "<leader>xx", "<cmd>Trouble toggle <CR>",            desc = "Open/close trouble list" },
        { "<leader>xw", "<cmd>Trouble diagnostics toggle<CR>", desc = "Open trouble workspace diagnostics" },
        {
            "<leader>xd",
            "<cmd>Trouble diagnostics toggle filter.buf=0<CR>",
            desc = "Open trouble document diagnostics",
        },
        { "<leader>xq", "<cmd>Trouble quickfix toggle<CR>", desc = "Open trouble quickfix list" },
        { "<leader>xl", "<cmd>Trouble loclist toggle<CR>",  desc = "Open trouble location list" },
        { "<leader>xt", "<cmd>Trouble todo toggle<CR>",     desc = "Open todos in trouble" },
    },
}


return { treesitter, linter, formatter, lsp, completion, lsp_progress, trouble }
