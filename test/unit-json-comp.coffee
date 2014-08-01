assert = require 'assert'
ESON = require '../build/eson'
JSON_TEST_OBJECTS = require './helper-JSONs'


describe 'parse', ()->

  for f in JSON_TEST_OBJECTS.all
    x = f()

    it 'should be consistent with JSON.parse on JSON named '+x.name, ()->
      s = JSON.stringify(x.val)
      assert.deepEqual(ESON.parse(s),JSON.parse(s))


describe 'stringify', ()->

  for f in JSON_TEST_OBJECTS.all
    x = f()

    it 'should be consistent with JSON.stringify on JSON named '+x.name, ()->
      s = JSON.stringify(x.val)
      assert.equal(ESON.stringify(x.val),s)