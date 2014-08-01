assert = require 'assert'
ESON = require '../build/eson'


describe '#core/datetime', ()->

  tokens = (s)-> s.split(/[\[\]{}:,\s ]+/)

  it 'should be parsed', ()->
    date = new Date()
    parsed = ESON.parse "#core/datetime \"#{date.toISOString()}\""
    assert parsed instanceof Date
    assert.equal +parsed, +date


  it 'should be stringified', ()->
    date = new Date()
    expected = "#core/datetime \"#{date.toISOString()}\""
    assert.equal (ESON.stringify date), expected


