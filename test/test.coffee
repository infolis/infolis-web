Async = require 'async'
test = require 'tapes'

mod = require '../src'

DEBUG=false
# DEBUG=true

testFunc = (t) ->
	Async.each [0,0,0], (number, cb) ->
		t.equals number, 0, 'Number is zero'
		cb()
	, () -> t.end()

test "Basic async each test", testFunc

# ALT: src/index.coffee
