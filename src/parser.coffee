# =======
# Parsing
# =======


# Strategy for tag parsing.
# Parse tag calling reviver.
standard_tag_resolver = (path, value)->
  r = ESON.resolveTag(path)
  if r is undefined
    throw new Error "Tag '#{path}' was not registered"
  r(value)


# Factory for strategies for tag parsing.
# Parse tag calling reviver. Default reviver for non-existing tags is given.
default_tag_resolver_factory = (default_reviver) ->
  return (path, value)->
    r = ESON.resolveTag(path) or default_reviver
    return r(value)


# Strategy for tag parsing.
# Ignore them
ignore_tag_resolver = (path, value)->
  value


# Strategy for tag parsing.
# Pack them to stringify compatible Tag structure
composite_tag_resolver = (path, value)->
  new Tag path, value


# Class which stores data during parsing
# Relieves argument passing
class Parser

  # Initiates Parser
  constructor: (str)->
    @list = []  # Will contain tokens
    @pos = 0    # Actual position in @list
    @tag_resolver = standard_tag_resolver
    @tokenize(str)


  # Function used to raise error
  # (including details may be repetitive)
  error: (msg)->
    throw new Error (msg + ' near ' + @list[@pos-1])


  # Splits string into tokens, which can be easily parsed
  tokenize: (str)->

    # Regex to tokenize string
    regex = ///(
      [\s\x20]+                # Whitespace of any length
      |:
      |,
      |\{
      |\}
      |\[
      |\]
      |true
      |false
      |null
      |\#([^\s\x20]*)          # Tag
      |"(([^"\\]|\\.)*)"       # String
      |([-0-9][-0-9eE.]*)      # Number
    )///gm

    # Get all tokens,sum the lengths to check validity
    # and throw away the spaces
    list_with_spaces = str.match regex
    check_sum = 0
    for x in list_with_spaces
      check_sum+=x.length
      @list.push x unless /^[\s ]+$/.test(x)

    # There shouldn't be anything else than tokens and spaces
    @error "Unexpected tokens" unless check_sum == str.length


  # Starts parsing
  parse: ()->

    # ESON is expected to be any value
    res = @parseVal()

    # Everything should be parsed
    @error "Extra tokens" unless @pos == @list.length
    return res


  # A tree deciding parsing behaviour based on first token character
  parse_tree:

    # Object
    '{': (that, v)-> that.parseObj()

    # List
    '[': (that, v)-> that.parseList()

    # String
    '\"': (that, v)-> JSON.parse v

    # Tag
    '#': (that, v)->
      tag = v.slice(1)  # get tagged string
      val = that.parseVal()  # again, value follows
      return that.tag_resolver(tag, val)

    # Constants
    'n': (that, v)-> null
    't': (that, v)-> true
    'f': (that, v)-> false

    # Numbers
    '-': (that, v)-> JSON.parse v
    '0': (that, v)-> JSON.parse v
    '1': (that, v)-> JSON.parse v
    '2': (that, v)-> JSON.parse v
    '3': (that, v)-> JSON.parse v
    '4': (that, v)-> JSON.parse v
    '5': (that, v)-> JSON.parse v
    '6': (that, v)-> JSON.parse v
    '7': (that, v)-> JSON.parse v
    '8': (that, v)-> JSON.parse v
    '9': (that, v)-> JSON.parse v


  # Parses any ESON value
  parseVal: ()->

    # Get next token
    v = @list[@pos++]

    # Decide behaviour based on first char
    f = @parse_tree[v[0]]
    @error "Invalid token" if f is undefined

    # Apply the behaviour
    return f(this, v)


  # Parses opened list
  parseList: ()->

    # Spoil next token but do not move
    v = @list[@pos]

    # Is this the end?
    if v == ']'
      @pos++  # now we can move
      return []  # list is empty

    # If this is not end initiate result with first value
    result = [@parseVal()]

    # Read the other values in a loop
    while true
      v = @list[@pos++] # Get next token

      if v == ']'  # If already finished
        return result  # return what we have

      # Otherwise, comma should follow
      @error "Expected ',' or ']'" unless v == ','

      x = @parseVal() # Get next value
      result.push(x) # And store it


  # Parses opened object
  parseObj: ()->
    v = @list[@pos++] # Get next token
    result = {}

    # Is this the end?
    if v == '}'
      return {} #object is empty

    # Should start with a string (key)
    @error "Expected string" unless v[0] == '\"'

    # and continue with a semicolon
    @error "Expected ':'" unless @list[@pos++] == ":"

    # then the first value comes and is stored
    result[JSON.parse v] = @parseVal()

    # Read the other pairs in a loop
    while true
      v = @list[@pos++] # Get next token

      if v == '}' # If already
        return result # return what we have

      # Otherwise, comma should follow
      @error "Expected ',' or ']'" unless v == ','

      # Get new key and check it is a string
      v = @list[@pos++]
      @error "Expected string" unless v[0] == '\"'

      # Enforce semicolon
      @error "Expected ':'" unless @list[@pos++] == ":"

      # Finally, get the value
      result[JSON.parse v] = @parseVal()


# Expose Parser to the world
ESON.Parser = Parser


# Create and expose standard parsing function
# Handles tag by calling tag reviver
# Optionally, default tag reviver can be provided
ESON.parse = (str, default_reviver) ->
  p = new Parser str
  unless default_reviver is undefined
    p.tag_resolver = default_tag_resolver_factory(default_reviver)
  p.parse()


# Create and expose parsing function which ignores tags
ESON.pure_parse = (str) ->
  p = new Parser str
  p.tag_resolver = ignore_tag_resolver
  p.parse()


# Create and expose parsing function which creates Tag structures
ESON.struct_parse = (str) ->
  p = new Parser str
  p.tag_resolver = composite_tag_resolver
  p.parse()
