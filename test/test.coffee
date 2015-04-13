test = require 'tape'

# mod = require '../src'

testConfigLoading = (t) ->
	t.equals require('../src/config').foo, 'bar', 'Loaded from cwd'
	t.end()

test "Test config loading", testConfigLoading

# ALT: src/index.coffee
