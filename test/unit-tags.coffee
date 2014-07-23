assert = require 'assert'
ESON = require '../build/eson'


describe 'parse', ()->

  f1 = (x)->
    return {tag:1, val:x}

  f2 = (x)->
    return {tag:2, val:x}

  before ()->
    ESON.registerTag 'tag1', f1
    ESON.registerTag 'tag2', f2

  it 'should handle tag', ()->
    obj = ESON.parse '#tag1 {}'
    assert.deepEqual obj, f1 {}

  it 'should handle recursive tags', ()->
    obj = ESON.parse '#tag1 #tag2 {}'
    assert.deepEqual obj, f1 f2 {}

  it 'should handle tag inside the list', ()->
    obj = ESON.parse '[#tag1 1, 2, #tag2 3]'
    assert.deepEqual obj, [(f1 1), 2, (f2 3)]

  it 'should handle tag inside the object', ()->
    obj = ESON.parse '{"a":#tag1 1, "b":2, "c":#tag2 3}'
    assert.deepEqual obj, {a: (f1 1), b: 2, c: (f2 3)}



describe 'stringify', ()->

  tokens = (s)-> s.split(/[\[\]{}:,\s ]+/)

  it 'should stringify tag', ()->
    s = ESON.stringify (new ESON.Tag 'lonely', 13)
    assert.deepEqual (tokens s), ['#lonely','13']

  it 'should stringify tag recursively', ()->
    s = ESON.stringify (new ESON.Tag '1', (new ESON.Tag '2', 3))
    assert.deepEqual (tokens s), ['#1','#2','3']

  it 'should stringify tag inside of something', ()->
    s = ESON.stringify [{x:(new ESON.Tag 'deep', 13)}]
    assert.deepEqual (tokens s), (tokens '[{"x":#deep 13}]')





