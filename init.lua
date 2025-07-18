-- GENERAL SETTINGS
vim.opt.shiftwidth = 4
vim.g.mapleader = " " -- Set leader key
vim.opt.nu = true -- Line numbers
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
vim.opt.fixeol = false -- Don't add newline at end of file

vim.g.autoformat = false
-- HELP
vim.api.nvim_create_user_command("HKL", "help keymap-help", {})

vim.keymap.set("n", "<leader>r", ":luafile $MYVIMRC<CR>", { noremap = true, silent = true })

-- LAZY INSTALLATION
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

-- PLUGINS
local plugins = {

	{
		"catgoose/nvim-colorizer.lua",
		event = "BufReadPre",
		opts = { -- set to setup table
		},
	},

	{
		"catppuccin/nvim",
		lazy = false,
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				transparent_background = true,
			})
			vim.cmd.colorscheme("catppuccin")
		end,
	},
	{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

	{
		"nvim-lualine/lualine.nvim",
		config = function()
			require("lualine").setup({
				options = {
					theme = "iceberg_dark",
				},
			})
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
				-- { name, width, height }
				{ "tohru", 62, 17 },
			}

			if arttoggle == true then
				dashboard.opts.opts.noautocmd = true
				dashboard.section.terminal.opts.redraw = true
				local path = vim.fn.stdpath("config") .. "/assets/"
				-- local random = math.random(1, #art)
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
				dashboard.button("f", " " .. "Find files", ":Telescope find_files <CR>"),
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
					local line1 = " " .. plugins_count .. " plugins loaded in " .. ms .. "ms"
					local line2 = "󰃭 " .. date .. "  " .. time
					local line3 = " " .. version

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

	-- { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },

	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		lazy = false,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("nvim-tree").setup({
				renderer = {
					highlight_git = true,
					highlight_opened_files = "name",
					indent_markers = { enable = true },
				},
			})

			-- Custom highlights
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
				-- This will not install any breaking changes.
				-- For major updates, this must be adjusted manually.
				version = "^1.0.0",
			},
		},
		cmd = "Telescope",
	},
	{ "ThePrimeagen/harpoon", dependencies = { "nvim-lua/plenary.nvim" } },
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
	{ "meatballs/notebook.nvim" }, -- Jupyter Notebook support
	{ "folke/which-key.nvim", event = "VeryLazy" },
	{ "stevearc/conform.nvim", cmd = { "ConformInfo" } },
	{ "numToStr/Comment.nvim" },
}

require("lazy").setup(plugins)

require("colorizer").setup()

-- THEME INIT
require("catppuccin").setup({
	flavour = "mocha",
	background = {
		light = "latte",
		dark = "mocha",
	},

	custom_highlights = function(colors)
		return {
			Comment = { fg = colors.flamingo },
			TabLineSel = { bg = colors.pink },
			CmpBorder = { fg = colors.surface2 },
			Pmenu = { bg = colors.none },
		}
	end,

	integrations = {
		cmp = true,
		gitsigns = true,
		nvimtree = true,
		treesitter = true,
		notify = false,
		mini = {
			enabled = true,
			indentscope_color = "",
		},
	},

	treesitter = true,
})
vim.cmd.colorscheme("catppuccin")

-- TELESCOPE CONFIG

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>fa", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")

vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fs", builtin.live_grep, {})
vim.keymap.set("n", "<leader>fg", builtin.git_files, {})
vim.keymap.set("n", "<leader>fb", builtin.current_buffer_fuzzy_find, {})
vim.keymap.set("", "<leader>fv", builtin.grep_string, {})
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
-- HARPOON CONFIG
vim.keymap.set("n", "<leader>a", require("harpoon.mark").add_file, {})
vim.keymap.set("n", "<leader>m", require("harpoon.ui").toggle_quick_menu, {})
vim.keymap.set("n", "<leader>n", require("harpoon.ui").nav_next, {})
vim.keymap.set("n", "<leader>p", require("harpoon.ui").nav_prev, {})
-- TREESITTER CONFIG
require("nvim-treesitter.configs").setup({
	ensure_installed = { "c", "lua", "javascript", "html", "python", "go" },
	highlight = { enable = true },
	indent = { enable = false },
})

-- COMMENT CONFIG
require("Comment").setup()

local lsp = require("lsp-zero").preset({})

lsp.on_attach(function(client, bufnr)
	local opts = { buffer = bufnr, noremap = true, silent = true }
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
	vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
	vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
	vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
	vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
	vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
	vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
	vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
end)

-- Ensure the language servers are set up
require("mason").setup({})
require("mason-lspconfig").setup({
	ensure_installed = { "lua_ls", "rust_analyzer", "html" }, -- Add or remove language servers as needed
	handlers = {
		lsp.default_setup,
		lua_ls = function()
			local lua_opts = lsp.nvim_lua_ls()
			require("lspconfig").lua_ls.setup(lua_opts)
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
		{ name = "buffer", keyword_length = 3 },
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
		html = { "djlint", "prettier" },
		json = { "prettier" },
		yaml = { "prettier" },
		markdown = { "prettier" },
		-- Add more file types and formatters as needed
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

-- SAVE WITH FEEDBACK FUNCTION
local function save_with_feedback()
	-- Get the current buffer number
	local bufnr = vim.api.nvim_get_current_buf()

	-- Get the current buffer's file name
	local filename = vim.api.nvim_buf_get_name(bufnr)

	-- Save the file
	local success, err = pcall(vim.cmd, "write")

	if success then
		-- Get the number of lines in the buffer
		local line_count = vim.api.nvim_buf_line_count(bufnr)

		-- Create the output message
		local output = string.format(
			'"%s" %dL, %dB written',
			vim.fn.fnamemodify(filename, ":t"),
			line_count,
			vim.fn.getfsize(filename)
		)

		-- Print the output
		print(output)
	else
		-- If saving failed, print the error message
		print("Error saving file: " .. err)
	end
end
-- KEYBINDINGS
vim.keymap.set("", "<C-s>", function()
	save_with_feedback()
end) -- Save file
vim.keymap.set("i", "<C-s>", function()
	save_with_feedback()
end) -- Save file in insert mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv") -- Move line down in visual mode
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv") -- Move line up in visual mode
vim.keymap.set("n", "<C-d>", "<C-d>zz") -- Scroll down
vim.keymap.set("n", "<C-u>", "<C-u>zz") -- Scroll up
vim.keymap.set("n", "n", "nzzv") -- Center screen after search
vim.keymap.set("n", "N", "Nzzv") -- Center screen after reverse search
vim.keymap.set("n", "<leader>f", function()
	vim.lsp.buf.format()
end) -- Format file
vim.keymap.set("n", "<leader>e", ":NvimTreeFindFileToggle<CR>", { noremap = true }) -- Toggle NvimTree
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { noremap = true, desc = "Yank to system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader><C-p>", '"+p', { noremap = true, desc = "Paste from system clipboard" })
vim.keymap.set(
	{ "n", "v" },
	"<leader><C-P>",
	'"+P',
	{ noremap = true, desc = "Paste from system clipboard before cursor" }
)
vim.keymap.set("n", "<C-a>", "ggVG") -- Select all in normal mode
vim.keymap.set("v", "<C-a>", "ggVG") -- Select all in visual mode
vim.keymap.set("n", "<Tab>", ":tabnext<CR>", { noremap = true, silent = true }) -- Next tab
vim.keymap.set("n", "<S-Tab>", ":tabprevious<CR>", { noremap = true, silent = true }) -- Previous tab

-- GENERAL KEYMAPS
vim.keymap.set("", "<leader><c-i>", "<esc>i", {})
vim.keymap.set("", "<leader><c-n>", "<esc>n")
vim.keymap.set("", "<leader><c-v>", "<esc>v", {})
vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>", {})

-- WHICH-KEY CONFIG
require("which-key").setup()
