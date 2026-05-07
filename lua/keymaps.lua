-- lua/keymaps.lua
-- Centralized keymap configuration with which-key integration

local M = {}

M.setup = function()
    local wk = require("which-key")

    -- Set leader key first
    vim.g.mapleader = " "

    -- Register all keymaps with which-key
    wk.add({
        -- ============================================================================
        -- GENERAL / NORMAL MODE KEYBINDINGS
        -- ============================================================================
        { "<leader>ld",    "<cmd>DocsViewToggle<CR>",                                                      desc = "LSP Doc",                           mode = { "n" } },
        { "<C-s>",         function() require("keymaps").save_with_feedback() end,                         desc = "Save file",                         mode = { "n", "i" } },
        { "<C-d>",         "<C-d>zz",                                                                      desc = "Scroll down (centered)",            mode = "n" },
        { "<C-u>",         "<C-u>zz",                                                                      desc = "Scroll up (centered)",              mode = "n" },
        { "n",             "nzzv",                                                                         desc = "Next search result (centered)",     mode = "n" },
        { "N",             "Nzzv",                                                                         desc = "Previous search result (centered)", mode = "n" },
        { "<C-a>",         "ggVG",                                                                         desc = "Select all",                        mode = { "n", "v" } },
        { "<Tab>",         ":tabnext<CR>",                                                                 desc = "Next tab",                          mode = "n" },
        { "<S-Tab>",       ":tabprevious<CR>",                                                             desc = "Previous tab",                      mode = "n" },

        -- ============================================================================
        -- VISUAL MODE KEYBINDINGS
        -- ============================================================================
        { "J",             ":m '>+1<CR>gv=gv",                                                             desc = "Move line down",                    mode = "v" },
        { "K",             ":m '<-2<CR>gv=gv",                                                             desc = "Move line up",                      mode = "v" },

        -- ============================================================================
        -- TERMINAL MODE KEYBINDINGS
        -- ============================================================================
        { "<esc><esc>",    "<c-\\><c-n>",                                                                  desc = "Exit terminal mode",                mode = "t" },

        -- ============================================================================
        -- LEADER KEY GROUPS
        -- ============================================================================
        { "<leader>f",     group = "Find/Format" },
        { "<leader>ff",    "<cmd>Telescope find_files<CR>",                                                desc = "Find files" },
        { "<leader>fs",    "<cmd>Telescope live_grep<CR>",                                                 desc = "Live grep (fuzzy search)" },
        { "<leader>fg",    "<cmd>Telescope git_files<CR>",                                                 desc = "Git files" },
        { "<leader>fb",    "<cmd>Telescope current_buffer_fuzzy_find<CR>",                                 desc = "Buffer fuzzy find" },
        { "<leader>fv",    "<cmd>Telescope grep_string<CR>",                                               desc = "Grep string under cursor" },
        { "<leader>fa",    "<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>", desc = "Live grep with args" },
        -- { "<leader>f",     function() vim.lsp.buf.format() end,                                            desc = "Format file (LSP)",                 mode = "n" },
        { "<leader>f",     function() require("conform").format({ async = true }) end,                     desc = "Format file",                       mode = "n" },


        -- Spectre
        { "<leader>s",     group = "Spectre" }, -- top-level group for Spectre
        { "<leader>sr",    "<cmd>lua require('spectre').open()<CR>",                                       desc = "Open Spectre Search/Replace" },
        { "<leader>sf",    "<cmd>lua require('spectre').open_file_search()<CR>",                           desc = "Search in current file" },

        -- Clipboard operations
        { "<leader>y",     '"+y',                                                                          desc = "Yank to system clipboard",          mode = { "n", "v" } },
        { "<leader><C-p>", '"+p',                                                                          desc = "Paste from clipboard",              mode = { "n", "v" } },
        { "<leader><C-P>", '"+P',                                                                          desc = "Paste from clipboard (before)",     mode = { "n", "v" } },

        -- File tree
        { "<leader>e",     ":NvimTreeFindFileToggle<CR>",                                                  desc = "Toggle file explorer" },

        -- Harpoon
        { "<leader>a",     function() require("harpoon.mark").add_file() end,                              desc = "Harpoon: Add file" },
        { "<leader>m",     function() require("harpoon.ui").toggle_quick_menu() end,                       desc = "Harpoon: Menu" },
        { "<leader>n",     function() require("harpoon.ui").nav_next() end,                                desc = "Harpoon: Next" },
        { "<leader>p",     function() require("harpoon.ui").nav_prev() end,                                desc = "Harpoon: Previous" },

        -- Terminal

        -- Reload config
        { "<leader>r",     ":luafile $MYVIMRC<CR>",                                                        desc = "Reload Neovim config" },

        -- LSP keybindings group
        { "<leader>v",     group = "LSP" },
        { "<leader>vws",   function() vim.lsp.buf.workspace_symbol() end,                                  desc = "Workspace symbol" },
        { "<leader>vd",    function() vim.diagnostic.open_float() end,                                     desc = "Open diagnostics" },
        { "<leader>vca",   function() vim.lsp.buf.code_action() end,                                       desc = "Code action" },
        { "<leader>vrr",   function() vim.lsp.buf.references() end,                                        desc = "References" },
        { "<leader>vrn",   function() vim.lsp.buf.rename() end,                                            desc = "Rename" },

        -- Database (dbee)
        { "<leader>d",     group = "Database/Docs" },
        { "<leader>dd",    function() require("docviewer").toggle() end,                                   desc = "Toggle Documentation Viewer" },
        { "<leader>db",    "<cmd>Dbee<cr>",                                                                desc = "Open Dbee" },
        { "<leader>dbr",   "<cmd>DbeeBuffers<cr>",                                                         desc = "Show Dbee buffers" },
        { "<leader>dbc",   "<cmd>DbeeConnections<cr>",                                                     desc = "Show Dbee connections" },
        { "<leader>dbq",   "<cmd>DbeeQuery<cr>",                                                           desc = "Open query editor" },
        { "<leader>dbt",   "<cmd>DbeeTables<cr>",                                                          desc = "List all tables" },
        { "<leader>dbs",   "<cmd>DbeeSchemas<cr>",                                                         desc = "List schemas" },
        { "<leader>dbx",   "<cmd>DbeeDisconnect<cr>",                                                      desc = "Disconnect from DB" },

        -- Control sequences
        { "<leader><c-i>", "<esc>i",                                                                       desc = "Escape to insert" },
        { "<leader><c-n>", "<esc>n",                                                                       desc = "Escape to normal" },
        { "<leader><c-v>", "<esc>v",                                                                       desc = "Escape to visual" },

        -- ============================================================================
        -- GIT (Fugitive)
        -- ============================================================================
        { "<leader>g",     group = "Git" },
        { "<leader>gs",    "<cmd>Git<CR>",                                                                 desc = "Git status" },
        { "<leader>gw",    "<cmd>Gwrite<CR>",                                                              desc = "Git add (write)" },
        { "<leader>gc",    "<cmd>Git commit<CR>",                                                          desc = "Git commit" },
        { "<leader>gpl",   "<cmd>Git pull<CR>",                                                            desc = "Git pull" },
        { "<leader>gpu",   "<cmd>Git push<CR>",                                                            desc = "Git push" },
        { "<leader>gl",    "<cmd>Git log<CR>",                                                             desc = "Git log" },
        { "<leader>gb",    "<cmd>Git blame<CR>",                                                           desc = "Git blame" },
        { "<leader>gd",    "<cmd>Gdiffsplit<CR>",                                                          desc = "Git diff" },
        { "<leader>gbd",   "<cmd>Git branch -d",                                                           desc = "Delete branch" },

        -- ============================================================================
        -- HOP (Fast Navigation)
        -- ============================================================================
        { "<leader>h",     group = "Hop" },
        { "<leader>hw",    "<cmd>HopWord<CR>",                                                             desc = "Hop to word" },
        { "<leader>hl",    "<cmd>HopLine<CR>",                                                             desc = "Hop to line" },
        { "<leader>hc",    "<cmd>HopChar1<CR>",                                                            desc = "Hop to char" },
        { "<leader>hC",    "<cmd>HopChar2<CR>",                                                            desc = "Hop to 2 chars" },
        { "<leader>hp",    "<cmd>HopPattern<CR>",                                                          desc = "Hop to pattern" },
        { "s",             "<cmd>HopWord<CR>",                                                             desc = "Hop to word (quick)" },

        -- ============================================================================
        -- AERIAL (Tags/Code Outline)
        -- ============================================================================
        { "<leader>T",     group = "Tags/Outline" },
        { "<leader>To",    "<cmd>AerialToggle!<CR>",                                                       desc = "Toggle code outline" },
        { "<leader>Tn",    "<cmd>AerialNext<CR>",                                                          desc = "Next symbol" },
        { "<leader>Tp",    "<cmd>AerialPrev<CR>",                                                          desc = "Previous symbol" },
        { "<leader>TN",    "<cmd>AerialNextUp<CR>",                                                        desc = "Next symbol (up)" },
        { "<leader>TP",    "<cmd>AerialPrevUp<CR>",                                                        desc = "Previous symbol (up)" },
        { "<leader>Tf",    "<cmd>Telescope aerial<CR>",                                                    desc = "Find symbols" },

        -- ============================================================================
        -- FOLDING (nvim-ufo)
        -- ============================================================================
        { "zR",            function() require("ufo").openAllFolds() end,                                   desc = "Open all folds" },
        { "zM",            function() require("ufo").closeAllFolds() end,                                  desc = "Close all folds" },
        { "zr",            function() require("ufo").openFoldsExceptKinds() end,                           desc = "Open folds except kinds" },
        { "zm",            function() require("ufo").closeFoldsWith() end,                                 desc = "Close folds with" },
        { "zp",            function() local winid = require("ufo").peekFoldedLinesUnderCursor() end,       desc = "Peek fold" },

        -- ============================================================================
        -- NON-LEADER KEYBINDINGS
        -- ============================================================================
        -- LSP
        { "gd",            function() vim.lsp.buf.definition() end,                                        desc = "Go to definition" },
        { "K",             function() vim.lsp.buf.hover() end,                                             desc = "Hover documentation" },
        { "[d",            function() vim.diagnostic.goto_next() end,                                      desc = "Next diagnostic" },
        { "]d",            function() vim.diagnostic.goto_prev() end,                                      desc = "Previous diagnostic" },
        { "<C-h>",         function() vim.lsp.buf.signature_help() end,                                    desc = "Signature help",                    mode = "i" },

        -- Python venv
        { "ev",            "<cmd>VenvSelect<cr>",                                                          desc = "Select Python venv" },
    })

    -- Additional which-key configuration
    wk.setup({
        preset = "modern",
        delay = 500,
        plugins = {
            marks = true,
            registers = true,
            spelling = {
                enabled = true,
                suggestions = 20,
            },
            presets = {
                operators = true,
                motions = true,
                text_objects = true,
                windows = true,
                nav = true,
                z = true,
                g = true,
            },
        },
        win = {
            border = "rounded",
            padding = { 1, 2 },
        },
        layout = {
            spacing = 3,
        },
    })
end

-- Save function with feedback
M.save_with_feedback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    local filename = vim.api.nvim_buf_get_name(bufnr)
    local success, err = pcall(vim.cmd, "write")

    if success then
        local line_count = vim.api.nvim_buf_line_count(bufnr)
        local output = string.format(
            '"%s" %dL, %dB written',
            vim.fn.fnamemodify(filename, ":t"),
            line_count,
            vim.fn.getfsize(filename)
        )
        print(output)
    else
        print("Error saving file: " .. err)
    end
end

-- DISABLED: Custom floating terminal - replaced by toggleterm.nvim
-- Keeping code here for reference in case needed later
-- local state = {
--     floating = {
--         buf = -1,
--         win = -1,
--     }
-- }
--
-- local function create_floating_window(opts)
--     opts = opts or {}
--     local width = opts.width or math.floor(vim.o.columns * 0.8)
--     local height = opts.height or math.floor(vim.o.lines * 0.8)
--     local col = math.floor((vim.o.columns - width) / 2)
--     local row = math.floor((vim.o.lines - height) / 2)
--
--     local buf = nil
--     if vim.api.nvim_buf_is_valid(opts.buf) then
--         buf = opts.buf
--     else
--         buf = vim.api.nvim_create_buf(false, true)
--     end
--
--     local win_config = {
--         relative = "editor",
--         width = width,
--         height = height,
--         col = col,
--         row = row,
--         style = "minimal",
--         border = "rounded",
--     }
--
--     local win = vim.api.nvim_open_win(buf, true, win_config)
--     return { buf = buf, win = win }
-- end
--
-- M.toggle_terminal = function()
--     if not vim.api.nvim_win_is_valid(state.floating.win) then
--         state.floating = create_floating_window { buf = state.floating.buf }
--         if vim.bo[state.floating.buf].buftype ~= "terminal" then
--             vim.cmd.terminal()
--         end
--     else
--         vim.api.nvim_win_hide(state.floating.win)
--     end
-- end

return M
