local vim = vim
local map = vim.keymap.set

--------------------------------------------------------------------------------
-- Load plugins
--------------------------------------------------------------------------------
vim.pack.add{
  -- dependencies
  { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/MunifTanjim/nui.nvim' },

  -- plugins
  { src = "https://github.com/nvim-neo-tree/neo-tree.nvim" },
  { src = "https://github.com/akinsho/bufferline.nvim" },
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
  { src = "https://github.com/EdenEast/nightfox.nvim" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },

  -- LSP
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/mason-org/mason.nvim' },
  { src = 'https://github.com/mason-org/mason-lspconfig.nvim' },
}

--------------------------------------------------------------------------------
-- Setup neo-tree
--------------------------------------------------------------------------------
-- Disable netrw in favor of neo-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("neo-tree").setup {
  filesystem = {
    filtered_items = {
      visible = false,
      hide_dotfiles = false,
      hide_gitignored = true,
    },
  },
}

map("n", "<Leader>e", ":Neotree toggle<CR>")

--------------------------------------------------------------------------------
-- Setup bufferline
--------------------------------------------------------------------------------
require("bufferline").setup {
  options = {
    diagnostics = "nvim_lsp",
    offsets = {
      {
        filetype = "neo-tree",
        text = "󰥨 File Explorer",
        text_align = "left",
        separator = true,
      }
    },
  },
}

map("n", "<Tab>", ":bnext<CR>")
map("n", "<S-Tab>", ":bprev<CR>")
map("n", "<Leader>w", ":bd<CR>")

--------------------------------------------------------------------------------
-- Setup lualine
--------------------------------------------------------------------------------
require("lualine").setup {
  options = {
    theme = "OceanicNext",
  },
}

--------------------------------------------------------------------------------
-- Setup nvim-treesitter
--------------------------------------------------------------------------------
require("nvim-treesitter").install {
  "vala",
  "lua",
}
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(args.match)
    if not lang then
      return
    end

    local parser = vim.treesitter.get_parser(args.buf, lang)
    if not parser then
      return
    end

    vim.treesitter.start(args.buf, lang)
  end,
})

--------------------------------------------------------------------------------
-- Setup nightfox
--------------------------------------------------------------------------------
vim.cmd("colorscheme nightfox")

--------------------------------------------------------------------------------
-- Setup gitsigns
--------------------------------------------------------------------------------
require("gitsigns").setup()

local lsp_list = {
  "vala_ls",
  "blueprint_ls",
}
vim.lsp.config("*", {})
vim.lsp.enable(lsp_list)

require("mason").setup()
require("mason-lspconfig").setup {
  ensure_installed = {
    "bashls",
    "lua_ls",
    "rust_analyzer",
  },
}

vim.opt.completeopt = { "menuone", "noselect", "noinsert" }
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    if client:supports_method("textDocument/completion") then
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end
  end,
})
