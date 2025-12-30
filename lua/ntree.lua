return {
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
}
