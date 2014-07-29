# =======
# Parsing
# =======


# Strategy for tag parsing.
# Parse tag calling handler.
standard_tag_resolver = (path, value)->
  r = ESON.resolveTag(path)
  if r is undefined
    throw new Error "Tag '#{path}' was not registered"
  r(value)


# Factory for strategies for tag parsing.
# Parse tag calling handler. Default handler for non-existing tags is given.
default_tag_resolver_factory = (default_handler) ->
  return (path, value)->
    r = ESON.resolveTag(path)
    return default_handler(path, value) unless r
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


  # Parses any ESON value
  parseVal: ()->

    # Get next token
    v = @list[@pos++]

    # Is it an object?
    if v == '{'
      return @parseObj()

    # Is it a list?
    else if v == '['
      return @parseList()

    # Is it a string?
    else if v[0] == '\"'
      return JSON.parse v  # use JSON for strings

    # Is it a tagged value?
    else if v[0] == '#'
      tag = v.slice(1)  # get tagged string
      val = @parseVal()  # again, value follows
      return @tag_resolver(tag, val)

    # Is it null?
    else if v[0] == 'n'
      return null

    # Is it true?
    else if v[0] == 't'
      return true

    # Is it false?
    else if v[0] == 'f'
      return false

    # Is it number?
    else if /^[-0-9]$/.test(v[0])
      return JSON.parse v  # use JSON for numbers also

    # What the hell is it?
    else
      @error "Invalid token"


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
# Uses registered tag handlers for parsing.
# Optionally, default tag handler can be provided
ESON.parse = (str, default_handler) ->
  p = new Parser str
  unless default_handler is undefined
    p.tag_resolver = default_tag_resolver_factory(default_handler)
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
