return {
	{
		"Davidyz/VectorCode",
		enabled = false,
		version = "*", -- optional, depending on whether you're on nightly or release
		--build = "uv tool upgrade vectorcode",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{
		"milanglacier/minuet-ai.nvim",
		enabled = false,
		dependencies = { "Davidyz/VectorCode" },
		config = function()
			require("vectorcode").setup({
				-- number of retrieved documents
				n_query = 1,
			})
			local has_vc, vectorcode_config = pcall(require, "vectorcode.config")
			local vectorcode_cacher = nil
			if has_vc then
				vectorcode_cacher = vectorcode_config.get_cacher_backend()
			end

			-- roughly equate to 2000 tokens for LLM
			local RAG_Context_Window_Size = 8000

			require("minuet").setup({
				blink = {
					enable_auto_complete = true,
				},
				notify = "debug",
				provider = "openai_fim_compatible",
				n_completions = 3, -- recommend for local model for resource saving
				-- I recommend beginning with a small context window size and incrementally
				-- expanding it, depending on your local computing power. A context window
				-- of 512, serves as an good starting point to estimate your computing
				-- power. Once you have a reliable estimate of your local computing power,
				-- you should adjust the context window to a larger value.
				context_window = 8000,
				request_timeout = 10,

				provider_options = {
					openai_fim_compatible = {
						-- For Windows users, TERM may not be present in environment variables.
						-- Consider using APPDATA instead.
						api_key = "TERM",
						name = "Ollama",
						end_point = "http://localhost:11434/v1/completions",
						model = "qwen2.5-coder:7b",
						stream = true,
						optional = {
							max_tokens = nil, --256,
							top_p = 0.9,
							stop = nil, --{ "\n\n" },
						},
						template = {
							prompt = function(context_before_cursor, _, _)
								local utils = require("minuet.utils")
								local language = utils.add_language_comment()
								local tab = utils.add_tab_comment()

								if has_vc then
									for _, file in ipairs(vectorcode_cacher.query_from_cache(0)) do
										prompt_message = prompt_message .. "<|file_sep|>" .. file.path .. "\n" .. file.document
									end
								end

								prompt_message = vim.fn.strcharpart(prompt_message, 0, RAG_Context_Window_Size)

								context_before_cursor = language .. "\n" .. prompt_message .. "\n" .. tab .. "\n" .. context_before_cursor

								return context_before_cursor
							end,
							suffix = function(_, context_after_cursor, _)
								return context_after_cursor
							end,
						},
					},
				},
				virtualtext = {
					auto_trigger_ft = { "*" },
					show_on_completion_menu = false,
					keymap = {
						-- accept whole completion
						accept = "<A-A>",
						-- accept one line
						accept_line = "<A-a>",
						-- accept n lines (prompts for number)
						-- e.g. "A-z 2 CR" will accept 2 lines
						accept_n_lines = "<A-z>",
						-- Cycle to prev completion item, or manually invoke completion
						prev = "<A-[>",
						-- Cycle to next completion item, or manually invoke completion
						next = "<A-]>",
						dismiss = "<A-e>",
					},
				},
			})
		end,
	},
	{
		"olimorris/codecompanion.nvim",
		opts = {
			send_code = true,
		},
		config = function()
			require("codecompanion").setup({
				interactions = {
					inline = { adapter = { name = "copilot", model = "gpt-5.4-mini" } },
					chat = { adapter = "copilot_acp" },
					-- chat = { adapter = { name = "copilot", model = "claude-sonnet-4.5" } },
					cmd = { adapter = { name = "copilot", model = "gpt-5.4-mini" } },
					cli = {
						adpater = "copilot_acp",
					},
				},
				memory = {
					opts = {
						chat = {
							enabled = true,
							default_memory = { "default" },
						},
					},
				},
				--prompt_library = require("plugins.extensions.companion-prompt-library").get_prompt_library(),
				adapters = {
					acp = {
						copilot_acp = function()
							return require("codecompanion.adapters").extend("copilot_acp", {
								defaults = { mcpServers = "inherit_from_config" },
							})
						end,
					},
					http = {
						gemini = function()
							return require("codecompanion.adapters").extend("gemini", {
								env = {
									api_key = os.getenv("GEMINI_API_KEY"),
								},
							})
						end,
						ollama_ctx_16k = function()
							return require("codecompanion.adapters").extend("ollama", {
								name = "ollama_ctx_16k",
								opts = {
									vision = true,
									stream = true,
								},
								schema = {
									model = {
										default = "qwen3:8b",
									},
									num_ctx = {
										default = 20000,
									},
									num_predict = { default = -1 },
									think = {
										default = false,
										--default = function(adapter)
										--	local model_name = adapter.model.name:lower()
										--	return vim.iter({ "qwen3" }):any(function(kw)
										--		return string.find(model_name, kw) ~= nil
										--	end)
										--end,
									},
								},
							})
						end,
						ollamactx30k_think = function()
							return require("codecompanion.adapters").extend("ollama", {
								name = "ollamactx30k_think",
								opts = {
									vision = true,
									stream = true,
								},
								schema = {
									model = {
										default = "qwen3:8b",
									},
									num_ctx = {
										default = 30960,
									},
									num_predict = { default = -1 },
									think = {
										default = false,
										--default = function(adapter)
										--	local model_name = adapter.model.name:lower()
										--	return vim.iter({ "qwen3" }):any(function(kw)
										--		return string.find(model_name, kw) ~= nil
										--	end)
										--end,
									},
								},
							})
						end,
						lmstudio = function()
							return require("codecompanion.adapters").extend("openai_compatible", {
								env = {
									url = "http://localhost:1234",
								},
							})
						end,
					},
				},
				extensions = {},
			})
		end,
		init = function()
			require("plugins.extensions.companion-notification").init()
		end,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"folke/noice.nvim",
			--"j-hui/fidget.nvim",
		},
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown", "codecompanion" },
	},
}
