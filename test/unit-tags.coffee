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

  it 'should throw error on non-existing tag', ()->
    assert.throws ()->
      ESON.parse '#lag1 {}'

  it 'should use default handler when provided', ()->
    obj = ESON.parse '#lag1 {}', f2
    assert.deepEqual obj, f2 {}



describe 'pure_parse', ()->

  it 'should ignore tag', ()->
    obj = ESON.pure_parse '#tag1 {}'
    assert.deepEqual obj, {}

  it 'should ignore recursive tags', ()->
    obj = ESON.pure_parse '#tag1 #tag2 {}'
    assert.deepEqual obj, {}

  it 'should ignore tag inside the list', ()->
    obj = ESON.pure_parse '[#tag1 1, 2, #tag2 3]'
    assert.deepEqual obj, [1, 2, 3]

  it 'should ignore tag inside the object', ()->
    obj = ESON.pure_parse '{"a":#tag1 1, "b":2, "c":#tag2 3}'
    assert.deepEqual obj, {a: 1, b: 2, c: 3}



describe 'struct_parse', ()->

  f1 = (x)->
    return (new ESON.Tag 'tag1', x)

  f2 = (x)->
    return (new ESON.Tag 'tag2', x)

  it 'should handle tag', ()->
    obj = ESON.struct_parse '#tag1 {}'
    assert(obj instanceof ESON.Tag)
    assert.deepEqual obj, f1 {}

  it 'should handle recursive tags', ()->
    obj = ESON.struct_parse '#tag1 #tag2 {}'
    assert.deepEqual obj, f1 f2 {}

  it 'should handle tag inside the list', ()->
    obj = ESON.struct_parse '[#tag1 1, 2, #tag2 3]'
    assert.deepEqual obj, [(f1 1), 2, (f2 3)]

  it 'should handle tag inside the object', ()->
    obj = ESON.struct_parse '{"a":#tag1 1, "b":2, "c":#tag2 3}'
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





