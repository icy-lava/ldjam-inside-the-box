std = '+love'
ignore = {'6[13]1', '212'}
globals = {
	'cli',
	'love.arg.parseGameArguments',
	'vector',
	'lume',
	'log',
	'vivid',
	'flux',
	'tiny',
	'inspect',
	'json',
	'bump',
	'roomy',
	'properties',
	'manager',
	'epsilon',
	'level',
}

for k in pairs(require 'util') do
	table.insert(globals, k)
end
