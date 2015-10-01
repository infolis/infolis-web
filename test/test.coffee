test = require 'tape'

# mod = require '../src'

testConfigLoading = (t) ->
	t.equals require('../src/config').port, 3000, 'Loaded from cwd'
	t.end()

test "Test config loading", testConfigLoading

# ALT: src/index.coffee
