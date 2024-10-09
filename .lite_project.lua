local config = require 'core.config'

config.ignore_files = {
	"^%.git$", "^%.gitignore$",
	"^%.lite_project%.lua$", -- lol
}
