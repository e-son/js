ESON.js
=======

JavaScript [ESON](https://github.com/e-son/ESON/) implementation.


Documentation
-------------

Before reading this you should read
[ESON documentation](https://github.com/e-son/ESON/) .

### ESON.Tag class ###

ESON.Tag class is an official representation of ESON's tag construction.
It has properties `id` (tag identifier) and `data` (tagged value).
ESON.Tag is the only structure stringified to ESON tag construction.

    >>> tag = new ESON.Tag("happy",7)
    Tag {id: "happy", data: 7}
    
    >>> ESON.stringify([5, "six", tag])
    '[5,"six",#happy 7]'

### Tag parsing strategy ###

Tag parsing strategy defines how tag constructions should be parsed.
In code, it is a function, which takes tag identifier and
parsed tagged data and returns value that is result of tag parsing.

### Standard tag parsing strategy ###

Standard parsing strategy tries to find handler registered with the tag
identifier. When successful passes data to the handler and returns it result.
When no handler is registered with the identifier, default strategy is used if
provided or error is thrown. Standard parsing strategy is provided by
`ESON.parse` function:

#### ESON.parse(tag, [default_strategy]) ####

Parses `str` using registered tag handlers.
Uses `default_handler` for unregistered tags or throws error
if `default_handler` is not provided.

    >>> ESON.parse("#happy 7")
    Error: Tag 'happy' was not registered
    
    >>> ESON.parse("#happy 7", function(id, data){return [id,data]})
    ["happy", 7]

For completeness handler's definition follows:

#### Tag parsing handler ####

Tag parsing handler is a function bound to the tag identifier, which takes
parsed data and returns value that is result of tag parsing.

#### Tag tree ####

Tag tree is a structure where tag handlers are organized. It's a tree composed
of namespaces which can contain other namespaces or handlers.
Namespace is implemented by objects. Tree elements can be addressed
by slash (`/`) separated paths. Paths are tag identifiers, handlers are bound
to

#### ESON.registerTag( path , elem ) ####

Registers handler or namespace to the specified `path`.
Parent namespace of `path` has to be already registered but
`path` itself has to be free.

    >>> ESON.registerTag("happy", function(data){return data + " :)"})
    >>> ESON.parse("#happy 7")
    "7 :)"
    
    >>> namespace = {"logger": function(data){console.log(data); return data}}
    >>> ESON.registerTag("utils", namespace)
    >>> ESON.parse("#utils/logger 'Hello world!'")
    Hello world!
    'Hello world!'
    
    
#### ESON.resolveTag( path ) ####

Returns object registered at specified `path` or `undefined` if path is free.

    >>> ESON.resolveTag("utils")
    Object {logger: function}
    
    >>> ESON.resolveTag("foo")
    undefined
    
    >>> ESON.resolveTag("utils/logger")
    function (data){console.log(data); return data}

#### ESON.deleteTag( path ) ####

Frees whole subtree of `path` if exists.

    >>> ESON.parse("#happy 7")
    "7 :)"
    
    >>> ESON.deleteTag("happy")
    >>> ESON.parse("#happy 7")
    Error: Tag 'happy' was not registered
    
### Ignore strategy - ESON.pure_parse( str ) ###

Parses `str` ignoring all tags.

    >>> ESON.pure_parse('#all [#moo false, #poo "", #foo 0]')
    [false, "", 0]

### Struct strategy - ESON.struct_parse( str )

Parses `str` encapsulating tags into `ESON.Tag` object.

    >>> ESON.struct_parse("#happy 7")
    Tag {id: "happy", data: 7}

### ESON.stringify( obj ) ###

Converts `obj` to valid ESON string. Tries to copy JSON.stringify behavior.

    >>> ESON.stringify({str: "Hi", list: [4,2]})
    '{"str":"Hi","list":[4,2]}'
Object can define own .toESON() which is preferred to .toJSON() but
both can be used to define the value to be stringified.

    >>> poo.name = 'Joe';
    >>> poo.toEson = function (){
    ...     return new ESON.Tag('poo', this.name);   
    ... };
    >>> ESON.stringify(poo);
    '#poo "Joe"'

In lists and tags unserializable values (functions, undefined, ...) are
converted to nulls. In all other cases unserializable values are ignored.

    >>> ESON.stringify({n:null, u:undefined, t:true, f: function(){}})
    "{"n":null,"t":true}"
    
    >>> ESON.stringify([null, undefined, true, function(){}])
    "[null,null,true,null]"
    

### ESON.Parser

Internal object providing custom tag parsing strategies:

    >>> var p = new Parser("#happy 7");
    >>> p.tag_strategy = function (tag, data) {return [data, tag]};
    >>> p.parse();
    [7, "happy"]
    
### ESON.tags

Root namespace. You touch, your problem.


Makefile
--------

Since project is written in CoffeeScript it has own GNU Makefile.
You'll need [coffee](https://www.npmjs.org/package/coffee-script) for compiling,
[uglifyjs](https://www.npmjs.org/package/uglify-js) for minifying and
[mocha](https://www.npmjs.org/package/mocha) for testing in Node .

Make targets:

  * `all` - compile and minify
  * `compile` - just compile CoffeeScript
  * `tests` - compile also test files
  * `test-run` - run tests
  * `clean` 
  
In browser, you can test without Mocha.
First, make `tests` and then open [test/index.html](test/index.html).
