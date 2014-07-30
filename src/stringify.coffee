# =========
# Stringify
# =========


# Stringify overview
# ------------------
#
# ESON.stringify tries to match JSON.stringify behavior.
# Object can define own .toESON() which is preferred to .toJSON() but
# both can be used to define value to be stringified.
#
# Implementation of stringify concatenates strings only once - at the end.
# During the object searching these strings are pushed to array named prefix.


# Internal stringify function, pushes strings to array
_stringify = (value, prefix)->

  # Only interesting type is 'object'
  if typeof value is 'object'

    if value == null
      prefix.push 'null'

    # Object can provide custom value to stringify
    else if typeof value.toESON is 'function'
      _stringify value.toESON(), prefix

    # Support JSON's custom value
    else if typeof value.toJSON is 'function'
      _stringify value.toJSON(), prefix

    # Tag
    else if value instanceof Tag
      prefix.push '#'
      prefix.push value.id
      prefix.push ' '
      _stringify (value.data or null), prefix

    # Array
    else if value instanceof Array
      prefix.push '['   # Open array
      comma = false   # There's no comma before first element
      for x in value
        prefix.push ',' if comma
        # In arrays, undefined values are printed like null's
        # This corresponds to JSON's behavior
        unless x is undefined
          _stringify x, prefix
        else
          prefix.push 'null'
        comma = true   # Separate next element
      prefix.push ']'   # Close object

    # Otherwise, object is supposed to be an unordered map
    else
      prefix.push '{'   # Open object
      comma = false   # There's no comma before first element
      for k,v of value
        # In objects, undefined values are not shown
        unless v is undefined
          prefix.push ',' if comma
          prefix.push JSON.stringify(k)
          prefix.push ':'
          _stringify(v,prefix)
        comma = true   # Separate next element
      prefix.push '}'   # Close object

  # All the other types are stringified like JSON
  else
    prefix.push JSON.stringify(value)


# Public stringify function
# Initializes and concatenates list of output tokens
stringify = (value)->
  l = []
  _stringify(value,l)
  return l.join('')


# Expose stringify to the world
ESON.stringify = stringify
