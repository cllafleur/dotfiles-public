return {
	{
		"Davidyz/VectorCode",
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
	--{
	--	"Kurama622/llm.nvim",
	--	enabled = false,
	--	dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
	--	cmd = { "LLMSessionToggle", "LLMSelectedTextHandler", "LLMAppHandler" },
	--	config = function()
	--		local tools = require("llm.tools")
	--		vim.fn.setenv("LLM_KEY", "")
	--		require("llm").setup({
	--			url = "http://localhost:11434/api/chat",
	--			model = "qwen2.5-coder:7b",
	--			api_type = "ollama",
	--			temperature = 0.3,
	--			top_p = 0.7,

	--			spinner = {
	--				text = {
	--					"|--",
	--					"-|-",
	--					"--|",
	--					"-|-",
	--				},
	--				hl = "Title",
	--			},
	--			prefix = {
	--				user = { text = "😃 ", hl = "Title" },
	--				assistant = { text = "  ", hl = "Added" },
	--			},

	--			history_path = "/tmp/llm-history",
	--			save_session = true,
	--			max_history = 15,
	--			max_history_name_length = 20,

	--      -- stylua: ignore
	--      keys = {
	--        -- The keyboard mapping for the input window.
	--        ["Input:Submit"]      = { mode = "n", key = "<cr>" },
	--        ["Input:Cancel"]      = { mode = {"n", "i"}, key = "<C-c>" },
	--        ["Input:Resend"]      = { mode = {"n", "i"}, key = "<C-r>" },

	--        -- only works when "save_session = true"
	--        ["Input:HistoryNext"] = { mode = {"n", "i"}, key = "<C-j>" },
	--        ["Input:HistoryPrev"] = { mode = {"n", "i"}, key = "<C-k>" },

	--        -- The keyboard mapping for the output window in "split" style.
	--        ["Output:Ask"]        = { mode = "n", key = "i" },
	--        ["Output:Cancel"]     = { mode = "n", key = "<C-c>" },
	--        ["Output:Resend"]     = { mode = "n", key = "<C-r>" },

	--        -- The keyboard mapping for the output and input windows in "float" style.
	--        ["Session:Toggle"]    = { mode = "n", key = "<leader>ac" },
	--        ["Session:Close"]     = { mode = "n", key = {"<esc>", "Q"} },

	--        -- Scroll
	--        ["PageUp"]            = { mode = {"i","n"}, key = "<C-b>" },
	--        ["PageDown"]          = { mode = {"i","n"}, key = "<C-f>" },
	--        ["HalfPageUp"]        = { mode = {"i","n"}, key = "<C-u>" },
	--        ["HalfPageDown"]      = { mode = {"i","n"}, key = "<C-d>" },
	--        ["JumpToTop"]         = { mode = "n", key = "gg" },
	--        ["JumpToBottom"]      = { mode = "n", key = "G" },
	--      },

	--			app_handler = {
	--				Completion = {
	--					handler = tools.completion_handler,
	--					opts = {
	--						url = "http://localhost:11434/v1/completions",
	--						model = "qwen2.5-coder:7b",
	--						api_type = "ollama",
	--						n_completions = 3,
	--						context_window = 512,
	--						max_tokens = 256,

	--						-- A mapping of filetype to true or false, to enable completion.
	--						filetypes = { sh = false },

	--						-- Whether to enable completion of not for filetypes not specifically listed above.
	--						default_filetype_enabled = true,

	--						auto_trigger = true,

	--						-- just trigger by { "@", ".", "(", "[", ":", " " } for `style = "nvim-cmp"`
	--						only_trigger_by_keywords = true,

	--						style = "virtual_text", -- nvim-cmp or blink.cmp

	--						timeout = 10, -- max request time

	--						-- only send the request every x milliseconds, use 0 to disable throttle.
	--						throttle = 1000,
	--						-- debounce the request in x milliseconds, set to 0 to disable debounce
	--						debounce = 400,
	--						keymap = {
	--							virtual_text = {
	--								accept = {
	--									mode = "i",
	--									keys = "<C-l>",
	--								},
	--								next = {
	--									mode = "i",
	--									keys = "<A-n>",
	--								},
	--								prev = {
	--									mode = "i",
	--									keys = "<A-p>",
	--								},
	--								toggle = {
	--									mode = "n",
	--									keys = "<leader>cp",
	--								},
	--							},
	--						},
	--					},
	--				},
	--			},
	--		})
	--	end,
	--	keys = {
	--		{ "<leader>ac", mode = "n", "<cmd>LLMSessionToggle<cr>" },
	--	},
	--},
	{
		"olimorris/codecompanion.nvim",
		opts = {
			send_code = true,
		},
		config = function()
			require("codecompanion").setup({
				strategies = {
					inline = { adapter = { name = "copilot", model = "gpt-5-mini" } },
					chat = { adapter = { name = "copilot", model = "gpt-5-mini" } },
					-- chat = { adapter = { name = "copilot", model = "claude-sonnet-4.5" } },
					cmd = { adapter = { name = "copilot", model = "gpt-5-mini" } },
				},
				memory = {
					opts = {
						chat = {
							enabled = true,
							default_memory = { "default" },
						},
					},
				},
				prompt_library = require("plugins.extensions.companion-prompt-library").get_prompt_library(),
				adapters = {
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
									default = 24000,
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
					ollamactx40k_think = function()
						return require("codecompanion.adapters").extend("ollama", {
							name = "ollamactx40k_think",
							opts = {
								vision = true,
								stream = true,
							},
							schema = {
								model = {
									default = "qwen3:8b",
								},
								num_ctx = {
									default = 40960,
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
				extensions = {
					vectorcode = {
						---@type VectorCode.CodeCompanion.ExtensionOpts
						opts = {
							tool_group = {
								-- this will register a tool group called `@vectorcode_toolbox` that contains all 3 tools
								enabled = true,
								-- a list of extra tools that you want to include in `@vectorcode_toolbox`.
								-- if you use @vectorcode_vectorise, it'll be very handy to include
								-- `file_search` here.
								extras = {},
								collapse = false, -- whether the individual tools should be shown in the chat
							},
							tool_opts = {
								---@type VectorCode.CodeCompanion.ToolOpts
								["*"] = {},
								---@type VectorCode.CodeCompanion.LsToolOpts
								ls = {},
								---@type VectorCode.CodeCompanion.VectoriseToolOpts
								vectorise = {},
								---@type VectorCode.CodeCompanion.QueryToolOpts
								query = {
									max_num = { chunk = -1, document = 4 },
									default_num = { chunk = 50, document = 10 },
									include_stderr = false,
									use_lsp = true,
									no_duplicate = true,
									chunk_mode = true,
									---@type VectorCode.CodeCompanion.SummariseOpts
									summarise = {
										---@type boolean|(fun(chat: CodeCompanion.Chat, results: VectorCode.QueryResult[]):boolean)|nil
										enabled = false,
										adapter = nil,
										query_augmented = true,
									},
								},
								files_ls = {},
								files_rm = {},
							},
						},
					},
					mcphub = {
						callback = "mcphub.extensions.codecompanion",
						opts = {
							make_vars = true,
							make_slash_commands = true,
							show_result_in_chat = true,
						},
					},
				},
			})
			--local progress = require("fidget.progress")
			--local handles = {}
			--local group = vim.api.nvim_create_augroup("CodeCompanionFidget", {})

			--vim.api.nvim_create_autocmd("User", {
			--	pattern = "CodeCompanionRequestStarted",
			--	group = group,
			--	callback = function(e)
			--		handles[e.data.id] = progress.handle.create({
			--			title = "CodeCompanion",
			--			message = "Thinking...",
			--			lsp_client = { name = e.data.adapter.formatted_name },
			--		})
			--	end,
			--})

			--vim.api.nvim_create_autocmd("User", {
			--	pattern = "CodeCompanionRequestFinished",
			--	group = group,
			--	callback = function(e)
			--		local h = handles[e.data.id]
			--		if h then
			--			h.message = e.data.status == "success" and "Done" or "Failed"
			--			h:finish()
			--			handles[e.data.id] = nil
			--		end
			--	end,
			--})
		end,
		init = function()
			require("plugins.extensions.companion-notification").init()
		end,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"folke/noice.nvim",
			--"j-hui/fidget.nvim",
			"ravitemer/mcphub.nvim",
		},
	},
	{
		"ravitemer/mcphub.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		build = "bundled_build.lua",
		config = function()
			require("mcphub").setup({
				port = 37373,
				use_bundled_binary = true,
			})
		end,
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown", "codecompanion" },
	},
}
