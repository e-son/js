assert = require 'assert'
ESON = require '../build/eson'


describe 'stringify', ()->

  tokens = (s)-> s.split(/[\[\]{}:,\s ]+/)

  it 'should use toESON', ()->
    obj =
      toESON: ()->'ESONized'
    assert.deepEqual (ESON.stringify obj), '\"ESONized\"'

  it 'should use toJSON', ()->
    obj =
      toJSON: ()->'JSONized'
    assert.deepEqual (ESON.stringify obj), '\"JSONized\"'

  it 'should prefer toESON to toJSON', ()->
    obj =
      toJSON: ()->'JSONized'
      toESON: ()->'ESONized'
    assert.deepEqual (ESON.stringify obj), '\"ESONized\"'





