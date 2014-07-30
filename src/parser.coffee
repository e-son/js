# =======
# Parsing
# =======


# Tag parsing strategies
# ----------------------
#
# Tag parsing strategy is a function, which takes tag identifier and
# parsed data and returns object that is result of tag parsing.
#
# NOTE:
# Tag parsing handler is a function similar to strategy but it does not take
# identifier, since it should be bound to the identifier by outer mechanism.
# (Normally, by tag tree)


# Tag parsing strategy
# Ignores tags.
ignore_tag_strategy = (tag, data)->
  data


# Tag parsing strategy
# Parses tags to ESON.Tag objects.
struct_tag_strategy = (tag, data)->
  new Tag tag, data


# Tag parsing strategy
# Raises error - used as default in make_standard_tag_strategy.
error_tag_strategy = (tag, data)->
  throw new Error "Tag '#{tag}' was not registered"


# Strategy for tag parsing.
# Tries to use registered handler and use given default_strategy otherwise
make_standard_tag_strategy = (default_strategy) ->
  default_strategy = default_strategy or error_tag_strategy
  return (tag, data)->
    r = ESON.resolveTag(tag)
    unless typeof r is 'function'
      return default_strategy(tag, data)
    return r(data)


# Class which stores data during parsing
# Relieves argument passing
class Parser

  # Initiates Parser
  constructor: (str)->
    @list = []  # Will contain tokens
    @pos = 0    # Actual position in @list
    @tag_strategy = make_standard_tag_strategy()
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
      return @tag_strategy(tag, val)

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
# Tries to use registered handler and use given default_strategy otherwise
ESON.parse = (str, default_strategy) ->
  p = new Parser str
  p.tag_strategy = make_standard_tag_strategy(default_strategy)
  p.parse()


# Create and expose parsing function which ignores tags
ESON.pure_parse = (str) ->
  p = new Parser str
  p.tag_strategy = ignore_tag_strategy
  p.parse()


# Create and expose parsing function parses tags to ESON.Tag object
ESON.struct_parse = (str) ->
  p = new Parser str
  p.tag_strategy = struct_tag_strategy
  p.parse()
