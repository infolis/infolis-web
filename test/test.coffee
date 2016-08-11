test = require 'tape'
TSON = require 'tson'

# mod = require '../src'

testConfigLoading = (t) ->
	t.equals require('../src/config').port, 3000, 'Loaded from cwd'
	t.end()

tson = TSON.load __dirname + '/../data/infolis.tson'
console.log tson
test "Test config loading", testConfigLoading

# ALT: src/index.coffee
