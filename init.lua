vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.winborder = "single"
vim.o.wrap = false
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.swapfile = false
vim.o.completeopt = "menu,menuone,noinsert,noselect"
vim.o.updatetime = 250
vim.g.mapleader = " "
vim.keymap.set('n', '<leader>o', ':update<CR> :source<CR>')
vim.keymap.set('n', '<leader>w', ':write<CR>')
vim.keymap.set('n', '<leader>q', ':quit<CR>')
vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format)
vim.keymap.set('n', '<Esc>', '<cmd>noh<CR>', { silent = true })
vim.g.closetag_filenames = '*.html,*.xhtml'
vim.pack.add({
		{src="https://github.com/nvim-lua/plenary.nvim"},
		{src="https://github.com/nvim-telescope/telescope.nvim"},
		{src="https://github.com/neovim/nvim-lspconfig"},
		{src="https://github.com/chomosuke/typst-preview.nvim"},
		{src="https://github.com/alvan/vim-closetag"},
		{src="https://github.com/uga-rosa/ccc.nvim"},
		{src="https://github.com/windwp/nvim-autopairs"}
})
require("nvim-autopairs").setup({})
require("ccc").setup({
	highlighter = { auto_enable = true, lsp = true },
})
vim.keymap.set('n', '<leader>cp', ":CccPick<CR>")
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client and client:supports_method('textDocument/completion', ev.buf) then
            local chars = {}
            for i = 32, 126 do table.insert(chars, string.char(i)) end
            client.server_capabilities.completionProvider.triggerCharacters = chars
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
        end
    end,
})
vim.api.nvim_create_autocmd('CursorHold', {
    callback = function()
        vim.diagnostic.open_float(nil, { focusable = false })
    end,
})
vim.keymap.set('i', '<Tab>', function()
  if vim.fn.pumvisible() == 1 then
    if vim.fn.complete_info().selected == -1 then
      return '<C-n><C-y>' 
    else
      return '<C-y>'       
    end
  else
    return '<Tab>'
  end
end, { expr = true })

require "telescope".setup({})
local builtin = require("telescope.builtin")
vim.keymap.set('n', '<leader>f', builtin.find_files, {desc = 'Telescope find files'})
vim.keymap.set('n', '<leader>g', builtin.live_grep, {desc = 'Telescope live grep'})
vim.keymap.set('n', '<leader>h', builtin.help_tags, {desc = 'Telescope help tags'})
vim.keymap.set('n', '<leader>b', builtin.buffers, {desc = 'Telescope buffers'})


vim.keymap.set('n', '<leader>cd', ":Ex<CR>")
vim.lsp.enable({"lua_ls", "tinymist", "clangd", "emmet_language_server" })
local runners = {
	cpp  = "c++ -std=c++23 -Wall -Wextra -g {file} -o {out} && {out}",
	c    = "cc -std=c17 -Wall -Wextra -g {file} -o {out} && {out}",
	rust = "rustc {file} -o {out} && {out}",
	java   = "java {file}",
	python = "python3 {file}",
	julia  = "julia {file}",
	lua    = "lua {file}",
	sh     = "sh {file}",
}

vim.keymap.set("n", "<leader>r", function()
  local cmd = runners[vim.bo.filetype]
  if not cmd then
    vim.notify("No runner for " .. vim.bo.filetype, vim.log.levels.WARN)
    return
  end

  vim.cmd("write")
  cmd = cmd:gsub("{file}", vim.fn.shellescape(vim.fn.expand("%:p")))
         :gsub("{out}",  vim.fn.shellescape(vim.fn.expand("%:p:r")))
   vim.cmd("botright 15split | terminal " .. cmd)
end, { desc = "Run current file" })
