-- lua/docviewer/init.lua
-- Documentation Viewer Plugin
-- A side panel for searching and viewing programming documentation

local M = {}
local api = vim.api
local buf, win
local search_buf, search_win
local panel_width = 60 -- characters width for the panel

-- State management
M.state = {
    is_open = false,
    current_doc = nil,
    search_history = {},
    bookmarks = {},
}

-- Configuration
M.config = {
    width = 60,
    position = "right", -- "left" or "right"
    search_engines = {
        devdocs = "https://devdocs.io/",
        mdn = "https://developer.mozilla.org/en-US/search?q=",
        python = "https://docs.python.org/3/search.html?q=",
        golang = "https://pkg.go.dev/search?q=",
    },
    default_engine = "devdocs",
}

-- Documentation sources configuration
M.doc_sources = {
    javascript = {
        name = "JavaScript (MDN)",
        url = "https://developer.mozilla.org/en-US/docs/Web/JavaScript",
        search_url = "https://developer.mozilla.org/en-US/search?q=",
    },
    python = {
        name = "Python 3",
        url = "https://docs.python.org/3/",
        search_url = "https://docs.python.org/3/search.html?q=",
    },
    lua = {
        name = "Lua",
        url = "https://www.lua.org/manual/5.4/",
        search_url = "https://www.lua.org/manual/5.4/",
    },
    go = {
        name = "Go",
        url = "https://pkg.go.dev/",
        search_url = "https://pkg.go.dev/search?q=",
    },
    rust = {
        name = "Rust",
        url = "https://doc.rust-lang.org/",
        search_url = "https://doc.rust-lang.org/std/?search=",
    },
    react = {
        name = "React",
        url = "https://react.dev/",
        search_url = "https://react.dev/?search=",
    },
}

-- Helper function to create a buffer
local function create_buffer(name, filetype)
    local new_buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_option(new_buf, 'bufhidden', 'wipe')
    api.nvim_buf_set_option(new_buf, 'buftype', 'nofile')
    api.nvim_buf_set_option(new_buf, 'swapfile', false)
    api.nvim_buf_set_option(new_buf, 'filetype', filetype)
    api.nvim_buf_set_name(new_buf, name)
    return new_buf
end

-- Helper function to set buffer lines with content
local function set_buffer_content(buffer, lines)
    api.nvim_buf_set_option(buffer, 'modifiable', true)
    api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
    api.nvim_buf_set_option(buffer, 'modifiable', false)
end

-- Create the main documentation panel
local function create_doc_panel()
    -- Calculate window dimensions
    local width = M.config.width
    local height = vim.o.lines - 4
    local row = 1
    local col = M.config.position == "right" and (vim.o.columns - width) or 0

    -- Create buffer for documentation content
    buf = create_buffer("DocViewer", "markdown")

    -- Window configuration
    local win_config = {
        relative = 'editor',
        width = width,
        height = height,
        col = col,
        row = row,
        style = 'minimal',
        border = 'rounded',
    }

    -- Create the window
    win = api.nvim_open_win(buf, true, win_config)
    
    -- Set window options
    api.nvim_win_set_option(win, 'wrap', true)
    api.nvim_win_set_option(win, 'linebreak', true)
    api.nvim_win_set_option(win, 'number', false)
    api.nvim_win_set_option(win, 'relativenumber', false)
    api.nvim_win_set_option(win, 'cursorline', true)

    -- Set up keybindings for the documentation buffer
    local opts = { noremap = true, silent = true, buffer = buf }
    vim.keymap.set('n', 'q', function() M.close() end, opts)
    vim.keymap.set('n', '<Esc>', function() M.close() end, opts)
    vim.keymap.set('n', '/', function() M.open_search() end, opts)
    vim.keymap.set('n', 's', function() M.open_search() end, opts)
    vim.keymap.set('n', 'r', function() M.refresh() end, opts)
    vim.keymap.set('n', '?', function() M.show_help() end, opts)
    
    return buf, win
end

-- Create search input window
local function create_search_window()
    local search_width = M.config.width - 4
    local search_height = 1
    local row = 2
    local col = M.config.position == "right" and (vim.o.columns - M.config.width + 2) or 2

    -- Create search buffer
    search_buf = create_buffer("DocSearch", "")
    api.nvim_buf_set_option(search_buf, 'modifiable', true)

    -- Search window configuration
    local search_win_config = {
        relative = 'editor',
        width = search_width,
        height = search_height,
        col = col,
        row = row,
        style = 'minimal',
        border = 'rounded',
    }

    -- Create search window
    search_win = api.nvim_open_win(search_buf, true, search_win_config)

    -- Set up search buffer keybindings
    local opts = { noremap = true, silent = true, buffer = search_buf }
    vim.keymap.set('i', '<CR>', function() M.execute_search() end, opts)
    vim.keymap.set('i', '<Esc>', function() M.close_search() end, opts)
    vim.keymap.set('n', '<Esc>', function() M.close_search() end, opts)

    -- Enter insert mode
    vim.cmd('startinsert')
end

-- Search for documentation
M.execute_search = function()
    local query = api.nvim_buf_get_lines(search_buf, 0, -1, false)[1] or ""
    
    if query == "" then
        M.close_search()
        return
    end

    -- Add to search history
    table.insert(M.state.search_history, query)

    -- Close search window
    M.close_search()

    -- Detect language from current buffer or use default
    local filetype = vim.bo.filetype
    local doc_source = M.doc_sources[filetype] or M.doc_sources.javascript

    -- Fetch documentation (simulated for now - we'll use curl)
    M.fetch_and_display(query, doc_source)
end

-- Fetch and display documentation
M.fetch_and_display = function(query, doc_source)
    -- First try offline docs
    local offline_docs = require('docviewer.offline_docs')
    local filetype = vim.bo.filetype
    local results = offline_docs.search(query, filetype)
    
    if results and #results > 0 then
        -- Found offline documentation
        M.display_offline_doc(results[1], query)
        return
    end
    
    -- Fallback to online search
    local loading_text = {
        "╔════════════════════════════════════════════════════════╗",
        "║                  DOCUMENTATION VIEWER                  ║",
        "╚════════════════════════════════════════════════════════╝",
        "",
        "🔍 Searching: " .. query,
        "📚 Source: " .. doc_source.name,
        "",
        "⏳ Searching offline documentation first...",
        "   No offline docs found, trying online...",
        "",
        "Please wait while we fetch the documentation.",
    }

    -- Show loading state
    if buf and api.nvim_buf_is_valid(buf) then
        set_buffer_content(buf, loading_text)
    end

    -- Check if curl is available
    local has_curl = vim.fn.executable('curl') == 1
    
    if not has_curl then
        M.show_no_tools_error(query, doc_source)
        return
    end

    -- Build search URL - use DevDocs API for better results
    local devdocs_url = string.format("https://devdocs.io/%s/index.json", filetype)
    
    -- Simple curl to get the page
    local cmd = string.format("curl -s '%s'", doc_source.search_url .. vim.fn.shellescape(query))

    vim.fn.jobstart(cmd, {
        stdout_buffered = true,
        on_stdout = function(_, data)
            if data and buf and api.nvim_buf_is_valid(buf) then
                -- Process the content
                local content = M.process_online_data(data, query, doc_source)
                set_buffer_content(buf, content)
                
                -- Store current doc
                M.state.current_doc = {
                    query = query,
                    source = doc_source,
                    content = content,
                }
            end
        end,
        on_exit = function(_, exit_code)
            if exit_code ~= 0 then
                M.show_fetch_error(query, doc_source)
            end
        end,
    })
end

-- Process markdown content
M.process_markdown = function(data, query, doc_source)
    local lines = {}
    
    -- Add header
    table.insert(lines, "╔════════════════════════════════════════════════════════╗")
    table.insert(lines, "║              DOCUMENTATION: " .. string.upper(query) .. string.rep(" ", 41 - #query) .. "║")
    table.insert(lines, "╚════════════════════════════════════════════════════════╝")
    table.insert(lines, "")
    table.insert(lines, "📚 Source: " .. doc_source.name)
    table.insert(lines, "🔗 URL: " .. doc_source.search_url .. query)
    table.insert(lines, "")
    table.insert(lines, string.rep("─", 58))
    table.insert(lines, "")

    -- Process fetched data
    if data and #data > 0 then
        for _, line in ipairs(data) do
            if line ~= "" then
                -- Clean up the line
                local cleaned = line:gsub("^%s+", ""):gsub("%s+$", "")
                if cleaned ~= "" then
                    table.insert(lines, cleaned)
                end
            end
        end
    else
        table.insert(lines, "No documentation found for: " .. query)
        table.insert(lines, "")
        table.insert(lines, "Try:")
        table.insert(lines, "• Different search terms")
        table.insert(lines, "• Press 's' to search again")
    end

    table.insert(lines, "")
    table.insert(lines, string.rep("─", 58))
    table.insert(lines, "")
    table.insert(lines, "💡 Press 's' to search | 'q' to close | '?' for help")

    return lines
end

-- Display offline documentation
M.display_offline_doc = function(doc, query)
    local lines = {}
    
    -- Add header
    table.insert(lines, "╔════════════════════════════════════════════════════════╗")
    local header_query = string.upper(query)
    local padding = math.max(0, 41 - #header_query)
    table.insert(lines, "║              DOCUMENTATION: " .. header_query .. string.rep(" ", padding) .. "║")
    table.insert(lines, "╚════════════════════════════════════════════════════════╝")
    table.insert(lines, "")
    table.insert(lines, "📚 Source: Offline Documentation")
    table.insert(lines, "📖 Topic: " .. doc.title)
    table.insert(lines, "")
    table.insert(lines, string.rep("─", 58))
    table.insert(lines, "")
    
    -- Add content
    for line in doc.content:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    
    table.insert(lines, "")
    table.insert(lines, string.rep("─", 58))
    table.insert(lines, "")
    table.insert(lines, "💡 Press 's' to search | 'q' to close | '?' for help")
    
    if buf and api.nvim_buf_is_valid(buf) then
        set_buffer_content(buf, lines)
        
        -- Store current doc
        M.state.current_doc = {
            query = query,
            source = { name = "Offline Docs" },
            content = lines,
        }
    end
end

-- Show error when tools are missing
M.show_no_tools_error = function(query, doc_source)
    local error_content = {
        "╔════════════════════════════════════════════════════════╗",
        "║                  TOOLS NOT FOUND                       ║",
        "╚════════════════════════════════════════════════════════╝",
        "",
        "❌ Cannot fetch online documentation",
        "",
        "Query: " .. query,
        "",
        "Required tools not found:",
        "• curl - for fetching web pages",
        "",
        "Installation:",
        "  Ubuntu/Debian: sudo apt install curl",
        "  MacOS: brew install curl",
        "  Arch: sudo pacman -S curl",
        "",
        "Alternative:",
        "• Use offline documentation (already searched)",
        "• Add more topics to offline_docs.lua",
        "",
        "💡 Press 's' to search again | 'q' to close",
    }
    
    if buf and api.nvim_buf_is_valid(buf) then
        set_buffer_content(buf, error_content)
    end
end

-- Show fetch error
M.show_fetch_error = function(query, doc_source)
    local error_content = {
        "╔════════════════════════════════════════════════════════╗",
        "║                  FETCH ERROR                           ║",
        "╚════════════════════════════════════════════════════════╝",
        "",
        "❌ Failed to fetch online documentation",
        "",
        "Query: " .. query,
        "Source: " .. doc_source.name,
        "",
        "Possible reasons:",
        "• Network connection issue",
        "• Documentation source unavailable",
        "• Request timeout",
        "",
        "What to try:",
        "• Check your internet connection",
        "• Try a different search term",
        "• Use offline documentation",
        "• Press 's' to search again",
        "",
        "💡 Tip: Add common topics to offline_docs.lua",
    }
    
    if buf and api.nvim_buf_is_valid(buf) then
        set_buffer_content(buf, error_content)
    end
end

-- Process online data
M.process_online_data = function(data, query, doc_source)
    local html_parser = require('docviewer.html_parser')
    local lines = {}
    
    -- Add header
    table.insert(lines, "╔════════════════════════════════════════════════════════╗")
    local header_query = string.upper(query)
    local padding = math.max(0, 34 - #header_query)
    table.insert(lines, "║         ONLINE DOCUMENTATION: " .. header_query .. string.rep(" ", padding) .. "║")
    table.insert(lines, "╚════════════════════════════════════════════════════════╝")
    table.insert(lines, "")
    table.insert(lines, "📚 Source: " .. doc_source.name)
    table.insert(lines, "🔗 URL: " .. doc_source.search_url .. query)
    table.insert(lines, "")
    table.insert(lines, string.rep("─", 58))
    table.insert(lines, "")
    
    -- Process HTML data
    if data and #data > 0 then
        -- Convert HTML lines to readable text
        local processed_lines = html_parser.process_html_lines(data)
        
        if processed_lines and #processed_lines > 0 then
            -- Limit to reasonable number of lines
            local max_lines = 100
            for i = 1, math.min(#processed_lines, max_lines) do
                local line = processed_lines[i]
                -- Wrap long lines
                if #line > 56 then
                    local wrapped = {}
                    for j = 1, #line, 56 do
                        table.insert(wrapped, line:sub(j, j + 55))
                    end
                    for _, wrapped_line in ipairs(wrapped) do
                        table.insert(lines, wrapped_line)
                    end
                else
                    table.insert(lines, line)
                end
            end
            
            if #processed_lines > max_lines then
                table.insert(lines, "")
                table.insert(lines, "... (content truncated)")
            end
        else
            table.insert(lines, "No readable content found in the response.")
            table.insert(lines, "")
            table.insert(lines, "Try:")
            table.insert(lines, "• Different search terms")
            table.insert(lines, "• Using offline documentation")
        end
    else
        table.insert(lines, "No data received from the server.")
        table.insert(lines, "")
        table.insert(lines, "Try:")
        table.insert(lines, "• Checking your internet connection")
        table.insert(lines, "• Different search terms")
        table.insert(lines, "• Using offline documentation")
    end
    
    table.insert(lines, "")
    table.insert(lines, string.rep("─", 58))
    table.insert(lines, "")
    table.insert(lines, "💡 Press 's' to search | 'q' to close | '?' for help")
    
    return lines
end

-- Open search window
M.open_search = function()
    if not search_win or not api.nvim_win_is_valid(search_win) then
        create_search_window()
    end
end

-- Close search window
M.close_search = function()
    if search_win and api.nvim_win_is_valid(search_win) then
        api.nvim_win_close(search_win, true)
        search_win = nil
    end
    if search_buf and api.nvim_buf_is_valid(search_buf) then
        api.nvim_buf_delete(search_buf, { force = true })
        search_buf = nil
    end
    
    -- Return focus to doc window if open
    if win and api.nvim_win_is_valid(win) then
        api.nvim_set_current_win(win)
    end
end

-- Show help
M.show_help = function()
    local help_content = {
        "╔════════════════════════════════════════════════════════╗",
        "║                  DOCVIEWER HELP                        ║",
        "╚════════════════════════════════════════════════════════╝",
        "",
        "KEYBINDINGS:",
        "  s, /        Open search",
        "  <Enter>     Execute search (in search mode)",
        "  q, <Esc>    Close panel",
        "  r           Refresh current documentation",
        "  ?           Show this help",
        "",
        "DOCUMENTATION SOURCES:",
        "  Automatically detected from file type:",
    }

    for ft, source in pairs(M.doc_sources) do
        table.insert(help_content, "  • " .. ft .. " → " .. source.name)
    end

    table.insert(help_content, "")
    table.insert(help_content, "USAGE:")
    table.insert(help_content, "  1. Press <leader>d to open panel")
    table.insert(help_content, "  2. Press 's' to search")
    table.insert(help_content, "  3. Type your query and press <Enter>")
    table.insert(help_content, "  4. Documentation will be displayed")
    table.insert(help_content, "")
    table.insert(help_content, "NOTE:")
    table.insert(help_content, "  • Requires 'curl' and 'pandoc' installed")
    table.insert(help_content, "  • Internet connection required")
    table.insert(help_content, "")
    table.insert(help_content, "Press any key to return to documentation")

    if buf and api.nvim_buf_is_valid(buf) then
        set_buffer_content(buf, help_content)
        
        -- Wait for keypress then restore previous content
        local opts = { noremap = true, silent = true, buffer = buf, once = true }
        vim.keymap.set('n', '<CR>', function() M.refresh() end, opts)
        for i = 97, 122 do -- a-z
            local char = string.char(i)
            vim.keymap.set('n', char, function() M.refresh() end, opts)
        end
    end
end

-- Refresh current documentation
M.refresh = function()
    if M.state.current_doc then
        M.fetch_and_display(M.state.current_doc.query, M.state.current_doc.source)
    else
        M.show_welcome()
    end
end

-- Show welcome screen
M.show_welcome = function()
    local welcome = {
        "╔════════════════════════════════════════════════════════╗",
        "║                  DOCUMENTATION VIEWER                  ║",
        "╚════════════════════════════════════════════════════════╝",
        "",
        "                    Welcome to DocViewer!",
        "",
        "  A powerful documentation search and viewer for Neovim",
        "",
        string.rep("─", 58),
        "",
        "QUICK START:",
        "  • Press 's' or '/' to search for documentation",
        "  • Press '?' to view all keybindings",
        "  • Press 'q' or <Esc> to close this panel",
        "",
        "SUPPORTED LANGUAGES:",
    }

    for ft, source in pairs(M.doc_sources) do
        table.insert(welcome, "  • " .. ft .. " (" .. source.name .. ")")
    end

    table.insert(welcome, "")
    table.insert(welcome, string.rep("─", 58))
    table.insert(welcome, "")
    table.insert(welcome, "💡 TIP: Documentation source is auto-detected from file type")
    table.insert(welcome, "")
    table.insert(welcome, "Press 's' to start searching!")

    if buf and api.nvim_buf_is_valid(buf) then
        set_buffer_content(buf, welcome)
    end
end

-- Toggle the documentation panel
M.toggle = function()
    if M.state.is_open then
        M.close()
    else
        M.open()
    end
end

-- Open the documentation panel
M.open = function()
    if not win or not api.nvim_win_is_valid(win) then
        create_doc_panel()
        M.show_welcome()
        M.state.is_open = true
    end
end

-- Close the documentation panel
M.close = function()
    -- Close search window if open
    M.close_search()
    
    -- Close main window
    if win and api.nvim_win_is_valid(win) then
        api.nvim_win_close(win, true)
        win = nil
    end
    
    -- Delete buffer
    if buf and api.nvim_buf_is_valid(buf) then
        api.nvim_buf_delete(buf, { force = true })
        buf = nil
    end
    
    M.state.is_open = false
end

-- Setup function
M.setup = function(opts)
    -- Merge user config with defaults
    M.config = vim.tbl_deep_extend('force', M.config, opts or {})
    
    -- Set panel width
    panel_width = M.config.width
end

return M
