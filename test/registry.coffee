assert = require 'assert'
ESON = require '../build/eson.js'


describe 'Registry', ()->

  beforeEach () -> ESON.tags = {}

  describe '#registerTag', ()->

    it 'should register a single tag', ()->
      f = (x) -> x
      ESON.registerTag('tg',f)
      assert.equal(ESON.tags.tg, f)

    it 'should register a single namespace', ()->
      n = {}
      ESON.registerTag('ns',n)
      assert.equal(ESON.tags.ns, n)

    it 'should register a filled namespace', ()->
      f = (x) -> x
      n = {tg: f}
      ESON.registerTag('ns',n)
      assert.equal(ESON.tags.ns.tg, f)

    it 'should register recursively', ()->
      f = (x) -> x
      ESON.registerTag('ns1',{})
      ESON.registerTag('ns1/ns2',{})
      ESON.registerTag('ns1/ns2/ns3',{})
      ESON.registerTag('ns1/ns2/ns3/tg',f)
      assert.equal(ESON.tags.ns1.ns2.ns3.tg, f)

    it 'should not create namespace', ()->
      f = (x) -> x
      ESON.registerTag('ns1',{})
      assert.throws (()->ESON.registerTag('ns1/ns2/ns3',{}))


  describe '#resolveTag', ()->

    it 'should resolve a single tag', ()->
      f = (x) -> x
      ESON.tags.tg = f
      assert.equal(ESON.resolveTag('tg'), f)

    it 'should resolve a single namespace', ()->
      n = {}
      ESON.tags.ns = n
      assert.equal(ESON.resolveTag('ns'), n)

    it 'should resolve recursively', ()->
      f = (x) -> x
      ESON.tags = {ns1 : {ns2: {ns3: {tg: f}}}}
      assert.equal(ESON.resolveTag('ns1/ns2/ns3/tg'), f)

    it 'should return undefined when child is not defined', ()->
      f = (x) -> x
      ESON.tags.ns1 = {}
      assert.equal(ESON.resolveTag('ns1/ns2'), undefined)

    it 'should fail when parent is not defined', ()->
      f = (x) -> x
      ESON.tags.ns1 = {}
      assert.throws (() -> ESON.resolveTag('ns1/ns2/ns3'))
