assert = require 'assert'
ESON = require '../build/eson'


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
      assert.throws () ->
        ESON.registerTag('ns1/ns2/ns3',{})

    it 'should not rewrite namespace', ()->
      f = (x) -> x
      ESON.registerTag('ns1',{})
      ESON.registerTag('ns1/ns2',{})
      assert.throws () ->
        ESON.registerTag('ns1',{})
      assert.throws () ->
        ESON.registerTag('ns1/ns2',(x)->x)


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

    it 'should return undefined when parent is not defined', ()->
      f = (x) -> x
      ESON.tags.ns1 = {}
      assert.equal(ESON.resolveTag('ns1/ns2'), undefined)

  describe '#deleteTag', ()->

    it 'should delete existing tag', ()->
      ESON.tags.tg = (x) -> x
      ESON.deleteTag('tg')
      assert.deepEqual(ESON.tags, {})

    it 'should delete whole tree', ()->
      ESON.tags = {ns1 : {ns2: {ns3: {tg: (x)->x }}}}
      ESON.deleteTag('ns1/ns2')
      assert.deepEqual(ESON.tags.ns1, {})

    it 'should accept non-existing path', ()->
      ESON.tags = {ns1 : {ns2: {ns3: {tg: (x)->x }}}}
      ESON.deleteTag('ns1/ns2/ns3/ns4/tg')

