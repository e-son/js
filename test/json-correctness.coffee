assert = require 'assert'
ESON = require '../build/eson.js'
JSON_TEST_OBJECTS = require './JSON-test-objects'


describe 'Parsing JSON Objects', ()->

  for f in JSON_TEST_OBJECTS.all
    x = f()

    it 'should parse '+x.name, ()->
      s = JSON.stringify(x.val)
      assert.deepEqual(ESON.parse(s),x.val)


describe 'Stringify JSON Objects', ()->

  for f in JSON_TEST_OBJECTS.all
    x = f()

    it 'should stringify '+x.name, ()->
      s = JSON.stringify(x.val)
      assert.equal(ESON.stringify(x.val),s)