local config = require 'core.config'

local extra_ignore_files = {
  '^%.lite_project%.lua$',
  '^%.gitignore$',
}

for _, f in ipairs(extra_ignore_files) do
	table.insert(config.ignore_files, f)
end
