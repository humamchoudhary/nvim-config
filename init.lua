-- GENERAL SETTINGS
vim.opt.shiftwidth = 4
vim.g.mapleader = " "         -- Set leader key
vim.opt.nu = true             -- Line numbers
vim.opt.relativenumber = true -- Relative numbers
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.updatetime = 50
vim.opt.fsync = false
vim.opt.clipboard = "unnamedplus" -- Use system clipboard
vim.opt.fixeol = false            -- Don't add newline at end of file
vim.o.winhighlight = "Visual:Visual"
vim.opt.virtualedit = ""
vim.g.autoformat = false

-- HELP
vim.api.nvim_create_user_command("HKL", "help keymap-help", {})



vim.diagnostic.config({
    virtual_text = true, -- show inline messages
    signs = true,      -- show gutter signs
    underline = true,  -- show underline
    update_in_insert = false,
    severity_sort = true,
    float = { border = "rounded" },
})

-- LAZY INSTALLATION
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- PLUGINS
local plugins = {
    {
        "linux-cultist/venv-selector.nvim",
        dependencies = {
            "neovim/nvim-lspconfig",
            { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } },
        },
        ft = "python",
        opts = {
            search = {},
            options = {}
        },
    },

    { "neovim/nvim-lspconfig" },

    {
        "catgoose/nvim-colorizer.lua",
        event = "BufReadPre",
        opts = {},
    },

    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

    {
        "nvim-lualine/lualine.nvim",
        config = function()
            require('lualine').setup {
                options = {
                    theme = {
                        normal = { a = { fg = '#e0e0e0', bg = '#050505' },
                            b = { fg = '#c0c0c0', bg = '#050505' },
                            c = { fg = '#888888', bg = '#050505' },
                        },
                        insert = { a = { fg = '#50fa7b', bg = '#050505' } },
                        visual = { a = { fg = '#ff79c6', bg = '#050505' } },
                        replace = { a = { fg = '#ff5555', bg = '#050505' } },
                    },
                    component_separators = '|',
                    section_separators = '',
                }
            }
        end,
    },

    {
        "goolord/alpha-nvim",
        event = "VimEnter",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = function()
            local dashboard = require("alpha.themes.dashboard")
            require("alpha.term")
            local arttoggle = false

            local logo = {
                [[                                                    ]],
                [[ ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ]],
                [[ ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ]],
                [[ ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ]],
                [[ ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ]],
                [[ ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ]],
                [[ ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ]],
                [[                                                    ]],
            }

            local art = {
                { "tohru", 62, 17 },
            }

            if arttoggle == true then
                dashboard.opts.opts.noautocmd = true
                dashboard.section.terminal.opts.redraw = true
                local path = vim.fn.stdpath("config") .. "/assets/"
                local currentart = art[1]
                dashboard.section.terminal.command = "cat " .. path .. currentart[1]
                dashboard.section.terminal.width = currentart[2]
                dashboard.section.terminal.height = currentart[3]
                dashboard.opts.layout = {
                    dashboard.section.terminal,
                    { type = "padding", val = 2 },
                    dashboard.section.buttons,
                    dashboard.section.footer,
                }
            else
                dashboard.section.header.val = logo
            end

            dashboard.section.buttons.val = {
                dashboard.button("f", " " .. "Find files", ":Telescope find_files <CR>"),
            }

            for _, button in ipairs(dashboard.section.buttons.val) do
                button.opts.hl = "AlphaButtons"
                button.opts.hl_shortcut = "AlphaShortcut"
            end

            dashboard.section.header.opts.hl = "Function"
            dashboard.section.buttons.opts.hl = "Identifier"
            dashboard.section.footer.opts.hl = "Function"
            dashboard.opts.layout[1].val = 4
            return dashboard
        end,
        config = function(_, dashboard)
            if vim.o.filetype == "lazy" then
                vim.cmd.close()
                vim.api.nvim_create_autocmd("User", {
                    pattern = "AlphaReady",
                    callback = function()
                        require("lazy").show()
                    end,
                })
            end

            require("alpha").setup(dashboard.opts)

            vim.api.nvim_create_autocmd("User", {
                pattern = "LazyVimStarted",
                callback = function()
                    local v = vim.version()
                    local dev = ""
                    if v.prerelease == "dev" then
                        dev = "-dev+" .. v.build
                    else
                        dev = ""
                    end
                    local version = v.major .. "." .. v.minor .. "." .. v.patch .. dev
                    local stats = require("lazy").stats()
                    local plugins_count = stats.loaded .. "/" .. stats.count
                    local ms = math.floor(stats.startuptime + 0.5)
                    local time = vim.fn.strftime("%H:%M:%S")
                    local date = vim.fn.strftime("%d.%m.%Y")
                    local line1 = " " .. plugins_count .. " plugins loaded in " .. ms .. "ms"
                    local line2 = "󰃭 " .. date .. "  " .. time
                    local line3 = " " .. version

                    local line1_width = vim.fn.strdisplaywidth(line1)
                    local line2Padded = string.rep(" ", (line1_width - vim.fn.strdisplaywidth(line2)) / 2) .. line2
                    local line3Padded = string.rep(" ", (line1_width - vim.fn.strdisplaywidth(line3)) / 2) .. line3

                    dashboard.section.footer.val = {
                        line1,
                        line2Padded,
                        line3Padded,
                    }
                    pcall(vim.cmd.AlphaRedraw)
                end,
            })
        end,
    },

    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy = false,
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup({
                renderer = {
                    highlight_git = true,
                    highlight_opened_files = "name",
                    indent_markers = { enable = true },
                },
            })

            local hl = vim.api.nvim_set_hl
            hl(0, "NvimTreeNormal", { bg = "#1e1e2e" })
            hl(0, "NvimTreeFolderName", { fg = "#89b4fa", bold = true })
            hl(0, "NvimTreeOpenedFolderName", { fg = "#f38ba8", italic = true })
            hl(0, "NvimTreeRootFolder", { fg = "#fab387", bold = true })
            hl(0, "NvimTreeIndentMarker", { fg = "#585b70" })
            hl(0, "NvimTreeGitDirty", { fg = "#f9e2af" })
            hl(0, "NvimTreeGitNew", { fg = "#a6e3a1" })
            hl(0, "NvimTreeGitDeleted", { fg = "#f38ba8" })
        end,
    },

    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.6",
        dependencies = {
            "nvim-lua/plenary.nvim",
            {
                "nvim-telescope/telescope-live-grep-args.nvim",
                version = "^1.0.0",
            },
        },
        cmd = "Telescope",
    },

    { "ThePrimeagen/harpoon",   dependencies = { "nvim-lua/plenary.nvim" } },

    {
        "VonHeikemen/lsp-zero.nvim",
        branch = "v3.x",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "neovim/nvim-lspconfig",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/nvim-cmp",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
    },

    { "meatballs/notebook.nvim" },

    {
        "akinsho/toggleterm.nvim",
        version = "*",
        config = function()
            require("toggleterm").setup({
                size = function(term)
                    if term.direction == "horizontal" then
                        return 15
                    elseif term.direction == "vertical" then
                        return vim.o.columns * 0.4
                    end
                end,
                open_mapping = false, -- We'll handle keybinds manually
                hide_numbers = true,
                shade_terminals = true,
                shading_factor = -1,
                start_in_insert = true,
                persist_size = true,
                direction = "float",
                close_on_exit = true,
                float_opts = {
                    border = "rounded",
                    width = function(term)
                        return math.floor(vim.o.columns * 0.8)
                    end,
                    height = function(term)
                        return math.floor(vim.o.lines * 0.8)
                    end,
                },
            })
        end,
    },

    { "folke/which-key.nvim",   event = "VeryLazy" },
    { "stevearc/conform.nvim",  cmd = { "ConformInfo" } },
    { "numToStr/Comment.nvim" },

    {
        "ray-x/go.nvim",
        dependencies = {
            "ray-x/guihua.lua",
            "neovim/nvim-lspconfig",
            "nvim-treesitter/nvim-treesitter",
        },
        opts = {},
        config = function(lp, opts)
            require("go").setup(opts)
            local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = "*.go",
                callback = function()
                    require('go.format').goimports()
                end,
                group = format_sync_grp,
            })
        end,
        event = { "CmdlineEnter" },
        ft = { "go", 'gomod' },
        build = ':lua require("go.install").update_all_sync()'
    },

    {
        "kndndrj/nvim-dbee",
        dependencies = { "MunifTanjim/nui.nvim" },
        build = function()
            require("dbee").install()
        end,
        config = function()
            require("dbee").setup({})
        end,
    },

    {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp",
        dependencies = { "rafamadriz/friendly-snippets" },
    },

    {
        "luckasRanarison/tailwind-tools.nvim",
        name = "tailwind-tools",
        build = ":UpdateRemotePlugins",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-telescope/telescope.nvim",
            "neovim/nvim-lspconfig",
        },
        opts = {
            server = {
                override = false,
            },
            document_color = {
                enabled = true,
                kind = "inline",
                inline_symbol = "󰝤 ",
                debounce = 200,
            },
        }
    },

    {
        "nyoom-engineering/oxocarbon.nvim",
        lazy = false,
        priority = 1000,
    },
    {
        "amrbashir/nvim-docs-view",
        lazy = true,
        cmd = "DocsViewToggle",
        opts = {
            position = "bottom",
        }
    },

    {
        "nvim-pack/nvim-spectre",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        config = function()
            require("spectre").setup()
        end,
    },

{
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    signs = {
      add          = { text = '┃' },
      change       = { text = '┃' },
      delete       = { text = '_' },
      topdelete    = { text = '‾' },
      changedelete = { text = '~' },
      untracked    = { text = '┆' },
    },
    signs_staged = {
      add          = { text = '┃' },
      change       = { text = '┃' },
      delete       = { text = '_' },
      topdelete    = { text = '‾' },
      changedelete = { text = '~' },
      untracked    = { text = '┆' },
    },
    signs_staged_enable = true,
    signcolumn = true,
    numhl      = false,
    linehl     = false,
    word_diff  = false,

    watch_gitdir = {
      follow_files = true
    },

    auto_attach = true,
    attach_to_untracked = false,

    current_line_blame = false,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = 'eol',
      delay = 1000,
      ignore_whitespace = false,
      virt_text_priority = 100,
      use_focus = true,
    },

    current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',

    sign_priority = 6,
    update_debounce = 100,
    status_formatter = nil,
    max_file_length = 40000,

    preview_config = {
      style = 'minimal',
      relative = 'cursor',
      row = 0,
      col = 1
    },
  },
}


}

require("lazy").setup(plugins)

vim.opt.termguicolors = true
vim.o.background = "dark"

-- Base colorscheme
vim.cmd("colorscheme oxocarbon")

require("colors")
require("colorizer").setup()
require("luasnip.loaders.from_vscode").lazy_load()

-- DOCVIEWER SETUP
require("docviewer").setup({
    width = 60,
    position = "right", -- or "left"
})

-- TELESCOPE CONFIG
local builtin = require("telescope.builtin")

-- NVIM TREE CONFIG
require("nvim-tree").setup({
    sort_by = "case_sensitive",
    view = {
        width = 30,
    },
    renderer = {
        group_empty = true,
    },
    filters = {
        dotfiles = false,
    },
    on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        local function opts(desc)
            return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end
        api.config.mappings.default_on_attach(bufnr)
    end,
})

-- TREESITTER CONFIG
require("nvim-treesitter.configs").setup({
    ensure_installed = { "c", "lua", "javascript", "html", "python", "go", "sql" },
    highlight = { enable = true },
    indent = { enable = false },
})

-- COMMENT CONFIG
require("Comment").setup()

-- LSP CONFIG
local lsp = require("lsp-zero").preset({})

lsp.on_attach(function(client, bufnr)
    -- LSP keymaps are now handled by which-key in keymaps.lua
end)

require("mason").setup({})
require("mason-lspconfig").setup({
    ensure_installed = { "lua_ls", "rust_analyzer", "pyright", "tailwindcss", "dockerls" },
    handlers = {
        function(server_name)
            require("lspconfig")[server_name].setup({})
        end,
        ["lua_ls"] = function()
            require("lspconfig").lua_ls.setup({
                settings = {
                    Lua = {
                        diagnostics = { globals = { "vim" } },
                    },
                },
            })
        end,
        ["tailwindcss"] = function()
            require("lspconfig").tailwindcss.setup({})
        end,
    },
})

lsp.setup()

-- AUTOCOMPLETE CONFIG
local cmp = require("cmp")
local cmp_select = { behavior = cmp.SelectBehavior.Select }

require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
    sources = {
        { name = "path" },
        { name = "nvim_lsp" },
        { name = "luasnip", keyword_length = 2 },
        { name = "buffer",  keyword_length = 3 },
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
        ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
        ["<C-y>"] = cmp.mapping.confirm({ select = true }),
        ["<C-Space>"] = cmp.mapping.complete(),
    }),
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },
})

-- AUTOFORMAT CONFIG (Conform)
require("conform").setup({
    formatters_by_ft = {
        lua = { "stylua" },
        python = { "black", "isort" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        htmldjango = { "djlint" },
        jinja = { "djlint" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
    },
    async = true,
    lsp_fallback = true,
    format_on_save = {
        timeout_ms = 5000,
        lsp_fallback = false,
    },
    timeout_ms = 5000,
})

-- JUPYTER NOTEBOOK (notebook.nvim) CONFIG
require("notebook").setup()

-- KEYBINDINGS - Load centralized keymap configuration
require("keymaps").setup()
