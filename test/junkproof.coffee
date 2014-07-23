assert = require 'assert'
ESON = require '../build/eson.js'


describe 'parse', ()->

  it 'should not parse two values', ()->
    assert.throws ()->
      ESON.parse '{"name":"twin1"} {"name":"twin1"}'

  it 'should not parse empty tag', ()->
    assert.throws ()->
      ESON.parse '   #nothing    '

  it 'should not parse empty tag (multiplied)', ()->
    assert.throws ()->
      ESON.parse '#nothing #really'

  it 'should not parse empty tag (in list)', ()->
    assert.throws ()->
      ESON.parse '[5, #tag "tagged", #nothing , {}]'

  it 'should not parse empty tag (before close bracket)', ()->
    assert.throws ()->
      ESON.parse '{"some":"thing", "no":#thing }'

  it 'should not parse tagged key', ()->
    assert.throws ()->
      ESON.parse '{"some":"thing", #pre "tagged":"thing"}'

  it 'should not parse unclosed string', ()->
    assert.throws ()->
      ESON.parse '{"slash":"/", "backslash":"\\"}'

  it 'should not accept missing comma (in list)', ()->
    assert.throws ()->
      ESON.parse '[ 0, 1, 2 3, 4, 5]'

  it 'should not accept comma at the end of list', ()->
    assert.throws ()->
      ESON.parse '[ 0, 1, 2, 3, 4, ]'

  it 'should not accept unclosed list', ()->
    assert.throws ()->
      ESON.parse '[ 0, 1, 2, 3, 4'

  it 'should not accept reclosed list', ()->
    assert.throws ()->
      ESON.parse '[ 0, 1, 2, 3, 4 ]]'

  it 'should not accept missing comma (in object)', ()->
    assert.throws ()->
      ESON.parse '{ "0": 1, "2": 3 "4": 5}'

  it 'should not accept comma at the end of object', ()->
    assert.throws ()->
      ESON.parse '{ "0": 1, "2": 3, "4": 5,}'

  it 'should not accept unclosed object', ()->
    assert.throws ()->
      ESON.parse '{ "0": 1, "2": 3, "4": 5'

  it 'should not accept reclosed object', ()->
    assert.throws ()->
      ESON.parse '{ "0": 1, "2": 3, "4": 5}}'

  it 'should not accept missing semicolon', ()->
    assert.throws ()->
      ESON.parse '{ "0": 1, "2" 3, "4": 5}'

  it 'should not accept missing key / value', ()->
    assert.throws ()->
      ESON.parse '{ "0": 1, "2", "4": 5}'

  it 'should not accept missing key', ()->
    assert.throws ()->
      ESON.parse '{ "0": 1, :3 , "4": 5}'

  it 'should not accept missing value', ()->
    assert.throws ()->
      ESON.parse '{ "0": 1, "2": , "4": 5}'

  it 'should not accept random tokens', ()->
    assert.throws ()->
      ESON.parse '[ 0, true, "two", 3, four, 5]'








