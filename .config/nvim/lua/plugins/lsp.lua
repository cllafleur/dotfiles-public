return {
	-- tools
	{
		"mason-org/mason.nvim",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, {
				"stylua",
				"selene",
				"luacheck",
				"shellcheck",
				"shfmt",
				"tailwindcss-language-server",
				"typescript-language-server",
				"css-lsp",
				"pyright",
				"omnisharp",
				"csharpier",
			})
			opts.automatic_installation = {
				exclude = {
					"ruff-lsp",
					"ruff_lsp",
				},
			}
		end,
	},
	--{ "nvim-neotest/neotest-plenary" },
	--{
	--	"Issafalcon/neotest-dotnet",
	--	opts = {
	--		discovery_root = "project",
	--		dotnet_additional_args = {
	--			"--no-restore",
	--			"--verbosity detailed",
	--		},
	--	},
	--},
	--{ "nvim-neotest/neotest-python" },
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"antoinemadec/FixCursorHold.nvim",
			"nvim-treesitter/nvim-treesitter",
			"Issafalcon/neotest-dotnet",
			"nvim-neotest/neotest-plenary",
			"nvim-neotest/neotest-python",
			"rouge8/neotest-rust",
		},
		opts = function()
			return {
				--log_level = 1,
				adapters = {
					require("neotest-plenary"),
					require("neotest-python"),
					require("neotest-rust")({
						args = { "--no-capture" },
						dap_adapter = "lldb",
					}),
					require("neotest-dotnet")({
						discovery_root = "solution",
						dap = {
							args = { justMyCode = false },
							adapter_name = "netcoredbg",
						},
						dotnet_additional_args = {
							"--no-restore",
							"--verbosity normal",
						},
					}),
					--{"neotest-dotnet", opts = { discovery_root = "solution"}},
				},
			}
		end,
	},

	-- lsp servers
	{
		"neovim/nvim-lspconfig",
		opts = {
			inlay_hints = { enabled = false },
			---@type lspconfig.options
			servers = {
				["*"] = {
					keys = {
						{
							"gd",
							function()
								-- DO NOT RESUSE WINDOW
								require("telescope.builtin").lsp_definitions({ reuse_win = false })
							end,
							desc = "Goto Definition",
							has = "definition",
						},
					},
				},
				ruff_lsp = {
					mason = false,
				},
				omnisharp = {
					--cmd = { "omnisharp" },
					root_dir = function(bufnr, on_dir)
						on_dir(vim.loop.cwd())
					end,
					settings = {
						RoslynExtensionsOptions = {
							EnableImportCompletion = true,
							EnableDecompilationSupport = true,
						},
					},
				},
				cssls = {},
				tailwindcss = {
					root_dir = function(...)
						return require("lspconfig.util").root_pattern(".git")(...)
					end,
				},
				tsserver = {
					root_dir = function(...)
						return require("lspconfig.util").root_pattern(".git")(...)
					end,
					single_file_support = false,
					settings = {
						typescript = {
							inlayHints = {
								includeInlayParameterNameHints = "literal",
								includeInlayParameterNameHintsWhenArgumentMatchesName = false,
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHints = false,
								includeInlayPropertyDeclarationTypeHints = true,
								includeInlayFunctionLikeReturnTypeHints = true,
								includeInlayEnumMemberValueHints = true,
							},
						},
						javascript = {
							inlayHints = {
								includeInlayParameterNameHints = "all",
								includeInlayParameterNameHintsWhenArgumentMatchesName = false,
								includeInlayFunctionParameterTypeHints = true,
								includeInlayVariableTypeHints = true,
								includeInlayPropertyDeclarationTypeHints = true,
								includeInlayFunctionLikeReturnTypeHints = true,
								includeInlayEnumMemberValueHints = true,
							},
						},
					},
				},
				html = {},
				yamlls = {
					settings = {
						yaml = {
							keyOrdering = false,
						},
					},
				},
				lua_ls = {
					-- enabled = false,
					single_file_support = true,
					settings = {
						Lua = {
							workspace = {
								checkThirdParty = false,
							},
							completion = {
								workspaceWord = true,
								callSnippet = "Both",
							},
							misc = {
								parameters = {
									-- "--log-level=trace",
								},
							},
							hint = {
								enable = true,
								setType = false,
								paramType = true,
								paramName = "Disable",
								semicolon = "Disable",
								arrayIndex = "Disable",
							},
							doc = {
								privateName = { "^_" },
							},
							type = {
								castNumberToInteger = true,
							},
							diagnostics = {
								disable = { "incomplete-signature-doc", "trailing-space" },
								-- enable = false,
								groupSeverity = {
									strong = "Warning",
									strict = "Warning",
								},
								groupFileStatus = {
									["ambiguity"] = "Opened",
									["await"] = "Opened",
									["codestyle"] = "None",
									["duplicate"] = "Opened",
									["global"] = "Opened",
									["luadoc"] = "Opened",
									["redefined"] = "Opened",
									["strict"] = "Opened",
									["strong"] = "Opened",
									["type-check"] = "Opened",
									["unbalanced"] = "Opened",
									["unused"] = "Opened",
								},
								unusedLocalExclude = { "_*" },
							},
							format = {
								enable = false,
								defaultConfig = {
									indent_style = "space",
									indent_size = "2",
									continuation_indent_size = "2",
								},
							},
						},
					},
				},
			},
			setup = {},
		},
	},
}
