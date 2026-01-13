-- local discipline = require("craftzdog.discipline")
--
-- discipline.cowboy()

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Do things without affecting the registers
keymap.set("n", "x", '"_x')
keymap.set("n", "<Leader>p", '"0p')
keymap.set("n", "<Leader>P", '"0P')
keymap.set("v", "<Leader>p", '"0p')
keymap.set("n", "<Leader>c", '"_c')
keymap.set("n", "<Leader>C", '"_C')
keymap.set("v", "<Leader>c", '"_c')
keymap.set("v", "<Leader>C", '"_C')
keymap.set("n", "<Leader>d", '"_d')
keymap.set("n", "<Leader>D", '"_D')
keymap.set("v", "<Leader>d", '"_d')
keymap.set("v", "<Leader>D", '"_D')

-- Increment/decrement
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")

-- Delete a word backwards
keymap.set("n", "dw", 'vb"_d')

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- Save with root permission (not working for now)
--vim.api.nvim_create_user_command('W', 'w !sudo tee > /dev/null %', {})

-- Disable continuations
keymap.set("n", "<Leader>o", "o<Esc>^Da", opts)
keymap.set("n", "<Leader>O", "O<Esc>^Da", opts)

-- Jumplist
keymap.set("n", "<C-m>", "<C-i>", opts)

-- New tab
keymap.set("n", "te", ":tabedit")
keymap.set("n", "<tab>", ":tabnext<Return>", opts)
keymap.set("n", "<s-tab>", ":tabprev<Return>", opts)
-- Split window
keymap.set("n", "ss", ":split<Return>", opts)
keymap.set("n", "sv", ":vsplit<Return>", opts)
-- Move window
keymap.set("n", "sh", "<C-w>h")
keymap.set("n", "sk", "<C-w>k")
keymap.set("n", "sj", "<C-w>j")
keymap.set("n", "sl", "<C-w>l")

-- Resize window
keymap.set("n", "<C-w><left>", "<C-w><")
keymap.set("n", "<C-w><right>", "<C-w>>")
keymap.set("n", "<C-w><up>", "<C-w>+")
keymap.set("n", "<C-w><down>", "<C-w>-")

-- Diagnostics
keymap.set("n", "<C-j>", function()
	vim.diagnostic.goto_next()
end, opts)

keymap.set("n", "<leader>r", function()
	require("craftzdog.hsl").replaceHexWithHSL()
end)

keymap.set("n", "<leader>i", function()
	require("craftzdog.lsp").toggleInlayHints()
end)

vim.api.nvim_create_user_command("ToggleAutoformat", function()
	require("craftzdog.lsp").toggleAutoformat()
end, {})

-- Check if diff mode is enabled
if vim.opt.diff:get() then
	-- Define key mappings for diff mode
	vim.api.nvim_set_keymap("n", "<localleader>1", ":diffget LOCAL<CR>", { noremap = true, silent = true })
	vim.api.nvim_set_keymap("n", "<localleader>2", ":diffget BASE<CR>", { noremap = true, silent = true })
	vim.api.nvim_set_keymap("n", "<localleader>3", ":diffget REMOTE<CR>", { noremap = true, silent = true })
	-- parameter to fix the new default setting of neovim describe here https://github.com/neovim/neovim/issues/22696
	vim.o.diffopt = "internal,filler,closeoff"
end

vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*",
	callback = function()
		if vim.opt.diff:get() then
			local wk = require("which-key")
			local opts = {
				mode = "n", -- NORMAL mode
				buffer = vim.api.nvim_get_current_buf(), -- Specify a buffer number for buffer local mappings
			}
			local mappings = {
				["<localleader>"] = {
					["1"] = { ":diffget LOCAL<CR>", "Get LOCAL" },
					["2"] = { ":diffget BASE<CR>", "Get BASE" },
					["3"] = { ":diffget REMOTE<CR>", "Get REMOTE" },
				},
			}

			wk.register(mappings, opts)
		end
	end,
})
