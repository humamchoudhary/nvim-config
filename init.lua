-- KEYMAPpING
vim.opt.shiftwidth = 4
vim.g.mapleader = " "
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.updatetime = 0
vim.opt.fsync = false
-- HELP
vim.api.nvim_create_user_command('HK', 'help keymap-help', {})
-- LAZY CONFIG

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)



local plugins = {
    { "catppuccin/nvim",                 name = "catppuccin", priority = 1000 },
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.6',
        dependencies = { 'nvim-lua/plenary.nvim' },
        cmd = "Telescope", -- Lazy-load on Telescope command
    },
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        event = "VimEnter", -- Lazy-load on VimEnter
    },
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons", }
    },
    {
        'ThePrimeagen/harpoon',
        dependencies = { 'nvim-lua/plenary.nvim' }
    },
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "neovim/nvim-lspconfig",
        }
    },
    { 'neovim/nvim-lspconfig' },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/nvim-cmp' },
    { 'L3MON4D3/LuaSnip' },
}

local opts = {}

-- LAZY INIT
require("lazy").setup(plugins, opts)

-- THEME INIT
require("catppuccin").setup({
    flavour = "mocha",
    background = {
        light = "latte",
        dark = "mocha",
    },
})
vim.cmd.colorscheme "catppuccin"

-- TELESCOPE INIT
local builtin = require('telescope.builtin')
require("telescope").load_extension('harpoon')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fs', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fg', builtin.git_files, {})

vim.keymap.set("", '<C-s>', ":w<CR>")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzv")
vim.keymap.set("n", "N", "Nzzv")
vim.keymap.set("n", "<leader>f", function()
    vim.lsp.buf.format()
end)
vim.keymap.set('n', '<leader>e', ':NvimTreeFindFileToggle<CR>', {
    noremap = true
})
vim.keymap.set("n", "<leader><C-p>", "\"+p", { noremap = true })
vim.keymap.set("n", "<leader><C-P>", "\"+P", { noremap = true })
vim.keymap.set("n", "<C-a>", "ggVG")
vim.keymap.set("v", "<C-a>", "ggVG")
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>y", "\"+y")

vim.api.nvim_set_option_value("clipboard", "unnamed", {})

vim.keymap.set('n', '<leader>a', require("harpoon.mark").add_file, {})
vim.keymap.set('n', '<leader>m', require("harpoon.ui").toggle_quick_menu, {})
-- vim.keymap.set('n', '<leader>hm', require("harpoon.ui").toggle_quick_menu, {})
vim.keymap.set('n', '<leader>n', require("harpoon.ui").nav_next, {})
vim.keymap.set('n', '<leader>p', require("harpoon.ui").nav_prev, {})


-- TREESITTER
require("nvim-treesitter.install").prefer_git = true

local configs = require("nvim-treesitter.configs")
configs.setup({
    ensure_installed = { "c", "lua", "javascript", "html", "python", "go" },
    highlight = { enable = false },
    indent = { enable = false },
})


-- LUA LINE CONFIG
-- require('lualine').setup()
-- local nvim_tree = require('ntree')
-- nvim_tree.config()


local statusline = require('statusline')


statusline.setup()
-- SAVE Command
local function save_with_feedback()
    -- Get the current buffer number
    local bufnr = vim.api.nvim_get_current_buf()

    -- Get the current buffer's file name
    local filename = vim.api.nvim_buf_get_name(bufnr)

    -- Save the file
    local success, err = pcall(vim.cmd, 'write')

    if success then
        -- Get the number of lines in the buffer
        local line_count = vim.api.nvim_buf_line_count(bufnr)

        -- Create the output message
        local output = string.format('"%s" %dL, %dB written',
            vim.fn.fnamemodify(filename, ':t'),
            line_count,
            vim.fn.getfsize(filename))

        -- Print the output
        print(output)
    else
        -- If saving failed, print the error message
        print('Error saving file: ' .. err)
    end
end
vim.api.nvim_create_autocmd('LspAttach', {

    callback = function(event)
        local opts = { buffer = event.buf }

        vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set('n', '<leader>vws', function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set('n', '<leader>vd', function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set('n', '[d', function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set('n', ']d', function() vim.diagnostic.goto_prev() end, opts)
        vim.keymap.set('n', '<leader>vca', function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set('n', '<leader>vrr', function() vim.lsp.buf.references() end, opts)
        vim.keymap.set('n', '<leader>vrn', function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set('i', '<C-h>', function() vim.lsp.buf.signature_help() end, opts)
        vim.keymap.set('n', '<C-s>', function() save_with_feedback() end, opts)
        vim.keymap.set('i', '<C-s>', function() save_with_feedback() end, opts)
    end,
})

local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = { 'eslint' },
    handlers = {
        function(server_name)
            require('lspconfig')[server_name].setup({
                capabilities = lsp_capabilities,
            })
        end,
        lua_ls = function()
            require('lspconfig').lua_ls.setup({
                capabilities = lsp_capabilities,
                settings = {
                    Lua = {
                        runtime = {
                            version = 'LuaJIT'
                        },
                        diagnostics = {
                            globals = { 'vim' },
                        },
                        workspace = {
                            library = {
                                vim.env.VIMRUNTIME,
                            }
                        }
                    }
                }
            })
        end,
    }
})

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }

-- this is the function that loads the extra snippets to luasnip
-- from rafamadriz/friendly-snippets
require('luasnip.loaders.from_vscode').lazy_load()

cmp.setup({
    sources = {
        { name = 'path' },
        { name = 'nvim_lsp' },
        { name = 'luasnip', keyword_length = 2 },
        { name = 'buffer',  keyword_length = 3 },
    },
    mapping = cmp.mapping.preset.insert({
        ['<leader><C-p>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<leader><C-n>'] = cmp.mapping.select_next_item(cmp_select),
        ['<leader><C-y>'] = cmp.mapping.confirm({ select = true }),
        ['<leader><C-Space>'] = cmp.mapping.complete(),
    }),
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
})
