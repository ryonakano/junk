local map = vim.keymap.set

local options = {
  number = true,
  termguicolors = true, -- enable 24-bit color
  mouse = "",
  list = true,
  listchars = {
    tab = ">-",
    space = ".",
  },
  colorcolumn = "120",
  wildmode = "list:longest", -- shell-like completion
  clipboard = "unnamedplus", -- yank to the system clipboard
}

for k, v in pairs(options) do
  vim.opt[k] = v
end

vim.g.mapleader = " "

map({"n", "i"}, "<F1>", "<Nop>")

-- Toggle relative number. Originally from https://cohama.hateblo.jp/entry/2013/10/07/020453
-- C-U to remove all characters between the cursor position and the beginning of the line; see ":help c-CTRL-U"
map("n", "<F3>", ":<C-u>setlocal relativenumber!<CR>")
