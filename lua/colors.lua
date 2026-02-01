-- Enable true colors

-- Normal & background
vim.cmd [[
    hi Normal guibg=#040404 guifg=#e0e0e0
    hi NormalNC guibg=#040404 guifg=#a0a0a0
    hi CursorLine guibg=#101010
    hi Visual guibg=#505050
]]

-- Line numbers
vim.cmd [[
    hi LineNr guifg=#888888 guibg=#040404
    hi SignColumn guifg=#888888 guibg=#040404
    hi CursorLineNr guifg=#c0c0c0 guibg=#101010
]]

-- Splits & borders
vim.cmd [[
    hi VertSplit guifg=#b0b0b0 guibg=#040404
    hi FloatBorder guifg=#b0b0b0 guibg=#040404
]]

-- Floating windows
vim.cmd [[
    hi NormalFloat guibg=#050505 guifg=#e0e0e0
]]

-- Statusline (default)
vim.cmd [[
    hi StatusLine guibg=#040404 guifg=#c0c0c0
    hi StatusLineNC guibg=#040404 guifg=#888888
]]

-- Telescope
vim.cmd [[
    hi TelescopeBorder guifg=#b0b0b0 guibg=#040404
    hi TelescopeNormal guibg=#040404 guifg=#e0e0e0
    hi TelescopePromptNormal guibg=#101010 guifg=#e0e0e0
    hi TelescopePromptBorder guifg=#b0b0b0 guibg=#101010
    hi TelescopePromptPrefix guifg=#ff79c6 guibg=#101010
    hi TelescopeSelection guibg=#222222 guifg=#e0e0e0
    hi TelescopeMatching guifg=#50fa7b guibg=#222222
    hi TelescopeResultsNormal guibg=#040404 guifg=#e0e0e0
    hi TelescopePreviewNormal guibg=#040404 guifg=#e0e0e0
    hi TelescopeResultsBorder guifg=#b0b0b0 guibg=#040404
    hi TelescopePreviewBorder guifg=#b0b0b0 guibg=#040404
]]

-- Nvim-Tree background
vim.cmd [[
    hi NvimTreeNormal guibg=#050505 guifg=#e0e0e0
    hi NvimTreeNormalNC guibg=#050505 guifg=#a0a0a0
]]

-- Nvim-Tree folder icons
vim.cmd [[
    hi NvimTreeFolderName guifg=#50fa7b
    hi NvimTreeOpenedFolderName guifg=#50fa7b
]]

-- Nvim-Tree file icons
vim.cmd [[
    hi NvimTreeFileName guifg=#e0e0e0
    hi NvimTreeExecFile guifg=#bd93f9
]]

-- Nvim-Tree root folder
vim.cmd [[
    hi NvimTreeRootFolder guifg=#ff79c6 guibg=#050505 gui=bold
]]

-- Nvim-Tree indent lines
vim.cmd [[
    hi NvimTreeIndentMarker guifg=#888888
]]

vim.cmd [[
    " Folders
    hi NvimTreeFolderName guifg=#888888
    hi NvimTreeOpenedFolderName guifg=#888888
    hi NvimTreeFolderIcon guifg=#888888
    hi NvimTreeOpenedFolderIcon guifg=#888888

    " Files
    hi NvimTreeFileName guifg=#cccccc
    hi NvimTreeExecFile guifg=#aaaaaa

    " Root folder
    hi NvimTreeRootFolder guifg=#bbbbbb gui=bold

    " Indent markers
    hi NvimTreeIndentMarker guifg=#777777
]]
