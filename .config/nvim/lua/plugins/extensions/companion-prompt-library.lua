local M = {}
local constants = require("codecompanion.config").constants

function M.get_prompt_library()
	return {
		["Plan then execute"] = {
			strategy = "workflow",
			description = "Decompose complex tasks into smaller, manageable steps and execute them sequentially",
			opts = {
				index = 1,
				is_default = true,
				--short_name = "pw",
				adapter = {
					name = "copilot",
					model = "claude-sonnet-4.5",
				},
			},
			prompts = {
				{
					{
						role = constants.SYSTEM_ROLE,
						content = function(context)
							vim.g.codecompanion_yolo_mode = true
							return string.format(
								[[You carefully provide accurate, factual, thoughtful, nuanced answers, and are brilliant at reasoning.
If you think there might not be a correct answer, you say so.
Always spend a few sentences explaining background context, assumptions, and step-by-step thinking BEFORE
you try to answer a question. Don't be verbose in your answers,
but do provide details and examples where it might help the explanation.
You are an expert software engineer for the %s language]],
								context.filetype
							)
						end,
						opts = { visible = true },
					},
					{
						role = constants.USER_ROLE,
						content = [[
### Instructions



### Expectations

Make a plan of the code to add and to update to implement the feature describe in the `Instructions`.
You should provide details of the planned changed without to be too verbose.

- Provide a list of the file that you will update and create
- Provide a list of the classes and the interface to create with brieve with their responsabilities
- Don't forget to explain the changes that must be done on the database when it is relevent
- Provide a list of tests that should be implemented to cover the feature

You can use the following tools to browse the solution and analyze the code
- @{neovim__read_file}
- @{neovim__read_multiple_files}
- @{neovim__find_files}
- @{neovim__list_directory}
- @{cmd_runner}
- @{read_file}
- @{grep_search}

]],
						opts = { auto_submit = false },
					},
				},
				{
					{
						role = constants.USER_ROLE,
						content = [[
Use the plan from the preivous step to implement the feature and the tests when it is specified.
You can use the following tools to implement the solution
- @{insert_edit_into_file}
- @{neovim__insert_edit_into_file}
- @{cmd_runner}
- @{neovim}
- @{full_stack_dev}

]],
						opts = {
							adapter = {
								name = "copilot",
								model = "claude-sonnet-4.5",
							},
							auto_submit = false,
						},
					},
				},
				{
					{
						name = "Repeat On Failure",
						role = constants.USER_ROLE,
						opts = {
							adapter = {
								name = "copilot",
								model = "claude-sonnet-4.5",
							},
							auto_submit = true,
						},
						condition = function(context)
							return _G.codecompanion_current_tool == "cmd_runner"
						end,
						repeat_until = function(chat)
							return chat.tools.flags.testing == true
						end,
						content = [[If the previous commands failed, analyze the error messages and generate revised build and fix the failing code.]],
					},
				},
				{
					{
						role = constants.USER_ROLE,
						content = [[Now, generate the necessary documentation of the new features and the commit with a summary of the changes.]],
						opts = { auto_submit = true },
					},
				},
			},
		},
		["Code Build Test Document Commit"] = {
			strategy = "workflow",
			description = "Generate code build, test, document, and commit commands for the provided changes",
			opts = {
				index = 2,
				is_default = true,
				--short_name = "cw",
			},
			prompts = {
				{
					{
						role = constants.SYSTEM_ROLE,
						content = function(context)
							vim.g.codecompanion_yolo_mode = true
							return string.format(
								[[You carefully provide accurate, factual, thoughtful, nuanced answers, and are brilliant at reasoning.
                If you think there might not be a correct answer, you say so.
                Always spend a few sentences explaining background context, assumptions, and step-by-step thinking BEFORE
                you try to answer a question. Don't be verbose in your answers,
                but do provide details and examples where it might help the explanation.
                You are an expert software engineer for the %s language]],
								context.filetype
							)
						end,
						opts = { visible = true },
					},
					{
						role = constants.USER_ROLE,
						content = [[To execute the following request you use the tool @{insert_edit_into_file} and @{neovim}.

I want you to ]],
						opts = { auto_submit = false },
					},
				},
				{
					{
						role = constants.USER_ROLE,
						content = [[Now, generate the necessary commands to build and test there is no regression with @{cmd_runner}.
            Ensure that the commands are accurate and follow best practices for this programming language and its ecosystem.
            Provide only the commands without any additional explanations or commentary.]],
						opts = { auto_submit = true },
					},
				},
				{
					{
						name = "Repeat On Failure",
						role = constants.USER_ROLE,
						opts = { auto_submit = true },
						condition = function(context)
							return _G.codecompanion_current_tool == "cmd_runner"
						end,
						repeat_until = function(chat)
							return chat.tools.flags.testing == true
						end,
						content = [[If the previous commands failed, analyze the error messages and generate revised build and fix the failing code.]],
					},
				},
				{
					{
						role = constants.USER_ROLE,
						content = [[Now, generate the necessary unit tests to ensure the correctness of the implementation and to avoid future regression.
            Ensure that the tests are accurate and follow best practices for this programming language and its ecosystem.
            Provide only the tests with some additional explanations in comment of the tests.]],
						opts = { auto_submit = true },
					},
				},
				{
					{
						role = constants.USER_ROLE,
						content = [[Now, generate the necessary documentation of the new features and the commit with a summary of the changes.]],
						opts = { auto_submit = true },
					},
				},
			},
		},
	}
end

return M
